module Main where

import RestyScript.Parser
import qualified RestyScript.Emitter.RestyScript as RS
import qualified RestyScript.Emitter.Stats as St

import System
import System.IO

main :: IO ()
main = do args <- getArgs
          input <- hGetContents stdin
          case compileView "RestyScript" input of
            Left err -> hPutStrLn stderr err
            Right vals -> do putStrLn (vals !! 0)
                             putStrLn (vals !! 1)

compileView :: String -> String -> Either String [String]
compileView file input = do case readView file input of
                                Left err -> Left $ show err
                                Right ast -> Right [show ast, RS.emit ast]

