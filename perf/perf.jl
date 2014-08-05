using Dates
using Benchmark

const _dt = Date(2014,1,1)
const _dt2 = DateTime(2014,1,1,0,0,0,0)
const _y = Dates.Year(1)
const _m = Dates.Month(1)
const _d = Dates.Day(1)
const _h = Dates.Hour(1)
const _mi = Dates.Minute(1)
const _s = Dates.Second(1)
const _ms = Dates.Millisecond(1)

perfs = {( p1() = Dates.Date(2014,1,1),"Construction", "Dates.Date(2014,1,1)",1000000),
( p2() = Dates.DateTime(2014,1,1,0,0,0,0),"Construction", "Dates.DateTime(2014,1,1,0,0,0,0)",1000000),
( p3() = Dates.year(_dt),"Accessor", "Dates.year(_dt)",1000000),
( p4() = Dates.month(_dt),"Accessor", "Dates.month(_dt)",1000000),
( p5() = Dates.day(_dt),"Accessor", "Dates.day(_dt)",1000000),
( p6() = Dates.hour(_dt2),"Accessor", "Dates.hour(_dt2)",1000000),
( p7() = Dates.minute(_dt2),"Accessor", "Dates.minute(_dt2)",1000000),
( p8() = Dates.second(_dt2),"Accessor", "Dates.second(_dt2)",1000000),
( p9() = Dates.millisecond(_dt2),"Accessor", "Dates.millisecond(_dt2)",1000000),
( p10() = Dates.Date(_dt2),"Conversion", "Dates.Date(_dt2)",1000000),
( p11() = Dates.DateTime(_dt),"Conversion", "Dates.DateTime(_dt)",1000000),
( p12() = string(_dt), "string","string(_dt)",1000000),
( p13() = string(_dt2), "string","string(_dt2)",1000000),
( p14() = Dates.isleapyear(_dt),"date functions", "Dates.isleapyear(_dt)",1000000),
( p15() = Dates.isleapyear(_dt2),"date functions", "Dates.isleapyear(_dt2)",1000000),
( p16() = Dates.firstdayofmonth(_dt),"date functions", "Dates.firstdayofmonth(_dt)",1000000),
( p17() = Dates.firstdayofmonth(_dt2),"date functions", "Dates.firstdayofmonth(_dt2)",1000000),
( p18() = Dates.lastdayofmonth(_dt),"date functions", "Dates.lastdayofmonth(_dt)",1000000),
( p19() = Dates.lastdayofmonth(_dt2),"date functions", "Dates.lastdayofmonth(_dt2)",1000000),
( p20() = Dates.dayofweek(_dt),"date functions", "Dates.dayofweek(_dt)",1000000),
( p21() = Dates.dayofweek(_dt2),"date functions", "Dates.dayofweek(_dt2)",1000000),
( p22() = Dates.dayofweekofmonth(_dt),"date functions", "Dates.dayofweekofmonth(_dt)",1000000),
( p23() = Dates.dayofweekofmonth(_dt2),"date functions", "Dates.dayofweekofmonth(_dt2)",1000000),
( p24() = Dates.daysofweekinmonth(_dt),"date functions", "Dates.daysofweekinmonth(_dt)",1000000),
( p25() = Dates.daysofweekinmonth(_dt2),"date functions", "Dates.daysofweekinmonth(_dt2)",1000000),
( p26() = Dates.firstdayofweek(_dt),"date functions", "Dates.firstdayofweek(_dt)",1000000),
( p27() = Dates.firstdayofweek(_dt2),"date functions", "Dates.firstdayofweek(_dt2)",1000000),
( p28() = Dates.lastdayofweek(_dt),"date functions", "Dates.lastdayofweek(_dt)",1000000),
( p29() = Dates.lastdayofweek(_dt2),"date functions", "Dates.lastdayofweek(_dt2)",1000000),
( p30() = Dates.dayofyear(_dt),"date functions", "Dates.dayofyear(_dt)",1000000),
( p31() = Dates.dayofyear(_dt2),"date functions", "Dates.dayofyear(_dt2)",1000000),
( p32() = _dt + _y, "arithmetic","_dt + _y",1000000),
( p33() = _dt2 + _y, "arithmetic","_dt2 + _y",1000000),
( p34() = _dt + _m, "arithmetic","_dt + _m",1000000),
( p35() = _dt2 + _m, "arithmetic","_dt2 + _m",1000000),
( p36() = _dt + _d, "arithmetic","_dt + _d",1000000),
( p37() = _dt2 + _d, "arithmetic","_dt2 + _d",1000000),
( p38() = _dt2 + _h, "arithmetic","_dt2 + _h",1000000),
( p49() = _dt2 + _mi, "arithmetic","_dt2 + _mi",1000000),
( p40() = _dt2 + _s, "arithmetic","_dt2 + _s",1000000),
( p41() = _dt2 + _ms, "arithmetic","_dt2 + _ms",1000000)}

