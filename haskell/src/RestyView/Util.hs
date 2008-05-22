module RestyView.Util (
    quoteLiteral,
    quoteIdent
) where

escapes :: [(Char, String)]
escapes = zipWith ch "\b\n\f\r\t" "bnfrt"
    where ch a b = (a, '\\':[b])

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

