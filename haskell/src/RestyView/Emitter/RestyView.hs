module RestyView.Emitter.RestyView where

import RestyView.AST
import RestyView.Util

import Text.Printf (printf)
import qualified Data.ByteString.Char8 as B

emitForList :: [SqlVal] -> B.ByteString
emitForList ls = B.intercalate (B.pack ", ") $ map emit ls

emit :: SqlVal -> B.ByteString
emit node = case node of
    TypeCast e t -> B.concat [emit e, "::", emit t]
    SetOp op lhs rhs -> B.concat ["((", emit lhs, ") ", bs op,
                        " (", emit rhs, "))"]
    Query lst -> B.unwords $ map emit lst
    String s -> bs $ quoteLiteral s
    Variable _ v -> '$' `B.cons` (bs v)
    FuncCall f args -> B.concat [emit f,
                                  "(", emitForList args, ")"]
    QualifiedColumn model col -> B.concat [emit model, ".", emit col]

    Select cols -> B.concat ["select ", emitForList cols]
    From models -> B.concat ["from ", emitForList models]
    Where cond -> B.concat ["where ", emit cond]
    OrderBy pairs -> B.concat ["order by ", emitForList pairs]
    GroupBy col -> B.concat ["group by ", emit col]
    Limit lim -> B.concat ["limit ", emit lim]
    Offset offset -> B.concat ["offset ", emit offset]

    OrderPair col dir -> B.concat [emit col, " ", bs dir]
    Model model -> emit model
    Column col -> emit col
    Symbol name -> bs $ quoteIdent name
    Integer int -> bs $ show int
    Float float -> bs $ printf "%0f" float
    Or a b -> B.concat ["(", emit a, " or ", emit b, ")"]
    And a b -> B.concat ["(", emit a, " and ", emit b, ")"]
    Compare op lhs rhs -> B.concat [emit lhs, " ", bs op, " ", emit rhs]
    Arith op lhs rhs -> B.concat ["(", emit lhs, " ", bs op, " ", emit rhs, ")"]

    Minus val@(Integer _) -> B.append "-" $ emit val
    Minus val@(Float _) -> B.append "-" $ emit val
    Minus val -> B.concat ["(-", emit val, ")"]
    Plus val -> emit val
    Not val -> B.concat ["(not ", emit val, ")"]

    Alias col alias -> B.concat [emit col, " as ", emit alias]
    Null -> B.empty
    AnyColumn -> "*"
    where bs = B.pack

