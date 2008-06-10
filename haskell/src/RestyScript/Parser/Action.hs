module RestyScript.Parser.Action (
    readAction
) where

import RestyScript.Parser
import RestyScript.Parser.View
import RestyScript.AST
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Monad (liftM, msum)

readAction :: String -> String -> Either ParseError RSVal
readAction = parse parseAction

parseAction :: Parser RSVal
parseAction = do spaces
                 stmts <- sepEndBy1 parseStmt $ many1 (char ';' >> spaces)
                 eof
                 return $ Action stmts

parseStmt :: Parser RSVal
parseStmt = parseDelete
        <|> parseUpdate
        <|> parseHttp
        <|> parseView
        <?> "RestyAction statement"

httpCmds = ["GET", "PUT", "DELETE", "POST"]

parseHttp :: Parser RSVal
parseHttp = do cmd <- msum $ map keyword httpCmds
               spaces
               url <- parseLitExpr
               content <- option Null parseJSON
               return $ HttpCmd cmd url content

litOpTable = [
     [Infix (do { reservedOp "||"; spaces; return Concat} <?> "operator") AssocLeft]
    ]

parseLitExpr :: Parser RSVal
parseLitExpr = buildExpressionParser litOpTable parseLitAtom
        <?> "literal expression"

parseLitAtom :: Parser RSVal
parseLitAtom = parseNumber
           <|> parseString
           <|> parseDString
           <|> try (parseVerbatimString)
           <|> parseVariable
           <|> parens parseLitExpr

-- Double quoted strings in the context of HTTP commands
parseDString :: Parser RSVal
parseDString = do s <- between (char '"' >> spaces) (char '"' >> spaces)
                        $ many $ quotedChar '"'
                  spaces
                  return $ String s

parseJSON :: Parser RSVal
parseJSON = parseObject
        <|> parseArray
        <|> parseLitExpr
        <?> "JSON content"

parseObject :: Parser RSVal
parseObject = do obj <- between (char '{' >> spaces) (char '}' >> spaces)
                    $ sepBy1 parsePair (char ',' >> spaces)
                 spaces
                 return $ Object obj

parsePair :: Parser RSVal
parsePair = do key <- parseKey
               char ':'
               spaces
               value <- parseJSON
               return $ Pair key value

parseKey :: Parser RSVal
parseKey = parseLitExpr
       <|> liftM String symbol
       <?> "JSON hash key"

parseArray :: Parser RSVal
parseArray = do lst <- between (char '[' >> spaces) (char ']' >> spaces)
                    $ sepBy parseJSON (char ',' >> spaces)
                spaces
                return $ Array lst

parseDelete :: Parser RSVal
parseDelete = do keyword "delete" >> spaces >> keyword "from" >> spaces
                 model <- parseModel
                 cond <- parseWhere
                 return $ Delete model cond
          <?> "SQL delete statement"

parseUpdate :: Parser RSVal
parseUpdate = do keyword "update" >> spaces
                 model <- parseModel
                 assign <- keyword "set" >> spaces >> parseAssign
                 cond <- option Null parseWhere
                 return $ Update model assign cond
          <?> "SQL update statement"

parseAssign :: Parser RSVal
parseAssign = do col <- parseColumn
                 char '=' >> spaces
                 expr <- parseExpr
                 return $ Assign col expr
          <?> "Column assignment"

