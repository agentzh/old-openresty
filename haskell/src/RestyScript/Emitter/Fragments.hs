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
    showJSON VTSymbol = showJSON "symbol"
    showJSON VTLiteral = showJSON "literal"
    showJSON VTUnknown = showJSON "unknown"
    readJSON = undefined

data Fragment = FVariable String VarType | FString B.ByteString
    deriving (Ord, Eq, Show)

instance JSON Fragment where
    showJSON (FString s) = showJSON s
    showJSON (FVariable v t) = JSArray [showJSON v, showJSON t]
    readJSON = undefined

bs :: String -> B.ByteString
bs = B.pack

emit :: SqlVal -> [Fragment]
emit node =
    case node of
        TypeCast (Variable _ v1) (Variable _ v2) -> [FVariable v1 VTUnknown, FString $ bs "::", FVariable v2 VTSymbol]
        TypeCast (Variable _ v1) t -> merge [FVariable v1 VTUnknown, FString $ bs "::"] $ emit t
        TypeCast e (Variable _ v2) -> merge (emit e) [FString $ bs "::", FVariable v2 VTSymbol]
        TypeCast e t -> join "::" $ [emit e, emit t]

        SetOp op lhs rhs -> mergeAll [
            str "((", emit lhs, str $ ") " ++ op ++ " (",
            emit rhs, str "))"]
        Query lst -> join " " $ map emit lst
        String s -> str $ quoteLiteral s

        Model (Variable _ v) -> [FVariable v VTSymbol]
        Model m -> emit m

        Column (Variable _ v) -> [FVariable v VTSymbol]
        Column col -> emit col

        Variable _ v -> [FVariable v VTUnknown]
        Alias e (Variable _ v) -> merge (emit e) [FString $ bs " as ", FVariable v VTSymbol]

        QualifiedColumn (Variable _ v1) (Variable _ v2) -> [FVariable v1 VTSymbol, FString $ bs ".", FVariable v2 VTSymbol]
        QualifiedColumn (Variable _ v) c -> merge [FVariable v VTSymbol, FString $ bs "."] (emit c)
        QualifiedColumn m (Variable _ v) -> merge (emit m) [FString $ bs ".", FVariable v VTSymbol]

        FuncCall (Variable _ v) args -> mergeAll $ [[FVariable v VTSymbol, FString $ bs "("], emitForList args, str ")"]
        FuncCall f args -> mergeAll $ [emit f, str "(", emitForList args, str ")"]
        QualifiedColumn model col -> mergeAll [emit model, str ".", emit col]
        Select cols -> mergeAll $ [str "select ", emitForList cols]
        From models -> mergeAll $ [str "from ", emitForList models]
        Where cond -> mergeAll $ [str "where ", emit cond]
        OrderBy pairs -> mergeAll $ [str "order by ", emitForList pairs]
        Symbol name -> str $ quoteIdent name

        GroupBy (Variable _ v) -> [FString $ bs "group by ", FVariable v VTSymbol]
        GroupBy col -> merge (str "group by ") (emit col)

        Limit (Variable _ v) -> [FString $ bs "limit ", FVariable v VTLiteral]
        Limit lim -> merge (str "limit ") (emit lim)

        Offset (Variable _ v) -> [FString $ bs "offset ", FVariable v VTLiteral]
        Offset offset -> merge (str "offset ") (emit offset)

        Alias col alias -> mergeAll [emit col, str " as ", emit alias]
        AnyColumn -> str "*"
        OrderPair col dir -> mergeAll [emit col, str (" " ++ dir)]
        Integer int -> str $ show int
        Float float -> str $ printf "%0f" float
        Or a b -> mergeAll [str "(", emit a, str " or ", emit b, str ")"]
        And a b -> mergeAll [str "(", emit a, str " and ", emit b, str ")"]
        Compare op lhs rhs -> mergeAll [emit lhs, str $ " " ++ op ++ " ", emit rhs]
        Arith op lhs rhs -> mergeAll [str "(", emit lhs, str $ " " ++ op ++ " ", emit rhs, str ")"]
        Null -> str ""
    where str s = [FString $ bs s]
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

