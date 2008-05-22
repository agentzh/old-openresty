module RestyScript.Emitter.Fragments (
    Fragment,
    VarType,
    emit,
    emitJSON
) where

import RestyScript.Util
import RestyScript.AST

import Data.List (intersperse)
import Text.Printf (printf)
import Text.JSON
import qualified Data.ByteString.Char8 as B

data VarType = VTLiteral | VTSymbol | VTUnknown
    deriving (Ord, Eq, Show)

instance JSON VarType where
    showJSON VTSymbol = showJSON $ B.unpack "symbol"
    showJSON VTLiteral = showJSON $ B.unpack "literal"
    showJSON VTUnknown = showJSON $ B.unpack "unknown"
    readJSON = undefined

data Fragment = FVariable String VarType | FString B.ByteString
    deriving (Ord, Eq, Show)

instance JSON Fragment where
    showJSON (FString s) = showJSON $ B.unpack s
    showJSON (FVariable v t) = JSArray [showJSON v, showJSON t]
    readJSON = undefined

bs :: String -> B.ByteString
bs = B.pack

emit :: SqlVal -> [Fragment]
emit node =
    case node of
        TypeCast (Variable _ v1) (Variable _ v2) -> [FVariable v1 VTUnknown, FString $ "::", FVariable v2 VTSymbol]
        TypeCast (Variable _ v1) t -> merge [FVariable v1 VTUnknown, FString $ "::"] $ emit t
        TypeCast e (Variable _ v2) -> merge (emit e) [FString $ "::", FVariable v2 VTSymbol]
        TypeCast e t -> join "::" $ [emit e, emit t]

        SetOp op lhs rhs -> mergeAll [
            str "((", emit lhs, str $ B.concat [") ", bs op, " ("],
            emit rhs, str "))"]
        Query lst -> join " " $ map emit lst
        String s -> str $ bs $ quoteLiteral s

        Model (Variable _ v) -> [FVariable v VTSymbol]
        Model m -> emit m

        Column (Variable _ v) -> [FVariable v VTSymbol]
        Column col -> emit col

        Variable _ v -> [FVariable v VTUnknown]
        Alias e (Variable _ v) -> merge (emit e) [FString $ " as ", FVariable v VTSymbol]

        QualifiedColumn (Variable _ v1) (Variable _ v2) -> [FVariable v1 VTSymbol, FString $ ".", FVariable v2 VTSymbol]
        QualifiedColumn (Variable _ v) c -> merge [FVariable v VTSymbol, FString $ "."] (emit c)
        QualifiedColumn m (Variable _ v) -> merge (emit m) [FString $ ".", FVariable v VTSymbol]

        FuncCall (Variable _ v) args -> mergeAll $ [[FVariable v VTSymbol, FString $ "("], emitForList args, str ")"]
        FuncCall f args -> mergeAll $ [emit f, str "(", emitForList args, str ")"]
        QualifiedColumn model col -> mergeAll [emit model, str ".", emit col]
        Select cols -> mergeAll $ [str "select ", emitForList cols]
        From models -> mergeAll $ [str "from ", emitForList models]
        Where cond -> mergeAll $ [str "where ", emit cond]
        OrderBy pairs -> mergeAll $ [str "order by ", emitForList pairs]
        Symbol name -> str $ bs $ quoteIdent name

        GroupBy (Variable _ v) -> [FString $ "group by ", FVariable v VTSymbol]
        GroupBy col -> merge (str "group by ") (emit col)

        Limit (Variable _ v) -> [FString $ "limit ", FVariable v VTLiteral]
        Limit lim -> merge (str "limit ") (emit lim)

        Offset (Variable _ v) -> [FString $ "offset ", FVariable v VTLiteral]
        Offset offset -> merge (str "offset ") (emit offset)

        Alias col alias -> mergeAll [emit col, str " as ", emit alias]
        AnyColumn -> str "*"
        OrderPair col dir -> mergeAll [emit col, str $ B.concat [" ", bs dir]]
        Integer int -> str $ bs $ show int
        Float float -> str $ bs $ printf "%0f" float
        Or a b -> mergeAll [str "(", emit a, str " or ", emit b, str ")"]
        And a b -> mergeAll [str "(", emit a, str " and ", emit b, str ")"]
        Compare op lhs rhs -> mergeAll [emit lhs, str $ B.concat [" ", bs op, " "], emit rhs]
        Arith op lhs rhs -> mergeAll [str "(", emit lhs, str $ B.concat [" ", bs op, " "], emit rhs, str ")"]
        Null -> str ""
    where str s = [FString s]
          emitForList ls = join ", " $ map emit ls

mergeAll :: [[Fragment]] -> [Fragment]
mergeAll [] = []
mergeAll ls = foldl1 merge ls

merge :: [Fragment] -> [Fragment] -> [Fragment]
merge [] b = b
merge a [] = a
merge a b = case (a !! (length a - 1), (head b)) of
    (FString u, FString v) -> (take (length a - 1) a) ++ [FString $ B.concat [u, v]] ++ tail b
    otherwise -> a ++ b

join :: String -> [[Fragment]] -> [Fragment]
join sep [] = []
join sep lst = mergeAll $ intersperse [FString $ bs sep] lst

emitJSON :: SqlVal -> String
emitJSON = encode . emit

