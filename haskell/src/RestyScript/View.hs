module Main where

import RestyScript.Parser.View
import RestyScript.AST

import qualified RestyScript.Emitter.RestyScript as RS
import qualified RestyScript.Emitter.Stats as St
import qualified RestyScript.Emitter.RenameVar as Re
import qualified RestyScript.Emitter.Fragments as Fr

import System
import System.IO
import System.Exit
import qualified Data.ByteString.Char8 as B

argHandles :: [(String, RSVal -> IO ())]
argHandles = [
    ("rs", B.putStrLn . RS.emit),
    ("stats", putStrLn . St.emitJSON),
    ("ast", putStrLn . show),
    ("frags", putStrLn . Fr.emitJSON)]

main :: IO ()
main = do args <- getArgs
          if null args
            then die "No command specified."
            else do input <- hGetContents stdin
                    case readView "RestyView" input of
                        Left err -> die (show err)
                        Right ast -> processArgs args input ast

processArgs :: [String] -> String -> RSVal -> IO ()
processArgs [] _ _ = return ()
processArgs (a:as) input ast =
    if a == "rename"
        then case as of
            old : new : as' -> do putStrLn $ Re.emit ast input old new
                                  processArgs as' input ast
            _ -> die "The \"rename\" command requires two arguments."
        else case lookup a argHandles of
                    Just hdl -> hdl ast >> processArgs as input ast
                    Nothing -> die $ "Unknown command: " ++ a

die :: String -> IO ()
die msg = do hPutStrLn stderr msg
             exitWith $ ExitFailure 1

