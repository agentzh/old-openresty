{-# OPTIONS_GHC -funbox-strict-fields #-}

module RestyScript.Emitter.Stats (
    Stats,
    emit,
    emitJSON
) where

import RestyScript.AST
import Text.JSON

data Stats = Stats {
    modelList :: ![String], funcList :: ![String],
    selectedMax :: !Int, joinedMax :: !Int,
    comparedCount :: !Int, queryCount :: !Int }
        deriving (Ord, Eq, Show)

instance JSON Stats where
    showJSON st =
        JSObject $ toJSObject [
                     ("modelList", showList $ modelList st),
                     ("funcList", showList $ funcList st),
                     ("selectedMax", showJSON $ selectedMax st),
                     ("joinedMax", showJSON $ joinedMax st),
                     ("comparedCount", showJSON $ comparedCount st),
                     ("queryCount", showJSON $ queryCount st)]
            where showList = JSArray . map showJSON
    readJSON = undefined

si = Stats {
    modelList = [], funcList = [],
    selectedMax = 0, joinedMax = 0,
    comparedCount = 0, queryCount = 0 }

findModel :: RSVal -> Stats -> Stats
findModel (Model (Symbol n)) st = st { modelList = [n] }
findModel (Model (Variable _ n)) st = st { modelList = ['$':n] }
findModel _ st = st

findFunc :: RSVal -> Stats -> Stats
findFunc (FuncCall (Symbol func)  _) st = st { funcList = func : (funcList st) }
findFunc (FuncCall (Variable _ func)  _) st = st { funcList = ('$':func) : (funcList st) }
findFunc _ st = st

findSelected :: RSVal -> Stats -> Stats
findSelected (Select lst) st = st { selectedMax = length lst }
findSelected _ st = st

findJoined :: RSVal -> Stats -> Stats
findJoined (From lst) st = st { joinedMax = length lst }
findJoined _ st = st

findQuery :: RSVal -> Stats -> Stats
findQuery (Query _) st = st { queryCount = 1 }
findQuery _ st = st

findCompared :: RSVal -> Stats -> Stats
findCompared (Compare _ _ _) st = st { comparedCount = 1 }
findCompared _ st = st

visit :: RSVal -> Stats
visit node = foldr (\f st -> f node st) si
    [findModel, findFunc,
     findSelected, findJoined, findCompared, findQuery]

merge :: Stats -> Stats -> Stats
merge a b = Stats {
    modelList = (modelList a) ++ (modelList b),
    funcList = (funcList a) ++ (funcList b),
    selectedMax = max (selectedMax a) (selectedMax b),
    joinedMax = max (joinedMax a) (joinedMax b),
    comparedCount = comparedCount a + comparedCount b,
    queryCount = queryCount a + queryCount b }

emit :: RSVal -> Stats
emit = traverse visit merge

emitJSON :: RSVal -> String
emitJSON = encode . emit

