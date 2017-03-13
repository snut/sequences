{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE BangPatterns #-}

module Main (main) where

import           Control.DeepSeq
import           Control.Exception (evaluate)
import           Control.Monad
import           Control.Monad.ST
import           Criterion.Main
import           Criterion.Types
import qualified Data.List as L
import           Data.Monoid
import qualified Data.Sequence as S
import qualified Data.Vector as V
import qualified Data.Vector.Algorithms.Merge as V
import qualified Data.Vector.Unboxed as UV
import           System.Directory

data Conser = forall f. NFData (f Int) => Conser String (Int -> f Int)
data Append = forall f. NFData (f Int) => Append String (Int -> IO (f Int)) (f Int -> f Int -> f Int)
data Replicator = forall f. NFData (f Int) => Replicator String (Int -> Int -> f Int)
data Indexing = forall f. NFData (f Int) => Indexing String (IO (f Int)) (f Int -> Int -> Int)
data Length = forall f. NFData (f Int) => Length String (Int -> IO (f Int)) (f Int -> Int)
data Min = forall f. NFData (f Int) => Min String (Int -> IO (f Int)) (f Int -> Int)
data Max = forall f. NFData (f Int) => Max String (Int -> IO (f Int)) (f Int -> Int)
data Sort = forall f. NFData (f Int) => Sort String (Int -> IO (f Int)) (f Int -> f Int)
data RemoveElement = forall f. NFData (f Int) => RemoveElement String (IO (f Int)) ((Int -> Bool) -> f Int -> f Int)
data RemoveByIndex = forall f. NFData (f Int) => RemoveByIndex String (IO (f Int)) ((Int -> Int -> Bool) -> f Int -> f Int)

main :: IO ()
main = do
  let fp = "out.csv"
  exists <- doesFileExist fp
  when exists (removeFile fp)
  defaultMainWith
    defaultConfig
    {csvFile = Just fp, regressions = [(["regress"], "allocated:iters")]}
    [ bgroup
        "Consing"
        (conses
           [ Conser "Data.List" conslist
           , Conser "Data.Vector" consvector
           , Conser "Data.Vector.Unboxed" consuvector
           , Conser "Data.Sequence" consseq
           ])
    , bgroup
        "Replicate"
        (replicators
           [ Replicator "Data.List" L.replicate
           , Replicator "Data.Vector" V.replicate
           , Replicator "Data.Vector.Unboxed" UV.replicate
           , Replicator "Data.Sequence" S.replicate
           ])
    , bgroup
        "Indexing"
        (let size = 10005
         in indexes
              [ Indexing "Data.List" (sampleList size) (L.!!)
              , Indexing "Data.Vector" (sampleVector size) (V.!)
              , Indexing "Data.Vector.Unboxed" (sampleUVVector size) (UV.!)
              , Indexing "Data.Sequence" (sampleSeq size) (S.index)
              ])
    , bgroup
        "Append"
        (appends
           [ Append "Data.List" sampleList (<>)
           , Append "Data.Vector" sampleVector (<>)
           , Append "Data.Vector.Unboxed" sampleUVVector (<>)
           , Append "Data.Sequence" sampleSeq (<>)
           ])
    , bgroup
        "Length"
        (lengths
              [ Length "Data.List" sampleList (L.length)
              , Length "Data.Vector" sampleVector (V.length)
              , Length "Data.Vector.Unboxed" sampleUVVector (UV.length)
              , Length "Data.Sequence" sampleSeq (S.length)
              ])
    , bgroup
        "Min"
        (mins
              [ Min "Data.List" (sampleList) (L.minimum)
              , Min "Data.Vector" (sampleVector) (V.minimum)
              , Min "Data.Vector.Unboxed" (sampleUVVector) (UV.minimum)
              ])
    , bgroup
        "Max"
        (maxs
              [ Max "Data.List" sampleList (L.maximum)
              , Max "Data.Vector" sampleVector (V.maximum)
              , Max "Data.Vector.Unboxed" sampleUVVector (UV.maximum)
              ])
    , bgroup
        "Sort"
        (sorts
         [ Sort "Data.List" sampleList (L.sort)
         , Sort "Data.Vector" sampleVector sortVec
         , Sort "Data.Vector.Unboxed" sampleUVVector sortUVec
         , Sort "Data.Sequence" sampleSeq (S.sort)
         ])
    , bgroup
        "Remove Element"
        (let size = 10005
         in removeElems
              [ RemoveElement "Data.List" (sampleList size) (L.filter)
              , RemoveElement "Data.Vector" (sampleVector size) (V.filter)
              , RemoveElement
                  "Data.Vector.Unboxed"
                  (sampleUVVector size)
                  (UV.filter)
              , RemoveElement "Data.Sequence" (sampleSeq size) (S.filter)
              ])
    , bgroup
        "Remove By Index"
        (let size = 10005
         in removeByIndexes
              [ RemoveByIndex "Data.Vector" (sampleVector size) (V.ifilter)
              , RemoveByIndex
                  "Data.Vector.Unboxed"
                  (sampleUVVector size)
                  (UV.ifilter)
              ])
    ]
  where
    appends funcs =
      [ env
        (payload i)
        (\p -> bench (title ++ ":" ++ show i) $ nf (\x -> func x x) p)
      | i <- [10, 100, 1000, 10000, 100000, 1000000, 10000000]
      , Append title payload func <- funcs
      ]
    conses funcs =
      [ bench (title ++ ":" ++ show i) $ nf func i
      | i <- [10, 100, 1000, 10000]
      , Conser title func <- funcs
      ]
    replicators funcs =
      [ bench (title ++ ":" ++ show i) $ nf (\(x, y) -> func x y) (i, 1234)
      | i <- [10, 100, 1000, 10000]
      , Replicator title func <- funcs
      ]
    indexes funcs =
      [ env
        payload
        (\p -> bench (title ++ ":" ++ show index) $ nf (\x -> func p x) index)
      | index <- [10, 100, 1000, 10000]
      , Indexing title payload func <- funcs
      ]
    lengths funcs =
      [ env (payload len) (\p -> bench (title ++ ":" ++ (show len)) $ nf (\x -> func x) p)
      | len <- [10, 100, 1000, 10000]
      , Length title payload func <- funcs
      ]
    mins funcs =
      [ env (payload len) (\p -> bench (title ++ ":" ++ (show len)) $ nf (\x -> func x) p)
      | len <- [10, 100, 1000, 10000]
      , Min title payload func <- funcs
      ]
    maxs funcs =
      [ env (payload len) (\p -> bench (title ++ ":" ++ (show len)) $ nf (\x -> func x) p)
      | len <- [10, 100, 1000, 10000]
      , Max title payload func <- funcs
      ]
    sorts funcs =
      [  env (payload len) (\p -> bench (title ++ ":" ++ (show len)) $ nf (\x -> func x) p)
      |  len <- [10, 100, 1000, 10000]
      ,  Sort title payload func <- funcs
      ]
    removeElems funcs =
      [ env
        payload
        (\p ->
           bench (title ++ ":" ++ show relem) $ nf (\x -> func (/= relem) x) p)
      | relem <- [1, 100, 1000, 10000 :: Int]
      , RemoveElement title payload func <- funcs
      ]
    removeByIndexes funcs =
      [ env
        payload
        (\p ->
           bench (title ++ ":" ++ show relem) $
           nf (\x -> func (\index _ -> index /= relem) x) p)
      | relem <- [1, 100, 1000, 10000 :: Int]
      , RemoveByIndex title payload func <- funcs
      ]

sortVec :: V.Vector Int -> V.Vector Int
sortVec vec =
  runST
    (do mv <- V.unsafeThaw vec
        V.sort mv
        V.unsafeFreeze mv)

sortUVec :: UV.Vector Int -> UV.Vector Int
sortUVec vec =
  runST
    (do mv <- UV.unsafeThaw vec
        V.sort mv
        UV.unsafeFreeze mv)

sampleList :: Int -> IO [Int]
sampleList i = evaluate $ force [1 .. i]

sampleVector :: Int -> IO (V.Vector Int)
sampleVector i = evaluate $ force $ V.generate i id

sampleUVVector :: Int -> IO (UV.Vector Int)
sampleUVVector i = evaluate $ force $ UV.generate i id

sampleSeq :: Int -> IO (S.Seq Int)
sampleSeq i = evaluate $ force $ S.fromList [1 .. i]

conslist :: Int -> [Int]
conslist n0 = go n0 []
  where go 0 acc = acc
        go n !acc = go (n - 1) (n : acc)

consvector :: Int -> V.Vector Int
consvector n0 = go n0 V.empty
  where go 0 acc = acc
        go n !acc = go (n - 1) (V.cons n acc)

consuvector :: Int -> UV.Vector Int
consuvector n0 = go n0 UV.empty
  where go 0 acc = acc
        go n !acc = go (n - 1) (UV.cons n acc)

consseq :: Int -> S.Seq Int
consseq n0 = go n0 S.empty
  where go 0 acc = acc
        go n !acc = go (n - 1) (n S.<| acc)
