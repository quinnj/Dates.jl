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

# TODO: optimize this?
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
const Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday = 1,2,3,4,5,6,0
const January,February,March,April,May,June = 1,2,3,4,5,6
const July,August,September,October,November,December = 7,8,9,10,11,12
const Mon,Tue,Wed,Thu,Fri,Sat,Sun = 1,2,3,4,5,6,0
const Jan,Feb,Mar,Apr,Jun,Jul,Aug,Sep,Oct,Nov,Dec = 1,2,3,4,5,6,7,8,9,10,11,12
const DAYSOFWEEK = [1=>"Monday",2=>"Tuesday",3=>"Wednesday",
                    4=>"Thursday",5=>"Friday",6=>"Saturday",0=>"Sunday"]
const DAYSOFWEEKABBR = [1=>"Mon",2=>"Tue",3=>"Wed",
                        4=>"Thu",5=>"Fri",6=>"Sat",0=>"Sun"]
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

const DAYSINMONTH = [31,28,31,30,31,30,31,31,30,31,30,31]
_isleap(y) = ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)
function _lastdayofmonth(y,m)
    @inbounds d = DAYSINMONTH[m]
    return d + (m == 2 && _isleap(y))
end
isleap(dt::TimeType) = _isleap(year(dt))
lastdayofmonth(dt::TimeType) = _lastdayofmonth(year(dt),month(dt))
firstdayofmonth(dt::Date) = Date(year(dt),month(dt),1)
firstdayofmonth(dt::DateTime) = DateTime(year(dt),month(dt),1)
# Sunday = 0, Monday = 1....Saturday = 6
dayofweek(dt::TimeType) = _days(dt) % 7
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
function firstdayofweek(dt::DateTime)
    d = firstdayofweek(Date(dt))
    return DateTime(d)
end
firstdayofweek(dt::Date) = Date(dt.instant - dayofweek(dt))
function lastdayofweek(dt::DateTime)
    d = lastdayofweek(Date(dt))
    return DateTime(d)
end
lastdayofweek(dt::Date) = Date(dt.instant + (6-dayofweek(dt)))
dayofyear(dt::TimeType) = _days(dt) - totaldays(year(dt),1,1) + 1

@vectorize_1arg TimeType isleap
@vectorize_1arg TimeType lastdayofmonth
@vectorize_1arg TimeType dayofweek
@vectorize_1arg TimeType dayofweekofmonth
@vectorize_1arg TimeType daysofweekinmonth
@vectorize_1arg TimeType firstdayofweek
@vectorize_1arg TimeType lastdayofweek
@vectorize_1arg TimeType dayofyear