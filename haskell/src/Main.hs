module Main where

import System
import RestyScript
import System.IO

main :: IO ()
main = do input <- hGetContents stdin
          case compileView "RestyScript" input of
            Left err -> hPutStrLn stderr err
            Right vals -> do putStrLn (vals !! 0)
                             putStrLn (vals !! 1)

