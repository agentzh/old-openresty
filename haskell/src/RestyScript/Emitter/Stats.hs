module RestyScript.Emitter.Stats (
    Stats,
    emit
) where

import RestyScript.AST

data Stats = Stats { modelList :: [String], funcList :: [String],
    selectedMax :: Int, joinedMax :: Int, comparedMax :: Int,
    queryCount :: Int }
        deriving (Ord, Eq, Show)

si = Stats { modelList = [], funcList = [],
             selectedMax = 0, joinedMax = 0, comparedMax = 0,
             queryCount = 0 }

instance Visit Stats where

findFunc :: SqlVal -> Stats -> Stats
findFunc (FuncCall func _) st = st { funcList = func : (funcList st) }
findFunc _ st = st

visit :: SqlVal -> Stats
visit node = foldr (\f st -> f node st) si [findFunc]

merge :: Stats -> Stats -> Stats
merge a b = Stats {
    modelList = (modelList a) ++ (modelList b),
    funcList = (funcList a) ++ (funcList b),
    selectedMax = max (selectedMax a) (selectedMax b),
    joinedMax = max (joinedMax a) (joinedMax b),
    comparedMax = max (comparedMax a) (comparedMax b),
    queryCount = (queryCount a) + (queryCount b) }

emit :: SqlVal -> Stats
emit = traverse visit merge

