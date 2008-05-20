module RestyScript.Emitter.RenameVar where

import Text.ParserCombinators.Parsec (sourceLine, sourceColumn)
import RestyScript.AST

instance Visit [SrcPos] where

findVar :: String -> SqlVal -> [SrcPos]
findVar var node =
    case node of
        Variable pos var -> [(fst pos, snd pos - length var)]
        otherwise -> []

