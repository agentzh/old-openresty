module RestyScript.Emitter.RestyScript where

import RestyScript.AST
import RestyScript.Util

import Data.List (intercalate)
import Text.Printf (printf)

emitForList ls = intercalate ", " $ map emit ls

emit :: SqlVal -> String
emit node = case node of
    TypeCast e t -> (emit e) ++ "::" ++ (emit t)
    SetOp op lhs rhs -> "((" ++ (emit lhs) ++ ") " ++ op ++
                        " (" ++ (emit rhs) ++ "))"
    Query lst -> unwords $ map emit lst
    String s -> quoteLiteral s
    Variable _ v -> '$' : v
    FuncCall f args -> (emit f) ++
                                  "(" ++ (emitForList args) ++ ")"
    QualifiedColumn model col -> (emit model) ++ "." ++ (emit col)

    Select cols -> "select " ++ (emitForList cols)
    From models -> "from " ++ (emitForList models)
    Where cond -> "where " ++ (emit cond)
    OrderBy pairs -> "order by " ++ (emitForList pairs)
    GroupBy col -> "group by " ++ emit col
    Limit lim -> "limit " ++ emit lim
    Offset offset -> "offset " ++ emit offset

    OrderPair col dir -> (emit col) ++ " " ++ dir
    Model model -> emit model
    Column col -> emit col
    Symbol name -> quoteIdent name
    Integer int -> show int
    Float float -> printf "%0f" float
    Or a b -> "(" ++ (emit a) ++ " or " ++  (emit b) ++ ")"
    And a b -> "(" ++ (emit a) ++ " and " ++ (emit b) ++ ")"
    Compare op lhs rhs -> (emit lhs) ++ " " ++ op ++ " " ++ (emit rhs)
    Arith op lhs rhs -> "(" ++ (emit lhs) ++ " " ++ op ++ " " ++ (emit rhs) ++ ")"
    Alias col alias -> (emit col) ++ " as " ++ (emit alias)
    Null -> ""
    AnyColumn -> "*"

