# Test string/show representation of Date
@test string(Dates.Date(1,1,1)) == "0001-01-01" # January 1st, 1 AD/CE
@test string(Dates.Date(0,12,31)) == "0000-12-31" # December 31, 1 BC/BCE
@test Dates.Date(1,1,1) - Dates.Date(0,12,31) == Dates.Day(1)
@test Dates.Date(Dates.UTD(-306)) == Dates.Date(0,2,29)
@test string(Dates.Date(0,1,1)) == "0000-01-01" # January 1st, 1 BC/BCE
@test string(Dates.Date(-1,1,1)) == "-0001-01-01" # January 1st, 2 BC/BCE
@test string(Dates.Date(-1000000,1,1)) == "-1000000-01-01"
@test string(Dates.Date(1000000,1,1)) == "1000000-01-01"


# DateTime parsing
#'1996-January-15'
dt = Dates.DateTime(1996,1,15)
f = "yy-mm-dd"
a = "96-01-15"
@test Dates.DateTime(a,f) + Dates.Year(1900) == dt
a1 = "96-1-15"
@test Dates.DateTime(a1,f) + Dates.Year(1900) == dt
a2 = "96-1-1"
@test Dates.DateTime(a2,f) + Dates.Year(1900) + Dates.Day(14) == dt
a3 = "1996-1-15"
@test Dates.DateTime(a3,f) == dt
a4 = "1996-Jan-15"
@test_throws ArgumentError Dates.DateTime(a4,f) # Trying to use month name, but specified only "mm"

f = "yy/mmm/dd"
b = "96/Feb/15"
@test Dates.DateTime(b,f) + Dates.Year(1900) == dt + Dates.Month(1)
b1 = "1996/Feb/15"
@test Dates.DateTime(b1,f) == dt + Dates.Month(1)
b2 = "96/Feb/1"
@test Dates.DateTime(b2,f) + Dates.Year(1900) + Dates.Day(14) == dt + Dates.Month(1)
# Here we've specifed the month name, yet fail to parse and default to January
b3 = "96/2/15"
@test Dates.DateTime(b3,f) == dt - Dates.Year(1900) 

f = "yy:dd:mm"
c = "96:15:01"
@test Dates.DateTime(c,f) + Dates.Year(1900) == dt
c1 = "1996:15:01"
@test Dates.DateTime(c1,f) == dt
c2 = "96:15:1"
@test Dates.DateTime(c2,f) + Dates.Year(1900) == dt
c3 = "96:1:01"
@test Dates.DateTime(c3,f) + Dates.Year(1900) + Dates.Day(14) == dt
c4 = "96:15:01 # random comment"
@test_throws ArgumentError Dates.DateTime(c4,f) # Currently doesn't handle trailing comments

f = "yyyy,mmm,dd"
d = "1996,Jan,15"
@test Dates.DateTime(d,f) == dt
d1 = "96,Jan,15"
@test Dates.DateTime(d1,f) + Dates.Year(1900) == dt
d2 = "1996,Jan,1"
@test Dates.DateTime(d2,f) + Dates.Day(14) == dt
d3 = "1996,2,15"
@test Dates.DateTime(d3,f) != Dates.DateTime(1996,2,15) # Same as above

f = "yyyy.mmmm.dd"
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
#@test Dates.DateTime(j,f) == dt
# k = "1996-01-15 10:00:00"
# f = "yyyy-mm-dd HH:MM:SS zzz"
# @test Dates.DateTime(k,f) == dt + Dates.Hour(10)
# l = "1996-01-15 10:10:10.25"
# f = "yyyy-mm-dd HH:MM:SS.ss zzz"
# @test Dates.DateTime(l,f) == dt + Dates.Hour(10) + Dates.Minute(10) + Dates.Second(10) + Dates.Millisecond(250)

# r = "1/15/1996" # Excel
# f = "m/dd/yyyy"
# @test Dates.DateTime(r,f) == dt
# s = "19960115"
# f = "yyyymmdd"
# @test Dates.DateTime(s,f) == dt
# v = "1996-01-15 10:00:00"
# f = "yyyy-mm-dd HH:MM:SS"
# @test Dates.DateTime(v,f) == dt + Dates.Hour(10)
# w = "1996-01-15T10:00:00"
# f = "yyyy-mm-ddTHH:MM:SS zzz"
# @test Dates.DateTime(w,f;sep="T") == dt + Dates.Hour(10)

# f = "yyyy/m"
# y = "1996/1"
# @test Dates.DateTime(y,f) == dt - Dates.Day(14)
# y1 = "1996/1/15"
# @test_throws ArgumentError Dates.DateTime(y1,f)
# y2 = "96/1"
# @test Dates.DateTime(y2,f) + Dates.Year(1900) == dt - Dates.Day(14)

# f = "yyyy"
# z = "1996"
# @test Dates.DateTime(z,f) == dt - Dates.Day(14)
# z1 = "1996-3"
# @test Dates.DateTime(z1,f) != Dates.DateTime(1996,3)
# z2 = "1996-3-1"
# @test Dates.DateTime(z2,f) != Dates.DateTime(1996,3)

# aa = "1/5/1996"
# f = "m/d/yyyy"
# @test Dates.DateTime(aa,f) == dt - Dates.Day(10)
# bb = "5/1/1996"
# f = "d/m/yyyy"
# @test Dates.DateTime(bb,f) == dt - Dates.Day(10)
# cc = "01151996"
# f = "mmddyyyy"
# @test Dates.DateTime(cc,f) == dt
# dd = "15011996"
# f = "ddmmyyyy"
# @test Dates.DateTime(dd,f) == dt
# ee = "01199615"
# f = "mmyyyydd"
# @test Dates.DateTime(ee,f) == dt
# ff = "1996-15-Jan"
# f = "yyyy-dd-mmm"
# @test Dates.DateTime(ff,f) == dt
# gg = "Jan-1996-15"
# f = "mmm-yyyy-dd"
# @test Dates.DateTime(gg,f) == dt

@test_throws ArgumentError DateTime("18/05/2009","mm/dd/yyyy") # switched month and day
@test_throws ArgumentError DateTime("18/05/2009 16","mm/dd/yyyy hh") # same
@test DateTime("18/05/2009 16:12","mm/dd/yyyy hh:mm") == DateTime(2009,12,16) # here they used mm instead of MM for minutes
@test_throws ArgumentError DateTime("18:05:2009","mm/dd/yyyy")
@test Date("2009年12月01日","yyyy年mm月dd日") == Date(2009,12,1)
@test Date("2009-12-01","yyyy-mm-dd") == Date(2009,12,1)
