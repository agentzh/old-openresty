module RestyScript.Emitter.RenameVar where

import Text.ParserCombinators.Parsec.Pos (
    SourcePos, incSourceColumn,
    updatePosChar, setSourceLine, setSourceColumn)
import RestyScript.AST.View

findVar :: String -> RSVal -> [SourcePos]
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

emit :: RSVal -> String -> String -> String -> String
emit ast input oldVar newVar =
    let varPos = traverse (findVar oldVar) (++) ast
    in if null varPos
         then input
         else rename input (newPos (head varPos) 1 1) varPos (length oldVar) newVar
    where newPos pos ln col = setSourceLine (setSourceColumn pos col) ln

