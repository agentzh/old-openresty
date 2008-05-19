module RestyScript.AST (
    SqlVal(..)
) where

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
            | Term SqlVal
            | Column SqlVal
            | Model SqlVal
            | Symbol String
            | QualifiedColumn SqlVal SqlVal
            | Integer Integer
            | Float Double
            | String String
            | Variable String
            | FuncCall String [SqlVal]
            | Compare String SqlVal SqlVal
            | Arith String SqlVal SqlVal
            | Or SqlVal SqlVal
            | And SqlVal SqlVal
            | Null
            | AnyColumn
                deriving (Ord, Eq, Show)

