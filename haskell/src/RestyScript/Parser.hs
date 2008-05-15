module RestyScript.Parser (
    readView
) where

import RestyScript.AST
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Monad (liftM)

readView :: String -> String -> Either ParseError [SqlVal]
readView = parse parseView

parseView :: Parser [SqlVal]
parseView = do spaces
               select <- parseSelect
               from <- parseFrom
               whereClause <- parseWhere
               moreClauses <- sepBy parseMoreClause spaces
               spaces
               eof
               return $ filter (\x->x /= Null)
                            [select, from, whereClause] ++ moreClauses
        <?> "select statement"

parseMoreClause :: Parser SqlVal
parseMoreClause = parseOrderBy
              <|> parseLimit
              <|> parseOffset
              <|> parseGroupBy

parseLimit :: Parser SqlVal
parseLimit = do string "limit" >> many1 space
                x <- parseExpr
                return $ Limit x
         <?> "limit clause"

parseOffset :: Parser SqlVal
parseOffset = do string "offset" >> many1 space
                 x <- parseExpr
                 return $ Offset x
          <?> "offset clause"

parseOrderBy :: Parser SqlVal
parseOrderBy = do try (string "order") >> many1 space >>
                    string "by" >> many1 space
                  pairs <- sepBy parseOrderPair listSep
                  return $ OrderBy pairs
           <?> "order by clause"

parseOrderPair :: Parser SqlVal
parseOrderPair = do col <- parseColumn
                    dir <- (string "asc" <|> string "desc" <|> (return "asc"))
                    spaces
                    return $ OrderPair col dir

parseGroupBy :: Parser SqlVal
parseGroupBy = do string "group" >> many1 space >>
                    string "by" >> many1 space
                  x <- parseColumn
                  return $ GroupBy x

parseFrom :: Parser SqlVal
parseFrom = do string "from" >> many1 space
               models <- sepBy1 parseFromItem listSep
               return $ From models
        <|> (return $ Null)
        <?> "from clause"

parseFromItem :: Parser SqlVal
parseFromItem = do model <- parseModel
                   alias <- parseModelAlias
                   return $ case alias of
                                Null -> model
                                otherwise -> Alias model alias

parseModel :: Parser SqlVal
parseModel = try(parseFuncCall)
         <|> liftM Model parseIdent
         <?> "model"

parseModelAlias :: Parser SqlVal
parseModelAlias = liftM Model (keyword "as" >> many1 space >> parseIdent)
              <|> return Null

parseIdent :: Parser SqlVal
parseIdent = do s <- symbol
                spaces
                return $ Symbol s
         <|> do char '"'
                s <- symbol
                char '"' >> spaces
                return $ Symbol s
         <|> parseVariable
         <?> "identifier entry"

symbol :: Parser String
symbol = do char '"'
            s <- word
            char '"'
            return s
     <|> word

word :: Parser String
word = do x <- letter
          xs <- many (alphaNum <|> char '_')
          return (x:xs)

listSep :: Parser ()
listSep = opSep ","

parseSelect :: Parser SqlVal
parseSelect = do string "select" >> many1 space
                 cols <- sepBy1 (parseSelectedItem <|> parseAnyColumn) listSep
                 return $ Select cols
          <?> "select clause"

parseSelectedItem :: Parser SqlVal
parseSelectedItem = do col <- parseExpr
                       alias <- (keyword "as" >> spaces >> parseIdent)
                                    <|> (return Null)
                       return $ case alias of
                            Null -> col
                            otherwise -> Alias col alias

parseColumn :: Parser SqlVal
parseColumn = do a <- parseIdent
                 spaces
                 b <- (char '.' >> spaces >> parseIdent) <|> (return Null)
                 return $ case b of
                    Null -> Column a
                    otherwise -> QualifiedColumn a b
          <?> "column"

parseAnyColumn :: Parser SqlVal
parseAnyColumn = do char '*'
                    spaces
                    return AnyColumn

parseWhere :: Parser SqlVal
parseWhere = do string "where" >> many1 space
                cond <- parseExpr
                return $ Where cond
         <|> (return Null)
         <?> "where clause"

parseExpr :: Parser SqlVal
parseExpr = buildExpressionParser opTable parseArithAtom
        <?> "expression"

opTable = [
            [
                relOp ">=", relOp ">",
                relOp "<=", relOp "<>", relOp "<",
                relOp "=", relOp "!=", relOp' "like"],
            [op' "and" And AssocLeft],
            [op' "or" Or AssocLeft]
            ]
      where
        op s f assoc
           = Infix (do { reservedOp s; spaces; return f} <?> "operator") assoc
        op' s f assoc
           = Infix (do { reservedWord s; spaces; return f} <?> "operator") assoc
        relOp s
           = op s (Compare s) AssocNone
        relOp' s
           = op' s (Compare s) AssocNone

reservedWord :: String -> Parser String
reservedWord s = try(do string s; notFollowedBy alphaNum; spaces; return s)

reservedOp :: String -> Parser String
reservedOp s = try(do string s; spaces; return s)

opSep :: String -> Parser ()
opSep op = string op >> spaces

parseArithAtom = parseNumber
             <|> parseString
             <|> parseVariable
             <|> try (parseFuncCall)
             <|> parseColumn
             <|> do char '(' >> spaces
                    t <- parseExpr
                    char ')' >> spaces
                    return t

keyword :: String -> Parser String
keyword s = try (do string s
                    notFollowedBy alphaNum
                    return s)

parseFuncCall :: Parser SqlVal
parseFuncCall = do f <- symbol
                   spaces >> char '(' >> spaces
                   args <- (do v <- parseAnyColumn; return [v]) <|>
                            sepBy parseExpr listSep
                   spaces >> char ')' >> spaces
                   return $ FuncCall f args

parseVariable :: Parser SqlVal
parseVariable = do char '$'
                   v <- symbol
                   spaces
                   return $ Variable v

parseNumber :: Parser SqlVal
parseNumber = do sign <- parseSign
                 (try (parseFloat sign) <|> parseInteger sign)
          <?> "number"

parseSign :: Parser String
parseSign = do c <- oneOf "+-"
               spaces
               return $ if c == '+' then "" else "-"
        <|> (return "")

parseInteger :: String -> Parser SqlVal
parseInteger sign  = do digits <- many1 digit
                        spaces
                        return $ Integer $ read (sign ++ digits)

parseFloat :: String -> Parser SqlVal
parseFloat sign = do int <- many1 digit
                     char '.'
                     dec <- many digit
                     spaces
                     return $ Float $ read (sign ++ int ++ "." ++ noEmpty dec)
              <|> do char '.'
                     dec <- many1 digit
                     spaces
                     return $ Float $ read (sign ++ "0." ++ dec)
              <?> "floating-point number"
    where noEmpty s = if s == "" then "0" else s

parseString :: Parser SqlVal
parseString = do char '\''
                 s <- many $ quotedChar '\''
                 char '\''
                 spaces
                 return $ String s
          <?> "string"

unescapes :: [(Char, Char)]
unescapes = zipWith pair "bnfrt" "\b\n\f\r\t"
    where pair a b = (a, b)

quotedChar :: Char -> Parser Char
quotedChar c = do char '\\'
                  c <- anyChar
                  return $ case lookup c unescapes of
                            Just r -> r
                            Nothing -> c
           <|> noneOf [c]
           <|> do try (string [c,c])
                  return c

