# sequences

Benchmarks for sequence data structures: lists, vectors, etc.

## Running

For all benchmarks:

    $ stack bench :time

For specific benchmarks:

    $ stack bench :time --benchmark-arguments Consing

<!-- RESULTS -->

## Consing

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|9.735 ns|9.291 ns|9.710 ns|0.010 μs|
|Data.Vector|494.1 ns|575.3 ns|1415 ns|11.11 μs|
|Data.Vector.Unboxed|40.41 ns|68.83 ns|439.5 ns|4.913 μs|
|Data.Sequence|14.77 ns|15.55 ns|14.47 ns|0.015 μs|


## Indexing

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|38.47 ns|199.8 ns|1923 ns|19.92 μs|
|Data.Vector|36.92 ns|37.01 ns|37.09 ns|0.037 μs|
|Data.Vector.Unboxed|19.84 ns|20.37 ns|20.14 ns|0.020 μs|
|Data.Sequence|41.17 ns|87.40 ns|144.4 ns|0.048 μs|

## Append

|Name|10|100|1000|10000|
|---|---|---|---|---|---|---|---|
|Data.List|173.9 ns|1.370 μs|14.15 μs|134.2 μs|
|Data.Vector|584.0 ns|1.034 μs|5.910 μs|57.72 μs|
|Data.Vector.Unboxed|54.21 ns|0.110 μs|0.807 μs|9.077 μs|
|Data.Sequence|242.9 ns|1.821 μs|15.71 μs|150.4 μs|

## Length

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|27.72 ns|187.5 ns|1997 ns|21.70 μs|
|Data.Vector|20.10 ns|19.64 ns|20.09 ns|0.020 μs|
|Data.Vector.Unboxed|12.41 ns|11.62 ns|11.98 ns|0.012 μs|
|Data.Sequence|11.39 ns|11.33 ns|11.19 ns|0.012 μs|

## Sort

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|0.834 μs|14.37 μs|292.4 μs|8.322 ms|
|Data.Vector|1.084 μs|12.12 μs|159.1 μs|2.845 ms|
|Data.Vector.Unboxed|0.966 μs|8.391 μs|94.66 μs|1.291 ms|
|Data.Sequence|2.824 μs|32.45 μs|497.4 μs|14.11 ms|

## Replicate

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|119.1 ns|1003 ns|9.834 μs|98.61 μs|
|Data.Vector|985.3 ns|1536 ns|4.117 μs|29.28 μs|
|Data.Vector.Unboxed|44.31 ns|107.5 ns|0.781 μs|6.956 μs|
|Data.Sequence|79.31 ns|945.9 ns|9.394 μs|94.60 μs|

## Min

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|175.1 ns|1587 ns|15.36 μs|157.7 μs|
|Data.Vector|35.65 ns|209.0 ns|1.910 μs|19.72 μs|
|Data.Vector.Unboxed|24.40 ns|108.5 ns|0.933 μs|8.940 μs|

## Max

|Name|10|100|1000|10000|
|---|---|---|---|---|
|Data.List|161.1 ns|1519 ns|14.84 μs|146.8 μs|
|Data.Vector|42.10 ns|227.3 ns|2.042 μs|20.97 μs|
|Data.Vector.Unboxed|28.47 ns|117.1 ns|0.913 μs|9.010 μs|

## Remove Element

|Name|1|100|1000|10000|
|---|---|---|---|---|
|Data.List|156.4 μs|176.0 μs|171.0 μs|171.4 μs|
|Data.Vector|744.4 μs|737.9 μs|745.0 μs|743.8 μs|
|Data.Vector.Unboxed|64.00 μs|77.40 μs|76.44 μs|77.84 μs|
|Data.Sequence|2240 μs|2246 μs|2229 μs|2252 μs|

## Remove By Index

|Name|1|100|1000|10000|
|---|---|---|---|---|
|Data.Vector|737.1 μs|744.0 μs|734.6 μs|743.2 μs|
|Data.Vector.Unboxed|68.41 μs|82.31 μs|81.93 μs|82.13 μs|
