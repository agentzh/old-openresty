module RestyScript (
    compileView
) where

import RestyScript.Parser
import RestyScript.Emitter

compileView :: String -> String -> Either String [String]
compileView file input = do case readView file input of
                                Left err -> Left $ show err
                                Right ast -> Right [dump show ast, dump emitSql ast]
    where dump f lst = unwords $ map f lst

