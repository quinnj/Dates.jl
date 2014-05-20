# Date functions

### Core date functions

# Monday = 1....Sunday = 7
dayofweek(days) = mod1(days,7)

# If the year is divisible by 4, except for every 100 years, except for every 400 years
isleap(y) = ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)

# Number of days in month
const DAYSINMONTH = Int64[31,28,31,30,31,30,31,31,30,31,30,31]
daysinmonth(y,m) = DAYSINMONTH[m] + (m == 2 && isleap(y))

# Number of days in year
daysinyear(y) = 365 + isleap(y)

# Day of the year
const MONTHDAYS2 = Int64[0,31,59,90,120,151,181,212,243,273,304,334]
dayofyear(y,m,d) = MONTHDAYS2[m] + d + (m > 2 && isleap(y))


### Weeks/Days of the Week
const Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday = 1,2,3,4,5,6,7
const Mon,Tue,Wed,Thu,Fri,Sat,Sun = 1,2,3,4,5,6,7
const DAYSOFWEEK = [1=>"Monday",2=>"Tuesday",3=>"Wednesday",
                    4=>"Thursday",5=>"Friday",6=>"Saturday",7=>"Sunday"]
const DAYSOFWEEKABBR = [1=>"Mon",2=>"Tue",3=>"Wed",
                        4=>"Thu",5=>"Fri",6=>"Sat",7=>"Sun"]
dayname(dt::TimeType) = DAYSOFWEEK[dayofweek(dt)]
dayabbr(dt::TimeType) = DAYSOFWEEKABBR[dayofweek(dt)]

dayofweek(dt::TimeType) = dayofweek(_days(dt))

# i.e. 1st Monday? 2nd Monday? 3rd Wednesday? 5th Sunday?
dayofweekofmonth(dt::TimeType) = (d = day(dt); return d < 8 ? 1 : 
    d < 15 ? 2 : d < 22 ? 3 : d < 29 ? 4 : 5)

# Total number of a day of week in the month
# i.e. are there 4 or 5 Mondays in this month?
const TWENTYNINE = IntSet(1,8,15,22,29)
const THIRTY = IntSet(1,2,8,9,15,16,22,23,29,30)
const THIRTYONE = IntSet(1,2,3,8,9,10,15,16,17,22,23,24,29,30,31)
function daysofweekinmonth(dt::TimeType)
    y,m,d = yearmonthday(dt)
    ld = daysinmonth(y,m)
    return ld == 28 ? 4 : ld == 29 ? ((d in TWENTYNINE) ? 5 : 4) :
           ld == 30 ? ((d in THIRTY) ? 5 : 4) :
           (d in THIRTYONE) ? 5 : 4
end

@vectorize_1arg TimeType dayname
@vectorize_1arg TimeType dayabbr
@vectorize_1arg TimeType dayofweek
@vectorize_1arg TimeType dayofweekofmonth
@vectorize_1arg TimeType daysofweekinmonth

### Months
const January,February,March,April,May,June = 1,2,3,4,5,6
const July,August,September,October,November,December = 7,8,9,10,11,12
const Jan,Feb,Mar,Apr,Jun,Jul,Aug,Sep,Oct,Nov,Dec = 1,2,3,4,5,6,7,8,9,10,11,12
const MONTHS = [1=>"January",2=>"February",3=>"March",4=>"April",
                5=>"May",6=>"June",7=>"July",8=>"August",9=>"September",
                10=>"October",11=>"November",12=>"December"]
const MONTHSABBR = [1=>"Jan",2=>"Feb",3=>"Mar",4=>"Apr",
                    5=>"May",6=>"Jun",7=>"Jul",8=>"Aug",9=>"Sep",
                    10=>"Oct",11=>"Nov",12=>"Dec"]
monthname(dt::TimeType) = MONTHS[month(dt)]
monthabbr(dt::TimeType) = MONTHSABBR[month(dt)]

daysinmonth(dt::TimeType) = daysinmonth(yearmonth(dt)...)

@vectorize_1arg TimeType monthname
@vectorize_1arg TimeType monthabbr
@vectorize_1arg TimeType daysinmonth

### Years
isleap(dt::TimeType) = isleap(year(dt))

dayofyear(dt::TimeType) = dayofyear(yearmonthday(dt)...)

daysinyear(dt::TimeType) = 365 + isleap(dt)

@vectorize_1arg TimeType isleap
@vectorize_1arg TimeType dayofyear
@vectorize_1arg TimeType daysinyear

### Quarters
function quarterofyear(dt::TimeType)
    m = month(dt)
    return m < 4 ? 1 : m < 7 ? 2 : m < 10 ? 3 : 4
end
const QUARTERDAYS = [0,90,181,273]
dayofquarter(dt::TimeType) = dayofyear(dt) - QUARTERDAYS[quarterofyear(dt)]

@vectorize_1arg TimeType quarterofyear
@vectorize_1arg TimeType dayofquarter