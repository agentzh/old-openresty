module Main where

import System.Environment
import RestyScript
import System.IO

main :: IO ()
main = do args <- getArgs
          case length args of
            1 -> processArg (args !! 0)
            otherwise -> putStrLn "Usage: restyview <source>"

processArg :: String -> IO ()
processArg input = case compileView "RestyScript" input of
                    Left err -> hPutStrLn stderr err
                    Right vals -> do putStrLn (vals!!0)
                                     putStrLn (vals!!1)

