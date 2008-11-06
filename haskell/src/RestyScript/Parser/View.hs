module RestyScript.Parser.View (
    readView, parseView
) where

import RestyScript.Parser
import RestyScript.AST
import Text.ParserCombinators.Parsec
import Text.ParserCombinators.Parsec.Expr
import Monad (liftM)

readView :: String -> String -> Either ParseError RSVal
readView = parse (do {
    ast <- parseView;
    many (string ";" >> spaces) >> eof;
    return ast })

parseView :: Parser RSVal
parseView = do ast <- (spaces >> parseSetExpr)
               spaces
               return ast

parseSetExpr :: Parser RSVal
parseSetExpr = buildExpressionParser setOpTable parseQuery

setOpTable = [[
                op "union", op "except", op "intersect" ]]
      where
        op s
           = Infix (do { reservedWord s;
                         spaces;
                         suffix <- option "" (keyword "all");
                         spaces;
                         return $ SetOp $
                            if suffix == "" then s else s ++ " all" }
                <?> "operator") AssocLeft

parseQuery :: Parser RSVal
parseQuery = do select <- spaces >> parseSelect
                from <- option Empty parseFrom
                whereClause <- option Empty parseWhere
                moreClauses <- sepBy parseMoreClause spaces
                return $ Query $ filter (Empty /=)
                    [select, from, whereClause] ++ moreClauses
         <|> parens parseSetExpr
         <?> "select statement"

parseSet :: Parser RSVal
parseSet = try(parseFuncCall)
        <|> parseModel
        <|> parseQuery
        <?> "model"

parseMoreClause :: Parser RSVal
parseMoreClause = parseOrderBy
              <|> parseLimit
              <|> parseOffset
              <|> parseGroupBy

parseLimit :: Parser RSVal
parseLimit = liftM Limit (keyword "limit" >> many1 space >> parseExpr)
         <?> "limit clause"

parseOffset :: Parser RSVal
parseOffset = liftM Offset (keyword "offset" >> many1 space >> parseExpr)
          <?> "offset clause"

parseOrderBy :: Parser RSVal
parseOrderBy = do try (keyword "order") >> many1 space >>
                    keyword "by" >> many1 space
                  liftM OrderBy $ sepBy1 parseOrderPair listSep
           <?> "order by clause"

parseOrderPair :: Parser RSVal
parseOrderPair = do col <- parseColumn
                    dir <- parseDir
                    spaces
                    return $ OrderPair col dir

parseDir :: Parser RSVal
parseDir = liftM Keyword (keyword "asc")
       <|> liftM Keyword (keyword "desc")
       <|> parseVariable
       <|> (return $ Keyword "asc")

parseGroupBy :: Parser RSVal
parseGroupBy = liftM GroupBy (keyword "group" >> many1 space >>
                    keyword "by" >> many1 space >> parseColumn)

parseFrom :: Parser RSVal
parseFrom = liftM From (keyword "from" >> many1 space >>
                sepBy1 parseFromItem listSep)
        <?> "from clause"

parseFromItem :: Parser RSVal
parseFromItem = do set <- parseSet
                   alias <- option Null parseSetAlias
                   return $ case alias of
                                Null -> set
                                otherwise -> Alias set alias

parseSetAlias :: Parser RSVal
parseSetAlias = keyword "as" >> many1 space >> (parseIdent <|> parseCapture)

parseCapture :: Parser RSVal
parseCapture = liftM Capture $ parens (sepBy1 parseParam listSep)

parseParam :: Parser (RSVal, RSVal)
parseParam = do param <- parseIdent
                typ <- spaces >> parseType
                return (param, typ)

parseType :: Parser RSVal
parseType = do s <- symbol
               spaces
               return $ Type s

parseSelect :: Parser RSVal
parseSelect = do keyword "select" >> many1 space
                 cols <- parseModifiedQuery
                 return $ Select cols

parseModifiedQuery :: Parser [RSVal]
parseModifiedQuery = do
    mod <- option "" (keyword "distinct" <|> keyword "all")
    spaces
    lst <- parseSelectedItemList
    spaces
    return $ case mod of
        "distinct" -> [Distinct lst]
        "all" -> [All lst]
        otherwise -> lst

parseSelectedItemList :: Parser [RSVal]
parseSelectedItemList = do
    cols <- sepBy1 (parseSelectedItem <|> parseAnyColumn) listSep
    spaces
    return cols

parseSelectedItem :: Parser RSVal
parseSelectedItem = do col <- parseExpr
                       alias <- option Null
                            (keyword "as" >> spaces >> parseIdent)
                       return $ case alias of
                            Null -> col
                            otherwise -> Alias col alias

