module RestyScript.Emitter.RenameVar where

import Text.ParserCombinators.Parsec.Pos (
    SourcePos, incSourceColumn,
    updatePosChar, setSourceLine, setSourceColumn)
import RestyScript.AST

instance Visit [SourcePos] where

findVar :: String -> SqlVal -> [SourcePos]
findVar var node =
    case node of
        Variable pos name | name == var
            -> [pos]
        otherwise -> []

rename :: String -> SourcePos -> [SourcePos] -> Int -> String -> String
rename src@(c:cs) pos varPos@(p:ps) varLen newVar
    | pos == p = newVar ++
            rename (drop varLen src) (incSourceColumn pos varLen) ps varLen newVar
    | otherwise = c : rename cs (updatePosChar pos c) varPos varLen newVar
rename [] _ _ _ _ = ""
rename src _ [] _ _ = src

emit :: SqlVal -> String -> String -> String -> String
emit ast input oldVar newVar =
    let pos = traverse (findVar oldVar) (++) ast
    in if null pos
         then input
         else rename input (setSourceLine (setSourceColumn (head pos) 1) 1) pos (length oldVar) newVar

