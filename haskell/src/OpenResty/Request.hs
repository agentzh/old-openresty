{-# OPTIONS_GHC -XOverloadedStrings -funbox-strict-fields -XDeriveDataTypeable #-}

module OpenResty.Request (
    parseCGIEnv, Request(..), DataFormat(..), RestyError(..)
) where

import Network.FastCGI
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.ByteString.Char8 as B
import Network.URI
import Data.List (stripPrefix)
import Data.Char (toLower)
import Text.Regex.PCRE.Light
import Control.Exception
import Debug.Trace (trace)
import Data.Typeable

data RestyError = URIError B.ByteString
                | MiscError B.ByteString
                | UnknownError B.ByteString
  deriving (Typeable)

instance Show RestyError where
    show (URIError s) = show s
    show (MiscError s) = show s
    show _ = "Unknown error"

data DataFormat = DFJson | DFYaml
    deriving (Show)

toDataFormat = [
    ("json",DFJson),
    ("js",DFJson),
    ("yaml",DFYaml),
    ("yml",DFYaml)]

data Request = Request {
    category :: B.ByteString,
    method :: B.ByteString,
    content :: BL.ByteString,
    format :: DataFormat,
    pathBits :: [B.ByteString],
    params :: [(String, BL.ByteString)]
}
    deriving (Show)

parseCGIEnv :: CGI Request
parseCGIEnv = do
    uri <- requestURI
    inputs <- trace "getInputsFPS" getInputsFPS
    (prefix, cat, pbits, fmt) <- parsePath $ B.pack $ uriPath uri
    meth <- if prefix /= ""
        then (return prefix) else (fmap B.pack $ requestMethod)
    body <- getBodyFPS -- XXX TODO: check if body is too long
    dataParam <- getInputFPS "_data"
    return $ Request {
        category = cat,
        method = meth,
        content = if (meth == "PUT" || meth == "POST") && body == ""
                    then maybe "" id dataParam
                    else body,
        format = maybe DFJson id $ lookup (B.map toLower fmt) toDataFormat,
        pathBits = pbits,
        -- pathBits = map (B.pack . unEscapeString . B.unpack) $ B.split '/' pbits,
        params = inputs
    }

parsePath :: B.ByteString -> CGI (B.ByteString, B.ByteString, [B.ByteString], B.ByteString)
parsePath path = if B.isPrefixOf "/=/" path
    then splitPath $ B.drop 3 path
    else throwDyn $ URIError "URL must be preceded by \"/=/\"."

splitPath :: B.ByteString -> CGI (B.ByteString, B.ByteString, [B.ByteString], B.ByteString)
splitPath p = case B.span (/='/') p of
    ("put", s)    -> fmap (prepend "PUT") $ splitBarePath $ B.tail s
    ("post", s)   -> fmap (prepend "POST") $ splitBarePath $ B.tail s
    ("delete", s) -> fmap (prepend "DELETE") $ splitBarePath $ B.tail s
    _             -> fmap (prepend "") $ splitBarePath p
    where prepend d (a, b, c) = (d, a, b, c)

splitBarePath :: B.ByteString -> CGI (B.ByteString, [B.ByteString], B.ByteString)
splitBarePath = undefined

--dropUtil :: (Char -> Bool) -> B.ByteString
--dropUtil = B.tail . B.dropWhile

