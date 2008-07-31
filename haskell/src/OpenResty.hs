{-# OPTIONS_GHC -XOverloadedStrings -funbox-strict-fields #-}
module Main where

import Network.FastCGI
import Control.Exception

import System.IO
import Database.HSQL
import Database.HSQL.PostgreSQL (connect)
import Text.JSON
import qualified OpenResty.Request as Req
import qualified OpenResty.Response as Res
import Debug.Trace (trace)
import Data.Dynamic
import Control.Monad.Trans
import qualified Data.ByteString.Char8 as B

main :: IO ()
main = do
    catchDyn initServer processInitError

initServer :: IO ()
initServer = do
    cnn <- (connect "localhost" "test" "agentzh" "agentzh")
    runServer cnn

runServer :: Connection -> IO ()
runServer = runFastCGI . handleErrors . processRequest

processRequest :: Connection -> CGI CGIResult
processRequest cnn = do
    catchCGI (Req.parseCGIEnv >>= output . (++"\n") . encode) handler
        where handler :: Exception -> CGI CGIResult
              handler error@(DynException dyn) = Res.emitError (trace ("Exception: " ++ e) e)
                    where e = case fromDynamic dyn of
                            Just v -> show (v :: Req.RestyError)
                            Nothing -> show error
              handler v = output $ show v ++ "\n"
    --processRequest cnn = output $ trace "Showing hi" (show "hi")

processInitError :: SqlError -> IO ()
processInitError = runFastCGI . Res.emitError . show

