module Main where

import RestyScript.Parser
import qualified RestyScript.Emitter.RestyScript as RS
import qualified RestyScript.Emitter.Stats as St

import System
import System.IO
import System.Exit

main :: IO ()
main = do args <- getArgs
          case args of
            "rs" : xs -> genRS
            "frags" : xs -> genFrags
            otherwise -> die "No command specified"

genRS :: IO ()
genRS = do input <- hGetContents stdin
           case readView "RestyScript" input of
             Left err -> die (show err)
             Right ast -> do putStrLn $ show ast
                             putStrLn $ RS.emit ast

die :: String -> IO ()
die msg = do hPutStrLn stderr msg
             exitWith $ ExitFailure 1

genFrags :: IO ()
genFrags = do input <- hGetContents stdin
              case readView "RestyScript" input of
                  Left err -> hPutStrLn stderr $ show err
                  Right ast -> do putStrLn $ show ast
                                  putStrLn $ RS.emit ast

