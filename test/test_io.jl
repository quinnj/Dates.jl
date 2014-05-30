# Test string/show representation of Date
@test string(Dates.Date(1,1,1)) == "0001-01-01" # January 1st, 1 AD/CE
@test string(Dates.Date(0,12,31)) == "0000-12-31" # December 31, 1 BC/BCE
@test Dates.Date(1,1,1) - Dates.Date(0,12,31) == Dates.Day(1)
@test Dates.Date(Dates.UTD(-306)) == Dates.Date(0,2,29)
@test string(Dates.Date(0,1,1)) == "0000-01-01" # January 1st, 1 BC/BCE
@test string(Dates.Date(-1,1,1)) == "-0001-01-01" # January 1st, 2 BC/BCE
@test string(Dates.Date(-1000000,1,1)) == "-1000000-01-01"
@test string(Dates.Date(1000000,1,1)) == "1000000-01-01"
@test string(Dates.DateTime(2000,1,1,0,0,0,1)) == "2000-01-01T00:00:00.001Z"
@test string(Dates.DateTime(2000,1,1,0,0,0,2)) == "2000-01-01T00:00:00.002Z"
@test string(Dates.DateTime(2000,1,1,0,0,0,500)) == "2000-01-01T00:00:00.5Z"
@test string(Dates.DateTime(2000,1,1,0,0,0,998)) == "2000-01-01T00:00:00.998Z"
@test string(Dates.DateTime(2000,1,1,0,0,0,999)) == "2000-01-01T00:00:00.999Z"

# DateTime parsing
# Useful reference for different locales: http://library.princeton.edu/departments/tsd/katmandu/reference/months.html

# Common Parsing Patterns
#'1996-January-15'
dt = Dates.DateTime(1996,1,15)
f = "yy-mm-dd"
a = "96-01-15"
@test DateTime(a,f) + Dates.Year(1900) == dt
a1 = "96-1-15"
@test Dates.DateTime(a1,f) + Dates.Year(1900) == dt
a2 = "96-1-1"
@test Dates.DateTime(a2,f) + Dates.Year(1900) + Dates.Day(14) == dt
a3 = "1996-1-15"
@test Dates.DateTime(a3,f) == dt
a4 = "1996-Jan-15"
@test_throws ArgumentError Dates.DateTime(a4,f) # Trying to use month name, but specified only "mm"

f = "yy/uuu/dd"
b = "96/Feb/15"
@test Dates.DateTime(b,f) + Dates.Year(1900) == dt + Dates.Month(1)
b1 = "1996/Feb/15"
@test Dates.DateTime(b1,f) == dt + Dates.Month(1)
b2 = "96/Feb/1"
@test Dates.DateTime(b2,f) + Dates.Year(1900) + Dates.Day(14) == dt + Dates.Month(1)
# Here we've specifed a text month name, but given a number
b3 = "96/2/15"
@test_throws KeyError Dates.DateTime(b3,f)

f = "yy:dd:mm"
c = "96:15:01"
@test Dates.DateTime(c,f) + Dates.Year(1900) == dt
c1 = "1996:15:01"
@test Dates.DateTime(c1,f) == dt
c2 = "96:15:1"
@test Dates.DateTime(c2,f) + Dates.Year(1900) == dt
c3 = "96:1:01"
@test Dates.DateTime(c3,f) + Dates.Year(1900) + Dates.Day(14) == dt
c4 = "1996:15:01 # random comment"
@test Dates.DateTime(c4,f) == dt

f = "yyyy,uuu,dd"
d = "1996,Jan,15"
@test Dates.DateTime(d,f) == dt
d1 = "96,Jan,15"
@test Dates.DateTime(d1,f) + Dates.Year(1900) == dt
d2 = "1996,Jan,1"
@test Dates.DateTime(d2,f) + Dates.Day(14) == dt
d3 = "1996,2,15"
@test_throws KeyError Dates.DateTime(d3,f)

f = "yyyy.U.dd"
e = "1996.January.15"
@test Dates.DateTime(e,f) == dt
e1 = "96.January.15"
@test Dates.DateTime(e1,f) + Dates.Year(1900) == dt

fo = "yyyy m dd"
f = "1996 1 15"
@test Dates.DateTime(f,fo) == dt
f1 = "1996 01 15"
@test Dates.DateTime(f1,fo) == dt
f2 = "1996 1 1"
@test Dates.DateTime(f2,fo) + Dates.Day(14) == dt

j = "1996-01-15"
f = "yyyy-mm-dd zzz"
@test Dates.DateTime(j,f) == dt
k = "1996-01-15 10:00:00"
f = "yyyy-mm-dd HH:MM:SS zzz"
@test Dates.DateTime(k,f) == dt + Dates.Hour(10)
l = "1996-01-15 10:10:10.25"
f = "yyyy-mm-dd HH:MM:SS.ss zzz"
@test Dates.DateTime(l,f) == dt + Dates.Hour(10) + Dates.Minute(10) + Dates.Second(10) + Dates.Millisecond(250)

r = "1/15/1996" # Excel
f = "m/dd/yyyy"
@test Dates.DateTime(r,f) == dt
s = "19960115"
f = "yyyymmdd"
@test Dates.DateTime(s,f) == dt
v = "1996-01-15 10:00:00"
f = "yyyy-mm-dd HH:MM:SS"
@test Dates.DateTime(v,f) == dt + Dates.Hour(10)
w = "1996-01-15T10:00:00"
f = "yyyy-mm-ddTHH:MM:SS zzz"
@test Dates.DateTime(w,f) == dt + Dates.Hour(10)

