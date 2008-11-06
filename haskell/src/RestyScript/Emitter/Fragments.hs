{-# OPTIONS_GHC -XOverloadedStrings -funbox-strict-fields #-}

module RestyScript.Emitter.Fragments (
    Fragment, VarType, emit, emitJSON
) where

import RestyScript.Util
import RestyScript.AST

import Data.List (intersperse)
import Text.Printf (printf)
import Text.JSON
import qualified Data.ByteString.Char8 as B
import qualified RestyScript.Emitter.RestyScript as RS

infixr 6 <+>

data VarType = VTLiteral
             | VTSymbol
             | VTUnknown
             | VTQuoted
             | VTKeyword

instance JSON VarType where
    showJSON VTSymbol = showJSON ("symbol"::String)
    showJSON VTLiteral = showJSON ("literal"::String)
    showJSON VTUnknown = showJSON ("unknown"::String)
    showJSON VTQuoted = showJSON ("quoted"::String)
    showJSON VTKeyword = showJSON ("keyword"::String)
    readJSON = undefined

data Fragment = FVariable !String !VarType
              | FString !B.ByteString
              | FSql ![Fragment]
              | FHttpCmd !String ![Fragment] ![Fragment]
              | FNull

instance JSON Fragment where
    showJSON val = case val of
        FString s -> showJSON $ B.unpack s
        FVariable v t -> JSArray [showJSON v, showJSON t]
        FHttpCmd meth url [FNull] -> JSArray [showJSON meth, showJSON url]
        FHttpCmd meth url content -> JSArray [showJSON meth, showJSON url, showJSON content]
        FSql frags -> JSArray [JSArray $ map showJSON frags]
        FNull -> showJSON (""::String)
    readJSON = undefined

bs :: String -> B.ByteString
bs = B.pack

(~~) = B.append
(<+>) = merge

joinStr :: B.ByteString -> [B.ByteString] -> B.ByteString
joinStr sep ls = B.intercalate sep ls

emit :: RSVal -> [Fragment]
emit node =
    case node of
        TypeCast (Variable _ v1) (Variable _ v2) -> [FVariable v1 VTUnknown, FString $ "::", FVariable v2 VTSymbol]
        TypeCast (Variable _ v1) t -> [FVariable v1 VTUnknown, FString $ "::"] <+> emit t
        TypeCast e (Variable _ v2) -> merge (emit e) [FString $ "::", FVariable v2 VTSymbol]
        TypeCast e t -> join "::" $ [emit e, emit t]

        SetOp op lhs rhs ->
            str "((" <+> emit lhs <+> (str $ ") " ~~ bs op ~~ " (") <+>
            emit rhs <+> str "))"
        Query lst -> join " " $ map emit lst
        String s -> str $ bs $ quoteLiteral s

        Model (Variable _ v) -> [FVariable v VTSymbol]
        Model m -> emit m

        Column (Variable _ v) -> [FVariable v VTSymbol]
        Column col -> emit col

        Variable _ v -> [FVariable v VTUnknown]
        Alias e (Variable _ v) -> emit e <+> [FString $ " as ", FVariable v VTSymbol]

        QualifiedColumn (Variable _ v1) (Variable _ v2) -> [FVariable v1 VTSymbol, FString $ ".", FVariable v2 VTSymbol]
        QualifiedColumn (Variable _ v) c -> [FVariable v VTSymbol, FString $ "."] <+> emit c
        QualifiedColumn m (Variable _ v) -> emit m <+> [FString $ ".", FVariable v VTSymbol]

        FuncCall (Variable _ v) args -> [FVariable v VTSymbol, FString $ "("] <+> emitForList args <+> str ")"
        FuncCall f args -> emit f <+> str "(" <+> emitForList args <+> str ")"
        QualifiedColumn model col -> emit model <+> str "." <+> emit col
        Select cols -> str "select " <+> emitForList cols
        From models -> str "from " <+> emitForList models
        Where cond -> str "where " <+> emit cond
        OrderBy pairs -> str "order by " <+> emitForList pairs
        Symbol name -> str $ bs $ quoteIdent name
        Type name -> str $ bs name
        Keyword s -> str $ bs $ s

        GroupBy (Variable _ v) -> [FString $ "group by ", FVariable v VTSymbol]
        GroupBy col -> str "group by " <+> emit col

        Limit (Variable _ v) -> [FString $ "limit ", FVariable v VTLiteral]
        Limit lim -> str "limit " <+> emit lim

        Offset (Variable _ v) -> [FString $ "offset ", FVariable v VTLiteral]
        Offset offset -> str "offset " <+> emit offset

        Alias col alias -> emit col <+> str " as " <+> emit alias
        AnyColumn -> str "*"
        OrderPair col (Variable _ v) -> emit col <+> [FString " ", FVariable v VTKeyword]
        OrderPair col dir -> emit col <+> str " " <+> emit dir
        Integer int -> str $ bs $ show int
        Float float -> str $ bs $ printf "%0f" float
        Or a b -> str "(" <+> emit a <+> str " or " <+> emit b <+> str ")"
        And a b -> str "(" <+> emit a <+> str " and " <+> emit b <+> str ")"
        Compare op lhs rhs -> emit lhs <+> (str $ " " ~~ bs op ~~ " ") <+> emit rhs
        Arith op lhs rhs -> str "(" <+> emit lhs <+> (str $ " " ~~ bs op ~~ " ") <+> emit rhs <+> str ")"
        Minus val -> str "(-" <+> emit val <+> str ")"
        Plus val -> emit val
        Not val -> str "(not " <+> emit val <+> str ")"
        Empty -> str ""
        Null -> str "null"
        Action cmds -> map p cmds
            where p :: RSVal -> Fragment
                  p x = case x of
                    HttpCmd meth url Empty -> FHttpCmd meth (emitLit url) [FNull]
                    HttpCmd meth url content -> FHttpCmd meth (emitLit url) (emitForJSON True content)

                    otherwise -> FSql $ emit x
        Delete model cond -> str "delete from " <+> emit model <+> str " " <+> emit cond
        Update model assign cond -> str "update " <+> emit model <+> str " set " <+> emit assign <+> str " " <+> emit cond
        Assign col expr -> emit col <+> str " = " <+> emit expr
        Distinct ls -> str "distinct " <+> emitForList ls
        All ls -> str "all " <+> emitForList ls
        Pair k v -> str "\"" <+> emitLit k <+> str "\": " <+> emitForJSON True v
        Object ps -> str "{" <+> (join ", " $ map emit ps) <+> str "}"
        Array xs -> str "[" <+> (join ", " $ map (emitForJSON True) xs) <+> str "]"
        Concat a b -> emitLit a <+> emitLit b
        RSTrue -> str "true"
        RSFalse -> str "false"
        HttpCmd _ _ _ -> []  -- this shouldn't happen
        Capture _ -> str $ RS.emit node
        ArrayIndex array ind -> str "(" <+> emit array <+> str ")[" <+> emit ind <+> str "]"
    where emitForList ls = join ", " $ map emit ls

str :: B.ByteString -> [Fragment]
str s = [FString s]

emitForJSON :: Bool -> RSVal -> [Fragment]
emitForJSON toplevel n = case n of
    Variable _ v -> [FVariable v t]
        where t = if toplevel then VTLiteral else VTQuoted
    String s -> if toplevel then [FString $ bs $ quoteIdent s] else str $ bs s
    Concat a b -> if toplevel
                    then str "\"" <+> emitForJSON False a <+> emitForJSON False b <+> str "\""
                    else emitLit a <+> emitLit b
    otherwise -> emitLit n

emitLit :: RSVal -> [Fragment]
emitLit node = case node of
    Variable _ v -> [FVariable v VTQuoted]
    String s -> [FString $ bs s]
    otherwise -> emit node

merge :: [Fragment] -> [Fragment] -> [Fragment]
merge [] b = b
merge a [] = a
merge a b = case (a !! (length a - 1), (head b)) of
    (FString u, FString v) -> (take (length a - 1) a) ++ [FString $ B.concat [u, v]] ++ tail b
    otherwise -> a ++ b

join :: String -> [[Fragment]] -> [Fragment]
join sep [] = []
join sep lst = foldl1 merge $ intersperse [FString $ bs sep] lst

emitJSON :: RSVal -> String
emitJSON = encode . emit

