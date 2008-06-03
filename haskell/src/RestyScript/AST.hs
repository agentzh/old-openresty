module RestyScript.AST (
    RSVal(..),
    traverse
) where

import Text.ParserCombinators.Parsec.Pos (SourcePos)

data RSVal = SetOp !String RSVal RSVal
            | Query [RSVal]
            | Select [RSVal]
            | From [RSVal]
            | Where RSVal
            | Limit RSVal
            | Offset RSVal
            | TypeCast RSVal RSVal
            | OrderBy [RSVal]
            | OrderPair RSVal !String
            | GroupBy RSVal
            | Alias RSVal RSVal
            | Column RSVal
            | Model RSVal
            | Symbol !String
            | QualifiedColumn RSVal RSVal
            | Integer !Int
            | Float !Double
            | String !String
            | Variable SourcePos !String
            | FuncCall RSVal [RSVal]
            | Compare !String RSVal RSVal
            | Arith !String RSVal RSVal
            | Minus RSVal
            | Plus RSVal
            | Not RSVal
            | Or RSVal RSVal
            | And RSVal RSVal
            | Null
            | AnyColumn
                deriving (Ord, Eq, Show)

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

