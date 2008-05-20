module RestyScript.Emitter.RenameVar where

import Text.ParserCombinators.Parsec (sourceLine, sourceColumn)
import Text.ParserCombinators.Parsec.Pos (Line, Column)
import RestyScript.AST

instance Visit [SrcPos] where

findVar :: String -> SqlVal -> [SrcPos]
findVar var node =
    case node of
        Variable pos name | name == var
            -> [(fst pos, snd pos - length name)]
        otherwise -> []

rename :: String -> Line -> Column -> [SrcPos] -> Int -> String -> String
rename src@(c:cs) ln col pos@(p:ps) varLen newVar
    | (ln, col) == p = newVar ++
            rename (drop varLen src) ln (col + varLen) ps varLen newVar
    | c == '\n' = c : rename cs (succ ln) 1 pos varLen newVar
    | c == '\t' = c : rename cs ln (col + 8 - (col-1) `mod` 8) pos varLen newVar
    | otherwise = c : rename cs ln (succ col) pos varLen newVar
rename [] _ _ _ _ _ = ""
rename src _ _ [] _ _ = src

emit :: SqlVal -> String -> String -> String -> String
emit ast input oldVar newVar =
    let pos = traverse (findVar oldVar) (++) ast
    in rename input 1 1 pos (length oldVar) newVar

