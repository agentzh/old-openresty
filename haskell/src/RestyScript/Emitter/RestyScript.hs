{-# OPTIONS_GHC -XOverloadedStrings #-}

module RestyScript.Emitter.RestyScript where

import RestyScript.AST
import RestyScript.Util

import Text.Printf (printf)
import qualified Data.ByteString.Char8 as B

join :: B.ByteString -> [RSVal] -> B.ByteString
join sep ls = B.intercalate sep $ map emit ls

(~~) = B.append

emit :: RSVal -> B.ByteString
emit node = case node of
    TypeCast e t -> emit e ~~ "::" ~~ emit t
    SetOp op lhs rhs -> "((" ~~ emit lhs ~~ ") " ~~  bs op ~~
                        " (" ~~ emit rhs ~~ "))"
    Query lst -> B.unwords $ map emit lst
    String s -> bs $ quoteLiteral s
    Variable _ v -> "$" ~~ (bs v)
    FuncCall f args -> emit f ~~ "(" ~~ join ", " args ~~ ")"
    QualifiedColumn model col -> emit model ~~ "." ~~ emit col

    Select cols -> "select " ~~ join ", " cols
    From models -> "from " ~~ join ", " models
    Where cond -> "where " ~~ emit cond
    OrderBy pairs -> "order by " ~~ join ", " pairs
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

    Minus val -> "(-" ~~ emit val ~~ ")"
    Plus val -> emit val
    Not val -> "(not " ~~ emit val ~~ ")"

    Alias col alias -> emit col ~~ " as " ~~ emit alias
    Empty -> B.empty
    Null -> "null"
    AnyColumn -> "*"
    Action cmds -> join ";\n" cmds
    Delete model cond -> "delete from " ~~ emit model ~~ " " ~~ emit cond
    Update model assign cond -> "update " ~~ emit model ~~ " set " ~~ emit assign ~~ " " ~~ emit cond
    Assign col expr -> emit col ~~ " = " ~~ emit expr
    HttpCmd meth url content -> bs meth ~~ " " ~~ emit url ~~ " " ~~ emit content
    Object ps -> "{" ~~ join ", " ps  ~~ "}"
    Array xs -> "[" ~~ join ", " xs  ~~ "]"
    Pair k v -> emit k ~~ ": " ~~ emit v
    Concat a b -> "(" ~~ emit a ~~ " || " ~~ emit b ~~ ")"

    Distinct ls -> "distinct " ~~ join ", " ls
    All ls -> "all " ~~ join ", " ls
    RSTrue -> "true"
    RSFalse -> "false"
    where bs = B.pack

