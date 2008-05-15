module RestyScript.Parser (
    readView
) where

import RestyScript.AST
import Text.ParserCombinators.Parsec

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
                x <- parseTerm
                return $ Limit x
         <?> "limit clause"

parseOffset :: Parser SqlVal
parseOffset = do string "offset" >> many1 space
                 x <- parseTerm
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
               models <- sepBy1 parseModel listSep
               return $ From models
        <|> (return $ Null)
        <?> "from clause"

parseModel :: Parser SqlVal
parseModel = do model <- parseIdent
                return $ Model model
         <?> "model"

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
                 cols <- sepBy1 (parseTerm <|> parseAnyColumn) listSep
                 return $ Select cols
          <?> "select clause"

parseColumn :: Parser SqlVal
parseColumn = do col <- parseIdent
                 spaces
                 return $ Column col
          <?> "column"

parseAnyColumn :: Parser SqlVal
parseAnyColumn = do char '*'
                    spaces
                    return AnyColumn

parseWhere :: Parser SqlVal
parseWhere = do string "where" >> many1 space
                cond <- parseOr
                return $ Where cond
         <|> (return Null)
         <?> "where clause"

parseOr :: Parser SqlVal
parseOr = do args <- sepBy1 parseAnd (opSep' "or")
             return $ OrExpr args

opSep :: String -> Parser ()
opSep op = string op >> spaces

opSep' :: String -> Parser ()
opSep' op = keyword op >> spaces


parseAnd :: Parser SqlVal
parseAnd = do args <- sepBy1 parseLogicAtom (opSep' "and")
              return $ AndExpr args

parseLogicAtom :: Parser SqlVal
parseLogicAtom = parseRel
             <|> do char '('
                    spaces
                    expr <- parseOr
                    char ')'
                    spaces
                    return expr

parseRel :: Parser SqlVal
parseRel = do lhs <- parseTerm
              op <- relOp
              spaces
              rhs <- parseTerm
              return $ RelExpr op lhs rhs
         <?> "comparison expression"

relOp :: Parser String
relOp = string "="
         <|> try (string ">=")
         <|> string ">"
         <|> try (string "<=")
         <|> try (string "<>")
         <|> string "<"
         <|> string "!="
         <|> keyword "like"

parseTerm :: Parser SqlVal
parseTerm = parseNumber
        <|> parseString
        <|> parseVariable
        <|> try (parseFuncCall)
        <|> parseColumn
        <?> "term"

keyword :: String -> Parser String
keyword s = try (do string s
                    notFollowedBy alphaNum
                    return s)

parseFuncCall :: Parser SqlVal
parseFuncCall = do f <- symbol
                   spaces >> char '(' >> spaces
                   args <- sepBy parseTerm listSep
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