results = benchmarks(perfs)


#=In  [15]: showall(results[[:Category,:Benchmark,:TotalWall]])
41x3 DataFrame
|-------|------------------|------------------------------------|-----------|
| Row # | Category         | Benchmark                          | TotalWall |
| 1     | "Construction"   | "Dates.Date(2014,1,1)"             | 0.183308  |
| 2     | "Construction"   | "Dates.DateTime(2014,1,1,0,0,0,0)" | 0.262621  |
| 3     | "Accessor"       | "Dates.year(_dt)"                  | 0.212874  |
| 4     | "Accessor"       | "Dates.month(_dt)"                 | 0.183713  |
| 5     | "Accessor"       | "Dates.day(_dt)"                   | 0.197268  |
| 6     | "Accessor"       | "Dates.hour(_dt2)"                 | 0.0897023 |
| 7     | "Accessor"       | "Dates.minute(_dt2)"               | 0.0928348 |
| 8     | "Accessor"       | "Dates.second(_dt2)"               | 0.0902584 |
| 9     | "Accessor"       | "Dates.millisecond(_dt2)"          | 0.0370552 |
| 10    | "Conversion"     | "Dates.Date(_dt2)"                 | 0.0523056 |
| 11    | "Conversion"     | "Dates.DateTime(_dt)"              | 0.0792681 |
| 12    | "string"         | "string(_dt)"                      | 1.86823   |
| 13    | "string"         | "string(_dt2)"                     | 3.88872   |
| 14    | "date functions" | "Dates.isleapyear(_dt)"                | 0.185513  |
| 15    | "date functions" | "Dates.isleapyear(_dt2)"               | 0.207353  |
| 16    | "date functions" | "Dates.firstdayofmonth(_dt)"       | 0.303621  |
| 17    | "date functions" | "Dates.firstdayofmonth(_dt2)"      | 0.429718  |
| 18    | "date functions" | "Dates.lastdayofmonth(_dt)"        | 0.354412  |
| 19    | "date functions" | "Dates.lastdayofmonth(_dt2)"       | 0.374203  |
| 20    | "date functions" | "Dates.dayofweek(_dt)"             | 0.0366103 |
| 21    | "date functions" | "Dates.dayofweek(_dt2)"            | 0.0921868 |
| 22    | "date functions" | "Dates.dayofweekofmonth(_dt)"      | 0.193035  |
| 23    | "date functions" | "Dates.dayofweekofmonth(_dt2)"     | 0.228165  |
| 24    | "date functions" | "Dates.daysofweekinmonth(_dt)"     | 0.72997   |
| 25    | "date functions" | "Dates.daysofweekinmonth(_dt2)"    | 0.767483  |
| 26    | "date functions" | "Dates.firstdayofweek(_dt)"        | 0.0799839 |
| 27    | "date functions" | "Dates.firstdayofweek(_dt2)"       | 0.0909415 |
| 28    | "date functions" | "Dates.lastdayofweek(_dt)"         | 0.0808826 |
| 29    | "date functions" | "Dates.lastdayofweek(_dt2)"        | 0.0769523 |
| 30    | "date functions" | "Dates.dayofyear(_dt)"             | 0.287922  |
| 31    | "date functions" | "Dates.dayofyear(_dt2)"            | 0.340623  |
| 32    | "arithmetic"     | "_dt + _y"                         | 0.34372   |
| 33    | "arithmetic"     | "_dt2 + _y"                        | 0.558761  |
| 34    | "arithmetic"     | "_dt + _m"                         | 0.387545  |
| 35    | "arithmetic"     | "_dt2 + _m"                        | 0.604046  |
| 36    | "arithmetic"     | "_dt + _d"                         | 0.0780923 |
| 37    | "arithmetic"     | "_dt2 + _d"                        | 0.07673   |
| 38    | "arithmetic"     | "_dt2 + _h"                        | 0.0768656 |
| 39    | "arithmetic"     | "_dt2 + _mi"                       | 0.0764599 |
| 40    | "arithmetic"     | "_dt2 + _s"                        | 0.0807666 |
| 41    | "arithmetic"     | "_dt2 + _ms"                       | 0.0769642 |=#


