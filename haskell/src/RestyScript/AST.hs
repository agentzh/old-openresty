module RestyScript.AST (
    RSVal(..)
) where

import Text.ParserCombinators.Parsec.Pos (SourcePos)

-- RestyScript AST datatype
data RSVal = SetOp !String RSVal RSVal
           | Query [RSVal]
           | Select !String [RSVal] -- Select modifier entries
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
           | Action [RSVal]
           | Delete RSVal RSVal -- Delete model cond
           | Update RSVal RSVal RSVal -- Update model assign cond
           | Assign RSVal RSVal -- Assign col expr
           | HttpCmd !String RSVal RSVal -- HttpCmd method url content
           | Object [RSVal]  -- Object [pair]
           | Pair RSVal RSVal -- Pair key value
           | Array [RSVal]  -- Array [elem]
               deriving (Ord, Eq, Show)

