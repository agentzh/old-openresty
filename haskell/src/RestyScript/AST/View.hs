module RestyScript.AST.View (
    RSVal(..), traverse
) where

import RestyScript.AST

traverse :: (RSVal->a) -> (a->a->a) -> RSVal -> a
traverse visit merge node =
    let mergeAll = foldl1 merge
        cur = visit node
        self = traverse visit merge
    in case node of
        SetOp _ lhs rhs -> mergeAll [cur, self lhs, self rhs]
        Query q -> mergeAll $ cur : map self q
        Select s -> mergeAll $ cur : map self s
        From f -> mergeAll $ cur : map self f
        Where w -> merge cur $ self w
        Limit l -> merge cur $ self l
        Offset o -> merge cur $ self o
        TypeCast e t -> mergeAll [cur, self e, self t]
        OrderBy o -> mergeAll $ cur : map self o
        OrderPair col _ -> merge cur (self col)
        GroupBy g -> merge cur (self g)
        Alias col alias -> mergeAll [cur, self col, self alias]
        Column c -> merge cur (self c)
        Model m -> merge cur (self m)
        QualifiedColumn lhs rhs -> mergeAll [cur, self lhs, self rhs]
        Variable _ _ -> visit node
        FuncCall f args -> mergeAll $ cur : map self (f:args)
        Compare _ lhs rhs -> mergeAll [cur, self lhs, self rhs]
        Arith _ lhs rhs -> mergeAll [cur, self lhs, self rhs]
        Or lhs rhs -> mergeAll [cur, self lhs, self rhs]
        And lhs rhs -> mergeAll [cur, self lhs, self rhs]
        otherwise -> cur

