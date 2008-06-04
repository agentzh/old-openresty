module RestyScript.Parser where

import RestyScript.AST.View
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
                relOp ">=", relOp ">",
                relOp "<=", relOp "<>", relOp "<",
                relOp "=", relOp "!=", relOp' "like"
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

parseArithAtom = parseNumber
             <|> parseString
             <|> try (do {
                r <- parseVariable;
                notFollowedBy (char '.' <|> char '(');
                return r })
             <|> try (parseFuncCall)
             <|> parseColumn
             <|> parens parseExpr

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
                   v <- symbol
                   spaces
                   return $ Variable pos v

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

parseColumn :: Parser RSVal
parseColumn = do a <- parseIdent
                 spaces
                 b <- option Null (char '.' >> spaces >> parseIdent)
                 return $ case b of
                    Null -> Column a
                    otherwise -> QualifiedColumn a b
          <?> "column"

parseModel :: Parser RSVal
parseModel = try(parseFuncCall)
         <|> liftM Model parseIdent
         <?> "model"

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

