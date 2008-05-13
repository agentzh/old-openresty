module RestyScript (
    SqlVal(..),
    readStmt
) where

import Text.ParserCombinators.Parsec
import Data.List (intercalate)

data VarContext = SymbolContext | LiteralContext
                deriving (Ord, Eq, Show)

data SqlVal = Select [SqlVal]
            | From [SqlVal]
            | Where SqlVal
            | Column String
            | Model String
            | QualifiedColumn (String, String)
            | Integer Integer
            | Float Float
            | String String
            | Variable (String, VarContext)
            | VariableWithDefault (String, SqlVal, VarContext)
            | FuncCall (String, [SqlVal])
            | ComparisonExpr (String, [SqlVal])
            | OrExpr [SqlVal]
            | AndExpr [SqlVal]
            | NullClause
                deriving (Ord, Eq, Show)

{- instance Show SqlVal where show = showVal -}

quote :: Char -> String -> String
quote sep s = [sep] ++ quoteChars s ++ [sep]
              where quoteChars (x:xs) =
                        if x== sep
                            then sep : quoteChars xs
                            else x : quoteChars xs
                    quoteChars [] = ""

quoteLiteral :: String -> String
quoteLiteral = quote '\''

quoteIdent :: String -> String
quoteIdent = quote '"'

asSql :: SqlVal -> String
asSql (String s) = quoteLiteral s
asSql (Select cols) = "select " ++ (intercalate ", " $ map asSql cols)
asSql (From models) = "from " ++ (intercalate ", " $ map asSql models)
asSql (Model name) = quoteIdent name
asSql (Column name) = quoteIdent name
asSql (NullClause) = ""

readStmt :: String -> String
readStmt input = case parse parseStmt "RestyScript" input of
                    Left err -> "ERROR: " ++ show err
                    Right vals -> (unwords $ map show vals) ++ "\n" ++
                                  (unwords $ map asSql vals)

parseStmt :: Parser [SqlVal]
parseStmt = do select <- parseSelect
               spaces
               from <- parseFrom
               spaces
               whereClause <- parseWhere
               return $ filter (\x->x /= NullClause)
                            [select, from, whereClause]

{-
          <|> parseWhere
          <|> parseLimit
          <|> parseLimit
          <|> parseOffset
          <|> parseGroupBy
          <|> parseOrderBy
          <?> "SQL clause"
-}

parseFrom :: Parser SqlVal
parseFrom = do string "from" >> many1 space
               models <- sepBy1 parseModel listSep
               return $ From models
        <|> (return $ NullClause)
        <?> "from clause"

parseModel :: Parser SqlVal
parseModel = do model <- symbol
                return $ Model model

symbol :: Parser String
symbol = do x <- letter
            xs <- many alphaNum
            return (x:xs)

listSep :: Parser ()
listSep = opSep ","

parseSelect :: Parser SqlVal
parseSelect = do string "select" >> many1 space
                 cols <- sepBy1 parseColumn listSep
                 return $ Select cols
          <?> "select clause"

parseColumn :: Parser SqlVal
parseColumn = do column <- symbol
                 return $ Column column
          <?> "selected column"

parseWhere :: Parser SqlVal
parseWhere = do string "where" >> many1 space
                cond <- parseOr
                return $ Where cond
         <|> (return $ NullClause)
         <?> "where clause"

parseOr :: Parser SqlVal
parseOr = do args <- sepBy1 parseAnd (opSep "or")
             return $ OrExpr args

opSep :: String -> Parser ()
opSep op = try(spaces >> string op) >> spaces

parseAnd :: Parser SqlVal
parseAnd = do args <- sepBy1 parseColumn (opSep "and")
              return $ AndExpr args

