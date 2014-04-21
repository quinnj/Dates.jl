# Convert # of Rata Die days to proleptic Gregorian calendar y,m,d,w
# Reference: http://mysite.verizon.net/aesir_research/date/date0.htm
function _day2date(days)
    z = days + 306; h = 100z - 25; a = fld(h,3652425); b = a - fld(a,4);
    y = fld(100b+h,36525); c = b + z - 365y - fld(y,4); m = div(5c+456,153);
    d = c - div(153m-457,5); return m > 12 ? (y+1,m-12,d) : (y,m,d)
end
function _year(days)
   z = days + 306; h = 100z - 25; a = fld(h,3652425); b = a - fld(a,4);
   y = fld(100b+h,36525); c = b + z - 365y - fld(y,4); m = div(5c+456,153); 
   return m > 12 ? y+1 : y
end 
function _month(days)
    z = days + 306; h = 100z - 25; a = fld(h,3652425); b = a - fld(a,4);
    y = fld(100b+h,36525); c = b + z - 365y - fld(y,4); m = div(5c+456,153); 
    return m > 12 ? m-12 : m
end
function _day(days)
    z = days + 306; h = 100z - 25; a = fld(h,3652425); b = a - fld(a,4);
    y = fld(100b+h,36525); c = b + z - 365y - fld(y,4); m = div(5c+456,153); 
    return c - div(153m-457,5)
end
# https://en.wikipedia.org/wiki/Talk:ISO_week_date#Algorithms
function _week(days)
    w = div(abs(days-1),7) % 20871
    c,w = divrem((w + (w >= 10435)),5218)
    w = (w*28+[15,23,3,11][c+1]) % 1461
    return div(w,28) + 1
end

# Accessor functions
value(dt::Date) = dt.instant.days
value(dt::UTDateTime) = dt.instant.t.ms
_days(dt::Date) = value(dt)
_days(dt::DateTime) = fld(value(dt),86400000)
year(dt::TimeType) = _year(_days(dt))
month(dt::TimeType) = _month(_days(dt))
week(dt::TimeType) = _week(_days(dt))
day(dt::TimeType) = _day(_days(dt))
hour(dt::DateTime)   = mod(fld(value(dt),3600000),24)
minute(dt::DateTime) = mod(fld(value(dt),60000),60)
second(dt::DateTime) = mod(fld(value(dt),1000),60)
millisecond(dt::DateTime) = mod(value(dt),1000)

@vectorize_1arg TimeType year
@vectorize_1arg TimeType month
@vectorize_1arg TimeType day
@vectorize_1arg TimeType week
@vectorize_1arg DateTime hour
@vectorize_1arg DateTime minute
@vectorize_1arg DateTime second
@vectorize_1arg DateTime millisecond

# Conversion/Promotion
#different calendars?
#different timezones?
#different precision levels?
DateTime(dt::Date) = DateTime(year(dt),month(dt),day(dt))
Date(dt::DateTime) = Date(year(dt),month(dt),day(dt))
convert{R<:Real}(::Type{R},x::DateTime) = convert(R,value(x))
convert{R<:Real}(::Type{R},x::Date)     = convert(R,value(x))

@vectorize_1arg DateTime Date
@vectorize_1arg Date DateTime

# Traits, Equality
hash(dt::TimeType) = hash(dt.instant)
isless(x::TimeType,y::TimeType) = isless(x.instant,y.instant)
isequal(x::TimeType,y::TimeType) = isequal(x.instant,y.instant)
isfinite(::TimeType) = true
calendar{P,C}(dt::DateTime{P,C}) = C
calendar(dt::Date) = ISOCalendar
precision{P,C}(dt::DateTime{P,C}) = P
precision(dt::Date) = Day
typemax{T<:DateTime}(::Type{T}) = DateTime(292277024,12,31,23,59,59)
typemin{T<:DateTime}(::Type{T}) = DateTime(-292277023,1,1,0,0,0)
typemax(::Type{Date}) = Date(252522163911149,12,31)
typemin(::Type{Date}) = Date(-252522163911150,1,1)

# TODO: optimize this
function string(dt::DateTime)
    y,m,d = _day2date(_days(dt))
    h,mi,s = hour(dt),minute(dt),second(dt)
    yy = y < 0 ? @sprintf("%05i",y) : lpad(y,4,"0")
    mm = lpad(m,2,"0")
    dd = lpad(d,2,"0")
    hh = lpad(h,2,"0")
    mii = lpad(mi,2,"0")
    ss = lpad(s,2,"0")
    ms = millisecond(dt) == 0 ? "" : string(millisecond(dt)/1000.0)[2:end]
    return "$yy-$mm-$(dd)T$hh:$mii:$ss$ms"