#=In  [13]: showall(results[[:Category,:Benchmark,:TotalWall]])
41x3 DataFrame
|-------|------------------|------------------------------------|-----------|
| Row # | Category         | Benchmark                          | TotalWall |
| 1     | "Construction"   | "Dates.Date(2014,1,1)"             | 0.0980119 |
| 2     | "Construction"   | "Dates.DateTime(2014,1,1,0,0,0,0)" | 0.0895475 |
| 3     | "Accessor"       | "Dates.year(_dt)"                  | 0.0657421 |
| 4     | "Accessor"       | "Dates.month(_dt)"                 | 0.0655449 |
| 5     | "Accessor"       | "Dates.day(_dt)"                   | 0.070821  |
| 6     | "Accessor"       | "Dates.hour(_dt2)"                 | 0.0572112 |
| 7     | "Accessor"       | "Dates.minute(_dt2)"               | 0.055226  |
| 8     | "Accessor"       | "Dates.second(_dt2)"               | 0.0523492 |
| 9     | "Accessor"       | "Dates.millisecond(_dt2)"          | 0.0460667 |
| 10    | "Conversion"     | "Dates.Date(_dt2)"                 | 0.0898486 |
| 11    | "Conversion"     | "Dates.DateTime(_dt)"              | 0.0781383 |
| 12    | "string"         | "string(_dt)"                      | 1.81929   |
| 13    | "string"         | "string(_dt2)"                     | 3.87923   |
| 14    | "date functions" | "Dates.isleapyear(_dt)"                | 0.105963  |
| 15    | "date functions" | "Dates.isleapyear(_dt2)"               | 0.0670621 |
| 16    | "date functions" | "Dates.firstdayofmonth(_dt)"       | 0.0753262 |
| 17    | "date functions" | "Dates.firstdayofmonth(_dt2)"      | 0.122178  |
| 18    | "date functions" | "Dates.lastdayofmonth(_dt)"        | 0.129431  |
| 19    | "date functions" | "Dates.lastdayofmonth(_dt2)"       | 0.122189  |
| 20    | "date functions" | "Dates.dayofweek(_dt)"             | 0.0460547 |
| 21    | "date functions" | "Dates.dayofweek(_dt2)"            | 0.0516793 |
| 22    | "date functions" | "Dates.dayofweekofmonth(_dt)"      | 0.077735  |
| 23    | "date functions" | "Dates.dayofweekofmonth(_dt2)"     | 0.0983128 |
| 24    | "date functions" | "Dates.daysofweekinmonth(_dt)"     | 0.0954514 |
| 25    | "date functions" | "Dates.daysofweekinmonth(_dt2)"    | 0.102127  |
| 26    | "date functions" | "Dates.firstdayofweek(_dt)"        | 0.0551054 |
| 27    | "date functions" | "Dates.firstdayofweek(_dt2)"       | 0.0971863 |
| 28    | "date functions" | "Dates.lastdayofweek(_dt)"         | 0.0880267 |
| 29    | "date functions" | "Dates.lastdayofweek(_dt2)"        | 0.0908077 |
| 30    | "date functions" | "Dates.dayofyear(_dt)"             | 0.231741  |
| 31    | "date functions" | "Dates.dayofyear(_dt2)"            | 0.268343  |
| 32    | "arithmetic"     | "_dt + _y"                         | 0.168302  |
| 33    | "arithmetic"     | "_dt2 + _y"                        | 0.177796  |
| 34    | "arithmetic"     | "_dt + _m"                         | 0.169318  |
| 35    | "arithmetic"     | "_dt2 + _m"                        | 0.220435  |
| 36    | "arithmetic"     | "_dt + _d"                         | 0.08031   |
| 37    | "arithmetic"     | "_dt2 + _d"                        | 0.0814756 |
| 38    | "arithmetic"     | "_dt2 + _h"                        | 0.0810951 |
| 39    | "arithmetic"     | "_dt2 + _mi"                       | 0.079283  |
| 40    | "arithmetic"     | "_dt2 + _s"                        | 0.0928423 |
| 41    | "arithmetic"     | "_dt2 + _ms"                       | 0.0816582 |=#
