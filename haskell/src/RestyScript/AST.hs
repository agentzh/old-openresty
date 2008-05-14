module RestyScript.AST (
    SqlVal(..)
) where

data SqlVal = Select [SqlVal]
            | From [SqlVal]
            | Where SqlVal
            | Limit SqlVal
            | OrderBy [SqlVal]
            | OrderPair (SqlVal, String)
            | GroupBy SqlVal
            | Column SqlVal
            | Model SqlVal
            | Symbol String
            | QualifiedColumn (SqlVal, SqlVal)
            | Integer Integer
            | Float Double
            | String String
            | Variable (String)
            | FuncCall (String, [SqlVal])
            | RelExpr (String, SqlVal, SqlVal)
            | OrExpr [SqlVal]
            | AndExpr [SqlVal]
            | Null
            | AnyColumn
                deriving (Ord, Eq, Show)

