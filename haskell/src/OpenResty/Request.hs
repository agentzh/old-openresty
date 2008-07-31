{-# OPTIONS_GHC -XOverloadedStrings -funbox-strict-fields -XDeriveDataTypeable #-}

module OpenResty.Request (
    parseCGIEnv, Request(..), DataFormat(..), RestyError(..)
) where

import Network.FastCGI
import qualified Data.ByteString.Lazy.Char8 as BL
import qualified Data.ByteString.Char8 as B
import Network.URI (unEscapeString, uriPath)
import Data.List (stripPrefix)
import Data.Char (toLower)
import Text.Regex.PCRE.Light
import Control.Exception
import Debug.Trace (trace)
import Data.Typeable
import Text.JSON
import Safe

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

instance JSON Request where
    showJSON req =
        JSObject $ toJSObject [
            ("category", showJSON $ B.unpack $ category req),
            ("method", showJSON $ B.unpack $ method req),
            ("content", showJSON $ BL.unpack $ content req),
            ("format", showJSON $ format req),
            ("pathBits", showList $ pathBits req),
            ("params", showList' $ params req)]
        where showList = JSArray . map (showJSON . B.unpack)
              showList' = JSArray . map (showJSON . pair2str)
              pair2str p = JSArray $ map showJSON [fst p, BL.unpack $ snd p]
    readJSON = undefined

instance JSON DataFormat where
    showJSON DFYaml = JSString $ toJSString "yaml"
    showJSON DFJson = JSString $ toJSString "json"
    readJSON = undefined

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
        category = unescape cat,
        method = meth,
        content = if (meth == "PUT" || meth == "POST") && body == ""
                    then maybe "" id dataParam
                    else body,
        format = maybe DFJson id $ lookup (lc fmt) toDataFormat,
        pathBits = map unescape pbits,
        -- pathBits = map (B.pack . unEscapeString . B.unpack) $ B.split '/' pbits,
        params = inputs
    }

unescape :: B.ByteString -> B.ByteString
unescape = B.pack . unEscapeString . B.unpack

lc :: B.ByteString -> B.ByteString
lc = B.map toLower

parsePath :: B.ByteString -> CGI (B.ByteString, B.ByteString, [B.ByteString], B.ByteString)
parsePath path = if B.isPrefixOf "/=/" path
    then splitPath $ B.drop 3 path
    else throwDyn $ URIError "URL must be preceded by \"/=/\"."

splitPath :: B.ByteString -> CGI (B.ByteString, B.ByteString, [B.ByteString], B.ByteString)
splitPath p = case B.span (/='/') p of
    ("put", s)    -> fmap (prepend "PUT") $ splitBarePath $ B.tail s
    ("post", s)   -> fmap (prepend "POST") $ splitBarePath $ B.tail s
    ("delete", s) -> fmap (prepend "DELETE") $ splitBarePath $ B.tail s
    ("", "")      -> return ("version", "", [], "json")
    _             -> fmap (prepend "") $ splitBarePath p
    where prepend d (a, b, c) = (d, a, b, c)

splitBarePath :: B.ByteString -> CGI (B.ByteString, [B.ByteString], B.ByteString)
splitBarePath p = if null bits
        then return ("version", [], "json")
        else return (head bits, (init bits) ++ [mid], fmt)
    where bits = B.split '/' p
          (mid, fmt) = processSuffix (last bits)

processSuffix :: B.ByteString -> (B.ByteString, B.ByteString)
processSuffix str =
    let regex = compile "(.*?)\\.(json|js|yaml|yml)$" [] in
        case match regex str [] of
            Just res -> (res !! 1, res !! 2)
            Nothing  -> (str, "json")

--dropUtil :: (Char -> Bool) -> B.ByteString
--dropUtil = B.tail . B.dropWhile

