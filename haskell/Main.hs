module Main where

import System.Environment
import RestyScript

main :: IO ()
main = do args <- getArgs
          case length args of
            1 -> putStrLn (readStmt (args !! 0))
            otherwise -> putStrLn "Usage: restyview <source>"

