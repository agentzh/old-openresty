module RestyScript.AST (
    SqlVal(..)
) where

data SqlVal = Select [SqlVal]
            | From [SqlVal]
            | Where SqlVal
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
            | NullClause
                deriving (Ord, Eq, Show)