f = "yyyy/m"
y = "1996/1"
@test Dates.DateTime(y,f) == dt - Dates.Day(14)
y1 = "1996/1/15"
@test_throws ArgumentError Dates.DateTime(y1,f)
y2 = "96/1"
@test Dates.DateTime(y2,f) + Dates.Year(1900) == dt - Dates.Day(14)

f = "yyyy"
z = "1996"
@test Dates.DateTime(z,f) == dt - Dates.Day(14)
z1 = "1996-3"
@test_throws ArgumentError Dates.DateTime(z1,f)
z2 = "1996-3-1"
@test_throws ArgumentError Dates.DateTime(z2,f)

aa = "1/5/1996"
f = "m/d/yyyy"
@test Dates.DateTime(aa,f) == dt - Dates.Day(10)
bb = "5/1/1996"
f = "d/m/yyyy"
@test Dates.DateTime(bb,f) == dt - Dates.Day(10)
cc = "01151996"
f = "mmddyyyy"
@test Dates.DateTime(cc,f) == dt
dd = "15011996"
f = "ddmmyyyy"
@test Dates.DateTime(dd,f) == dt
ee = "01199615"
f = "mmyyyydd"
@test Dates.DateTime(ee,f) == dt
ff = "1996-15-Jan"
f = "yyyy-dd-uuu"
@test Dates.DateTime(ff,f) == dt
gg = "Jan-1996-15"
f = "uuu-yyyy-dd"
@test Dates.DateTime(gg,f) == dt

# from Jiahao
@test Dates.Date("2009年12月01日","yyyy年mm月dd日") == Dates.Date(2009,12,1)
@test Dates.Date("2009-12-01","yyyy-mm-dd") == Dates.Date(2009,12,1)

# French: from Milan
f = "dd/mm/yyyy"
f2 = "dd/mm/yy"
@test Dates.Date("28/05/2014",f) == Dates.Date(2014,5,28)
@test Dates.Date("28/05/14",f2) + Dates.Year(2000) == Dates.Date(2014,5,28)

const french = ["janv"=>1,"févr"=>2,"mars"=>3,"avril"=>4,"mai"=>5,"juin"=>6,"juil"=>7,"août"=>8,"sept"=>9,"oct"=>10,"nov"=>11,"déc"=>12]
Dates.MONTHLOCALEABBR["french"] = french
f = "dd uuuuu yyyy"
@test Dates.Date("28 mai 2014",f;locale="french") == Dates.Date(2014,5,28)
@test Dates.Date("28 févr 2014",f;locale="french") == Dates.Date(2014,2,28)
@test Dates.Date("28 août 2014",f;locale="french") == Dates.Date(2014,8,28)
@test Dates.Date("28 avril 2014",f;locale="french") == Dates.Date(2014,4,28)
f = "dd u yyyy"
@test Dates.Date("28 avril 2014",f;locale="french") == Dates.Date(2014,4,28)
f = "dduuuuuyyyy"
@test Dates.Date("28avril2014",f;locale="french") == Dates.Date(2014,4,28)
@test_throws KeyError Dates.Date("28mai2014",f;locale="french")

# From Tony Fong
f = "dduuuyy"
@test Dates.Date("01Dec09",f) + Dates.Year(2000) == Dates.Date(2009,12,1)
f = "dduuuyyyy"
@test Dates.Date("01Dec2009",f) == Dates.Date(2009,12,1)
f = "duy"
const globex = ["f"=>Jan,"g"=>Feb,"h"=>Mar,"j"=>Apr,"k"=>May,"m"=>Jun,
                "n"=>Jul,"q"=>Aug,"u"=>Sep,"v"=>Oct,"x"=>Nov,"z"=>Dec]
Dates.MONTHLOCALEABBR["globex"] = globex
@test Dates.Date("1F4",f;locale="globex") + Dates.Year(2010) == Dates.Date(2014,1,1)

# From Matt Bauman
f = "yyyy-mm-ddTHH:MM:SSZ"
@test Dates.DateTime("2014-05-28T16:46:04Z",f) == Dates.DateTime(2014,5,28,16,46,04)

# Try to break stuff

# Specified mm/dd, but date string has day/mm
@test_throws ArgumentError Dates.DateTime("18/05/2009","mm/dd/yyyy")
@test_throws ArgumentError Dates.DateTime("18/05/2009 16","mm/dd/yyyy hh")
# Used "mm" for months AND minutes
@test_throws ArgumentError Dates.DateTime("18/05/2009 16:12","mm/dd/yyyy hh:mm")
# Date string has different delimiters than format string
@test_throws ArgumentError Dates.DateTime("18:05:2009","mm/dd/yyyy")

f = "y m d"
@test Dates.Date("1 1 1",f) == Dates.Date(1)
@test Dates.Date("10000000000 1 1",f) == Dates.Date(10000000000)
@test_throws ArgumentError Dates.Date("1 13 1",f)
@test Dates.Date("1 1 32",f) == Dates.Date(1,2,1)
@test Dates.Date(" 1 1 32",f) == Dates.Date(1,2,1)
@test_throws ArgumentError Dates.Date("# 1 1 32",f)
@test Dates.Date("1",f) == Dates.Date(1)
@test Dates.Date("1 2",f) == Dates.Date(1,2)
# different delimiter, so it tries to parse year, fails, and defaults to Year(1)
@test Dates.Date("2000/1",f) == Dates.Date(1)

@test DateTime("20140529 120000","yyyymmdd HHMMSS") == Dates.DateTime(2014,5,29,12)