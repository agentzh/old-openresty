{-# OPTIONS_GHC -XOverloadedStrings -funbox-strict-fields #-}
module Main where

import Network.FastCGI
import Control.Exception

import System.IO
import Database.HSQL
import Database.HSQL.PostgreSQL (connect)
import Text.JSON
import OpenResty.Request
import Debug.Trace (trace)
import Data.Dynamic
import Control.Monad.Trans
import qualified Data.ByteString.Char8 as B

main :: IO ()
main = catchDyn initServer processInitError

initServer :: IO ()
initServer = do
    cnn <- (connect "localhost" "test" "agentzh" "agentzh")
    runServer cnn

runServer :: Connection -> IO ()
runServer = runFastCGI . processRequest

processRequest :: Connection -> CGI CGIResult
processRequest cnn = do
    catchCGI (parseCGIEnv >>= output . (++"\n") . encode) handler
        where handler :: Exception -> CGI CGIResult
              handler (DynException dyn) = output $ "Hello: " ++ (show $ e) ++ "\n"
                    where e = case fromDynamic dyn of
                            Just v -> v
                            Nothing -> UnknownError ""
              handler v = output $ show v ++ "\n"
    --processRequest cnn = output $ trace "Showing hi" (show "hi")

processInitError :: RestyError -> IO ()
processInitError e = runFastCGI . output $
    "{\"success\":false,\"error\":" ++
    (encode $ show e) ++ "}\n"

