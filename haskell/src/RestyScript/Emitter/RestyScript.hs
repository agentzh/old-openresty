{-# OPTIONS_GHC -XOverloadedStrings #-}

module RestyScript.Emitter.RestyScript where

import RestyScript.AST
import RestyScript.Util

import Text.Printf (printf)
import qualified Data.ByteString.Char8 as B

emitForList :: [RSVal] -> B.ByteString
emitForList ls = B.intercalate (B.pack ", ") $ map emit ls

(~~) = B.append

emit :: RSVal -> B.ByteString
emit node = case node of
    TypeCast e t -> emit e ~~ "::" ~~ emit t
    SetOp op lhs rhs -> "((" ~~ emit lhs ~~ ") " ~~  bs op ~~
                        " (" ~~ emit rhs ~~ "))"
    Query lst -> B.unwords $ map emit lst
    String s -> bs $ quoteLiteral s
    Variable _ v -> "$" ~~ (bs v)
    FuncCall f args -> emit f ~~ "(" ~~ emitForList args ~~ ")"
    QualifiedColumn model col -> emit model ~~ "." ~~ emit col

    Select cols -> "select " ~~ emitForList cols
    From models -> "from " ~~ emitForList models
    Where cond -> "where " ~~ emit cond
    OrderBy pairs -> "order by " ~~ emitForList pairs
    GroupBy col -> "group by " ~~ emit col
    Limit lim -> "limit " ~~ emit lim
    Offset offset -> "offset " ~~ emit offset

    OrderPair col dir -> emit col ~~ " " ~~ bs dir
    Model model -> emit model
    Column col -> emit col
    Symbol name -> bs $ quoteIdent name
    Integer int -> bs $ show int
    Float float -> bs $ printf "%0f" float
    Or a b -> "(" ~~ emit a ~~ " or " ~~ emit b ~~ ")"
    And a b -> "(" ~~ emit a ~~ " and " ~~ emit b ~~ ")"
    Compare op lhs rhs -> emit lhs ~~ " " ~~ bs op ~~ " " ~~ emit rhs
    Arith op lhs rhs -> "(" ~~ emit lhs ~~ " " ~~ bs op ~~ " " ~~ emit rhs ~~ ")"

    Minus val -> B.concat ["(-", emit val, ")"]
    Plus val -> emit val
    Not val -> B.concat ["(not ", emit val, ")"]

    Alias col alias -> B.concat [emit col, " as ", emit alias]
    Null -> B.empty
    AnyColumn -> "*"
    _ -> ""
    where bs = B.pack

