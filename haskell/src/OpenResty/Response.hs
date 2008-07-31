module OpenResty.Response (
    emitError
) where

import Text.JSON
import Network.CGI

emitError :: String -> CGI CGIResult
emitError msg = output $
    "{\"success\":false,\"error\":" ++
    (encode msg) ++ "}\n"