end
show(io::IO,x::DateTime) = print(io,string(x))
function string(dt::Date)
    y,m,d = _day2date(value(dt))
    yy = y < 0 ? @sprintf("%05i",y) : lpad(y,4,"0")
    mm = lpad(m,2,"0")
    dd = lpad(d,2,"0")
    return "$yy-$mm-$dd"
end
show(io::IO,x::Date) = print(io,string(x))

# Date functions
#TODO: make these enums
const Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday = 1,2,3,4,5,6,7
const January,February,March,April,May,June = 1,2,3,4,5,6
const July,August,September,October,November,December = 7,8,9,10,11,12
const Mon,Tue,Wed,Thu,Fri,Sat,Sun = 1,2,3,4,5,6,7
const Jan,Feb,Mar,Apr,Jun,Jul,Aug,Sep,Oct,Nov,Dec = 1,2,3,4,5,6,7,8,9,10,11,12
const DAYSOFWEEK = [1=>"Monday",2=>"Tuesday",3=>"Wednesday",
                    4=>"Thursday",5=>"Friday",6=>"Saturday",7=>"Sunday"]
const DAYSOFWEEKABBR = [1=>"Mon",2=>"Tue",3=>"Wed",
                        4=>"Thu",5=>"Fri",6=>"Sat",7=>"Sun"]
const MONTHS = [1=>"January",2=>"February",3=>"March",4=>"April",
                5=>"May",6=>"June",7=>"July",8=>"August",9=>"September",
                10=>"October",11=>"November",12=>"December"]
const MONTHSABBR = [1=>"Jan",2=>"Feb",3=>"Mar",4=>"Apr",
                    5=>"May",6=>"Jun",7=>"Jul",8=>"Aug",9=>"Sep",
                    10=>"Oct",11=>"Nov",12=>"Dec"]

monthname(dt::TimeType) = MONTHS[month(dt)]
monthabbr(dt::TimeType) = MONTHSABBR[month(dt)]
dayname(dt::TimeType) = DAYSOFWEEK[dayofweek(dt)]
dayabbr(dt::TimeType) = DAYSOFWEEKABBR[dayofweek(dt)]

const DAYSINMONTH = Int64[31,28,31,30,31,30,31,31,30,31,30,31]
_isleap(y) = ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)
function _lastdayofmonth(y,m)
    d = DAYSINMONTH[m]::Int64
    return d + (m == 2 && _isleap(y))
end
isleap(dt::TimeType) = _isleap(year(dt))
lastdayofmonth(dt::TimeType) = _lastdayofmonth(year(dt),month(dt))
firstdayofmonth(dt::Date) = Date(year(dt),month(dt),1)
firstdayofmonth(dt::DateTime) = DateTime(year(dt),month(dt),1)
# Sunday = 0, Monday = 1....Saturday = 6
dayofweek(dt::TimeType) = (_ = _days(dt) % 7; return _ == 0 ? 7 : _)
# i.e. 1st Monday? 2nd Monday? 3rd Wednesday? 5th Sunday?
dayofweekofmonth(dt::TimeType) = (d = day(dt); return d < 8 ? 1 : 
    d < 15 ? 2 : d < 22 ? 3 : d < 29 ? 4 : 5)
# Total number of a day of week in the month
# i.e. are there 4 or 5 Mondays in this month?
function daysofweekinmonth(dt::TimeType)
    d,ld = day(dt),lastdayofmonth(dt)
    return ld == 28 ? 4 : ld == 29 ? ((d in [1,8,15,22,29]) ? 5 : 4) :
           ld == 30 ? ((d in [1,2,8,9,15,16,22,23,29,30]) ? 5 : 4) :
           (d in [1,2,3,8,9,10,15,16,17,22,23,24,29,30,31]) ? 5 : 4
end

firstdayofweek(dt::Date) = Date(dt.instant - dayofweek(dt) + Day(1))
firstdayofweek(dt::DateTime) = DateTime(firstdayofweek(Date(dt)))
lastdayofweek(dt::Date) = Date(dt.instant + (7-dayofweek(dt)))
lastdayofweek(dt::DateTime) = DateTime(lastdayofweek(Date(dt)))
dayofyear(dt::TimeType) = _days(dt) - totaldays(year(dt),1,1) + 1

@vectorize_1arg TimeType isleap
@vectorize_1arg TimeType lastdayofmonth
@vectorize_1arg TimeType dayofweek
@vectorize_1arg TimeType dayofweekofmonth
@vectorize_1arg TimeType daysofweekinmonth
@vectorize_1arg TimeType firstdayofweek
@vectorize_1arg TimeType lastdayofweek
@vectorize_1arg TimeType dayofyear