module Main where

import RestyView.Parser
import RestyView.AST

import qualified RestyView.Emitter.RestyView as RS
import qualified RestyView.Emitter.Stats as St
import qualified RestyView.Emitter.RenameVar as Re
import qualified RestyView.Emitter.Fragments as Fr

import System
import System.IO
import System.Exit
import qualified Data.ByteString.Char8 as B

argHandles :: [(String, SqlVal -> IO ())]
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

processArgs :: [String] -> String -> SqlVal -> IO ()
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

