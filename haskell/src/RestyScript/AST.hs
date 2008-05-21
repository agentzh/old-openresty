module RestyScript.AST (
    SqlVal(..),
    traverse,
    Visit
) where

import Text.ParserCombinators.Parsec.Pos (SourcePos)

data SqlVal = SetOp String SqlVal SqlVal
            | Query [SqlVal]
            | Select [SqlVal]
            | From [SqlVal]
            | Where SqlVal
            | Limit SqlVal
            | Offset SqlVal
            | TypeCast SqlVal SqlVal
            | OrderBy [SqlVal]
            | OrderPair SqlVal String
            | GroupBy SqlVal
            | Alias SqlVal SqlVal
            | Column SqlVal
            | Model SqlVal
            | Symbol String
            | QualifiedColumn SqlVal SqlVal
            | Integer Int
            | Float Double
            | String String
            | Variable SourcePos String
            | FuncCall SqlVal [SqlVal]
            | Compare String SqlVal SqlVal
            | Arith String SqlVal SqlVal
            | Or SqlVal SqlVal
            | And SqlVal SqlVal
            | Null
            | AnyColumn
                deriving (Ord, Eq, Show)

class Visit a where

traverse :: (Visit a) => (SqlVal->a) -> (a->a->a) -> SqlVal -> a
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
        FuncCall _ args -> mergeAll $ cur : map self args
        Compare _ lhs rhs -> mergeAll [cur, self lhs, self rhs]
        Arith _ lhs rhs -> mergeAll [cur, self lhs, self rhs]
        Or lhs rhs -> mergeAll [cur, self lhs, self rhs]
        And lhs rhs -> mergeAll [cur, self lhs, self rhs]
        otherwise -> cur

