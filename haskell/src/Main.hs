module Main where

import RestyScript.Parser
import RestyScript.AST
import qualified RestyScript.Emitter.RestyScript as RS
import qualified RestyScript.Emitter.Stats as St

import System
import System.IO
import System.Exit

argHandles :: [(String, SqlVal -> IO ())]
argHandles = [
    ("rs", putStrLn . RS.emit),
    ("stats", putStrLn . show . St.emit),
    ("ast", putStrLn . show)]

main :: IO ()
main = do args <- getArgs
          if null args
            then die "No command specified."
            else do input <- hGetContents stdin
                    case readView "RestyScript" input of
                        Left err -> die (show err)
                        Right ast -> processArgs args ast

processArgs :: [String] -> SqlVal -> IO ()
processArgs [] _ = return ()
processArgs (a:as) ast =
    case lookup a argHandles of
        Just hdl -> hdl ast >> processArgs as ast
        Nothing -> die $ "Unknown command: " ++ a

die :: String -> IO ()
die msg = do hPutStrLn stderr msg
             exitWith $ ExitFailure 1

