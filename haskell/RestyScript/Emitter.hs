module RestyScript.Emitter (
    emitSql
) where

import RestyScript.AST
import Data.List (intercalate)
import Text.Printf (printf)

quote :: Char -> String -> String
quote sep s = [sep] ++ quoteChars s ++ [sep]
              where quoteChars (x:xs) =
                        if x == sep || x == '\\'
                            then x : x : quoteChars xs
                            else case lookup x escapes of
                                Just r -> r ++ quoteChars xs
                                Nothing -> x : quoteChars xs
                    quoteChars [] = ""

quoteLiteral :: String -> String
quoteLiteral = quote '\''

quoteIdent :: String -> String
quoteIdent = quote '"'

emitSql :: SqlVal -> String
emitSql (String s) = quoteLiteral s
emitSql (Select cols) = "select " ++ (intercalate ", " $ map emitSql cols)
emitSql (From models) = "from " ++ (intercalate ", " $ map emitSql models)
emitSql (Where cond) = "where " ++ (emitSql cond)
emitSql (Model model) = emitSql model
emitSql (Column col) = emitSql col
emitSql (Symbol name) = quoteIdent name
emitSql (Integer int) = show int
emitSql (Float float) = printf "%0f" float
emitSql (OrExpr args) = "(" ++ (intercalate " or " $ map emitSql args) ++ ")"
emitSql (AndExpr args) = "(" ++ (intercalate " and " $ map emitSql args) ++ ")"
emitSql (RelExpr (op, lhs, rhs)) = "(" ++ (emitSql lhs) ++ " " ++ op ++ " " ++ (emitSql rhs) ++ ")"
emitSql (NullClause) = ""

escapes :: [(Char, String)]
escapes = zipWith ch "\b\n\f\r\t" "bnfrt"
    where ch a b = (a, '\\':[b])


