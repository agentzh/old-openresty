module RestyScript.AST (
    RSVal(..), traverse
) where

import Text.ParserCombinators.Parsec.Pos (SourcePos)

-- RestyScript AST datatype
data RSVal = SetOp !String !RSVal !RSVal
           | Query ![RSVal]
           | Select ![RSVal] -- Select entries
           | From ![RSVal]
           | Where !RSVal
           | Limit !RSVal
           | Offset !RSVal
           | TypeCast !RSVal !RSVal
           | OrderBy ![RSVal]
           | OrderPair !RSVal !String
           | GroupBy !RSVal
           | Alias !RSVal !RSVal
           | Column !RSVal
           | Model !RSVal
           | Symbol !String
           | QualifiedColumn !RSVal !RSVal
           | Integer !Int
           | Float !Double
           | String !String
           | Variable !SourcePos !String
           | FuncCall !RSVal ![RSVal]
           | Compare !String !RSVal !RSVal
           | Arith !String !RSVal !RSVal
           | Minus !RSVal
           | Plus !RSVal
           | Not !RSVal
           | Or !RSVal !RSVal
           | And !RSVal !RSVal
           | Null
           | AnyColumn
           | Action ![RSVal]
           | Delete !RSVal !RSVal -- Delete model cond
           | Update !RSVal !RSVal !RSVal -- Update model assign cond
           | Assign !RSVal !RSVal -- Assign col expr
           | HttpCmd !String !RSVal !RSVal -- HttpCmd method url content
           | Object ![RSVal]  -- Object [pair]
           | Pair !RSVal !RSVal -- Pair key value
           | Array ![RSVal]  -- Array [elem]
           | Concat !RSVal !RSVal
           | Distinct ![RSVal]
           | All ![RSVal]
               deriving (Eq, Show)

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

        Minus val -> mergeAll [cur, self val]
        Plus val -> mergeAll [cur, self val]
        Not val -> mergeAll [cur, self val]

        Action cmds -> mergeAll $ cur : map self cmds
        Delete model cond -> mergeAll [cur, self model, self cond]
        Update model assign cond -> mergeAll [cur, self model, self assign, self cond]
        Assign col expr -> mergeAll [cur, self col, self expr]
        HttpCmd meth url content -> mergeAll [cur, self url, self content]
        Object ps -> mergeAll $ cur : map self ps
        Array xs -> mergeAll $ cur : map self xs
        Pair k v -> mergeAll [cur, self k, self v]
        Concat a b -> mergeAll [cur, self a, self b]
        AnyColumn -> cur
        Null -> cur
        String _ -> cur
        Float _ -> cur
        Integer _ -> cur
        Symbol _ -> cur
        All _ -> cur
        Distinct _ -> cur
        -- otherwise -> cur

