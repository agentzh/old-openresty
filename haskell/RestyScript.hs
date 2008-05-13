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
            | ComparisonExpr (String, SqlVal, SqlVal)
            | LogicalExpr (String, SqlVal, SqlVal)
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
asSql (From models) = "from " ++ (intercalate ", " $ map asSql models)
asSql (Model name) = quoteIdent name

readStmt :: String -> String
readStmt input = case parse parseStmt "RestyScript" input of
                    Left err -> "ERROR: " ++ show err
                    Right vals -> (unwords $ map show vals) ++ "\n" ++
                                  (unwords $ map asSql vals)

parseStmt :: Parser [SqlVal]
parseStmt = sepBy1 parseClause spaces

parseClause :: Parser SqlVal
parseClause = parseFrom
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
parseFrom = do endBy (string "from") (many1 space)
               vals <- sepBy1 parseModel parseListSep
               return $ From vals
        <?> "from clause"

parseModel :: Parser SqlVal
parseModel = do model <- symbol
                return $ Model model

symbol :: Parser String
symbol = do x <- letter
            xs <- many alphaNum
            return (x:xs)

parseListSep :: Parser ()
parseListSep = spaces >> string "," >> spaces

