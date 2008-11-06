module RestyScript.Parser where

import RestyScript.AST
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Monad (liftM)

unescapes :: [(Char, Char)]
unescapes = zipWith pair "bnfrt" "\b\n\f\r\t"
    where pair a b = (a, b)

quotedChar :: Char -> Parser Char
quotedChar c = do c <- char '\\' >> anyChar
                  return $ case lookup c unescapes of
                            Just r -> r
                            Nothing -> c
           <|> noneOf [c]
           <|> do try (string [c,c])
                  return c

parens :: Parser a -> Parser a
parens = between (char '(' >> spaces) (char ')' >> spaces)

keyword :: String -> Parser String
keyword s = try (do string s
                    notFollowedBy alphaNum
                    return s)

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

parseWhere :: Parser RSVal
parseWhere = do keyword "where" >> many1 space
                cond <- parseExpr
                return $ Where cond
         <?> "where clause"

parseExpr :: Parser RSVal
parseExpr = buildExpressionParser opTable parseArithAtom
        <?> "expression"

opTable = [
            [ op "::" TypeCast AssocNone ],
            [  preOp "-" Minus, preOp "+" Plus ],
            [
                arithOp "^"
                ],
            [
                arithOp "*", arithOp "/", arithOp "%"
                ],
            [
                arithOp "+", arithOp "-"
                ],
            [
                arithOp "||"
                ],
            [
                relOp "@@", relOp "@>", relOp "@<", relOp "~", relOp "@",
                relOp "<<=", relOp "<<", relOp ">>=", relOp ">>",
                relOp ">=", relOp ">",
                relOp "<=", relOp "<>", relOp "<",
                relOp "=", relOp "!=", relOp' "like",
                relOp' "is not",
                relOp' "is"
                ],
            [   preOp' "not" Not ],
            [
                op' "and" And AssocLeft
                ],
            [
                op' "or" Or AssocLeft
                ]
            ]
      where
        preOp s f
            = Prefix (do { reservedOp s; spaces; return f} <?> "operator")
        preOp' s f
            = Prefix (do { reservedWord s; spaces; return f} <?> "operator")

        op s f assoc
           = Infix (do { reservedOp s; spaces; return f} <?> "operator") assoc
        op' s f assoc
           = Infix (do { reservedWord s; spaces; return f} <?> "operator") assoc
        relOp s
           = op s (Compare s) AssocNone
        relOp' s
           = op' s (Compare s) AssocNone
        arithOp s
           = op s (Arith s) AssocLeft

reservedWord :: String -> Parser String
reservedWord s = try(do string s; notFollowedBy alphaNum; spaces; return s)

reservedOp :: String -> Parser String
reservedOp s = try(do string s; spaces; return s)

opSep :: String -> Parser ()
opSep op = string op >> spaces

parseArithAtom :: Parser RSVal
parseArithAtom = parseNumber
             <|> parseString
             <|> parseBool
             <|> parseNull
             <|> parseDistinct
             <|> try (parseVerbatimString)
             <|> try (do {
                r <- parseVariable;
                notFollowedBy (char '.' <|> char '(');
                return r })
             <|> try (parseFuncCall)
             <|> try(parseArrayIndex)
             <|> parseColumn
             <|> parens parseExpr

parseArrayIndex :: Parser RSVal
parseArrayIndex = do
    array <- (parseColumn <|> parens parseExpr)
    ind   <- between (char '[' >> spaces) (char ']' >> spaces) parseExpr
    return $ ArrayIndex array ind

parseBool :: Parser RSVal
parseBool = (keyword "true" >> spaces >> return RSTrue)
        <|> (keyword "false" >> spaces >> return RSFalse)

parseNull :: Parser RSVal
parseNull = keyword "null" >> spaces >> return Null

parseDistinct :: Parser RSVal
parseDistinct = do
    mod <- (keyword "distinct" <|> keyword "all")
    spaces
    cols <- sepBy1 parseExpr listSep
    spaces
    return $ case mod of
        "distinct" -> Distinct cols
        otherwise -> All cols

parseFuncCall :: Parser RSVal
parseFuncCall = do f <- parseIdent
                   args <- parens parseArgs
                   return $ FuncCall f args


parseArgs :: Parser [RSVal]
parseArgs = do v <- parseAnyColumn
               return [v]
        <|> sepBy parseExpr listSep

parseAnyColumn :: Parser RSVal
parseAnyColumn = do char '*'
                    spaces
                    return AnyColumn

parseVariable :: Parser RSVal
parseVariable = do char '$'
                   pos <- getPosition
                   prefix <- option "" $ string "_"
                   v <- symbol
                   spaces
                   return $ Variable pos $ prefix ++ v

parseNumber :: Parser RSVal
parseNumber = try (parseFloat)
          <|> parseInteger
          <?> "number"

parseInteger :: Parser RSVal
parseInteger = do digits <- many1 digit
                  spaces
                  return $ Integer $ read digits

parseFloat :: Parser RSVal
parseFloat = do int <- many1 digit
                dec <- char '.' >> many digit
                spaces
                return $ Float $
                   read (int ++ "." ++ noEmpty dec)
         <|> do dec <- char '.' >> many1 digit
                spaces
                return $ Float $ read ("0." ++ dec)
         <?> "floating-point number"
    where noEmpty s = if s == "" then "0" else s

parseString :: Parser RSVal
parseString = do s <- between (char '\'') (char '\'')
                         $ many $ quotedChar '\''
                 spaces
                 return $ String s
          <?> "string"

parseVerbatimString :: Parser RSVal
parseVerbatimString = do delim <- char '$' >> option "" identifier
                         char '$'
                         str <- manyTill anyChar (try (char '$' >> string delim >> char '$'))
                         spaces
                         -- char '$' >> string delim >> char '$'
                         return $ String str

identifier :: Parser String
identifier = do c <- letter <|> char '_'
                s <- many (alphaNum <|> char '_')
                return (c : s)

parseColumn :: Parser RSVal
parseColumn = do a <- parseIdent
                 spaces
                 b <- option Empty (char '.' >> spaces >> parseIdent)
                 return $ case b of
                    Empty -> Column a
                    otherwise -> QualifiedColumn a b
          <?> "column"

parseModel :: Parser RSVal
parseModel = liftM Model parseIdent

parseIdent :: Parser RSVal
parseIdent = do s <- symbol
                spaces
                return $ Symbol s
         <|> do char '"'
                s <- symbol
                char '"' >> spaces
                return $ Symbol s
         <|> parseVariable
         <?> "identifier entry"

