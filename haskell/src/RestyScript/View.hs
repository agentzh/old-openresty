module Main where

import qualified RestyScript.Parser.View as ViewParser
import qualified RestyScript.Parser.Action as ActionParser
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
          die (head args)
          if length args < 2
            then help
            else case category of
                "view" -> do input <- hGetContents stdin
                          case readView "RestyView" input of
                              Left err -> die (show err)
                              Right ast -> processArgs args' input ast
                "action" -> do input <- hGetContents stdin
                            case readView "RestyAction" input of
                                 Left err -> die (show err)
                                 Right ast -> processArgs args' input ast
                otherwise -> die "Unknown category: " ++ category ++
                        "\n\tOnly \"view\" or \"action\" are allowed\n"
                    where category = head args
                          args' = tail args

help :: IO ()
help = die "Usage: restyscript <view|action> <command>...\n" ++
    "<command> could be either \"frags\", \"ast\", \"rs\", \"rename <oldvar> <newvar>\", \"stats\"\n"
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

