module RestyScript.Emitter.RestyScript where

import RestyScript.AST
import RestyScript.Util

import Text.Printf (printf)
import qualified Data.ByteString.Char8 as B

emitForList :: [SqlVal] -> B.ByteString
emitForList ls = B.intercalate (B.pack ", ") $ map emit ls

emit :: SqlVal -> B.ByteString
emit node = case node of
    TypeCast e t -> B.concat [emit e, bs "::", emit t]
    SetOp op lhs rhs -> B.concat [bs "((", emit lhs, bs ") ", bs op,
                        bs " (", emit rhs, bs "))"]
    Query lst -> B.unwords $ map emit lst
    String s -> bs $ quoteLiteral s
    Variable _ v -> '$' `B.cons` (bs v)
    FuncCall f args -> B.concat [emit f,
                                  bs "(", emitForList args, bs ")"]
    QualifiedColumn model col -> B.concat [emit model, bs ".", emit col]

    Select cols -> B.concat [bs "select ", emitForList cols]
    From models -> B.concat [bs "from ", emitForList models]
    Where cond -> B.concat [bs "where ", emit cond]
    OrderBy pairs -> B.concat [bs "order by ", emitForList pairs]
    GroupBy col -> B.concat [bs "group by ", emit col]
    Limit lim -> B.concat [bs "limit ", emit lim]
    Offset offset -> B.concat [bs "offset ", emit offset]

    OrderPair col dir -> B.concat [emit col, bs " ", bs dir]
    Model model -> emit model
    Column col -> emit col
    Symbol name -> bs $ quoteIdent name
    Integer int -> bs $ show int
    Float float -> bs $ printf "%0f" float
    Or a b -> B.concat [bs "(", emit a, bs " or ", emit b, bs ")"]
    And a b -> B.concat [bs "(", emit a, bs " and ", emit b, bs ")"]
    Compare op lhs rhs -> B.concat [emit lhs, bs " ", bs op, bs " ", emit rhs]
    Arith op lhs rhs -> B.concat [bs "(", emit lhs, bs " ", bs op, bs " ", emit rhs, bs ")"]
    Alias col alias -> B.concat [emit col, bs " as ", emit alias]
    Null -> B.empty
    AnyColumn -> bs "*"
    where bs = B.pack

