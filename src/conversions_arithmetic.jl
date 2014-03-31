const UNIXEPOCH = value(DateTime(1970)) #Rata Die milliseconds for 1970-01-01T00:00:00 UTC
function unix2date(x)
    rata = UNIXEPOCH + int64(1000*x)
    return UTDateTime(UTInst(rata))
end
# Returns unix seconds since 1970-01-01T00:00:00 UTC
date2unix(dt::DateTime) = (value(dt) - UNIXEPOCH)/1000.0
now() = unix2date(time())

ratadays2date(days) = _day2date(days)
date2ratadays(dt::TimeType) = _days(dt)

# Julian conversions
const JULIANEPOCH = value(DateTime(-4713,11,24,12))
function julian2date(f)
    rata = JULIANEPOCH + int64(86400000*f)
    return UTDateTime(UTInst(rata))
end
# Returns # of julian days since -4713-11-24T12:00:00 UTC
date2julian(dt::DateTime) = (value(dt) - JULIANEPOCH)/86400000.0

#wrapping arithmetic
monthwrap(m1,m2) = (v = (m1 + m2) % 12; return v == 0 ? 12 : v < 0 ? 12 + v : v)
yearwrap(y,m1,m2) = y + fld(m1 + m2 - 1,12)

#DateTime arithmetic
for op in (:+,:*,:%,:/)
    @eval ($op)(x::TimeType,y::TimeType) = error("Operation not defined for TimeTypes")
end
(+)(x::TimeType) = x
(-){T<:TimeType}(x::T,y::T) = x.instant - y.instant

function (+)(dt::DateTime,y::Year)
    oy,m,d = _day2date(_days(dt)); ny = oy+y.years; ld = _lastdayofmonth(ny,m)
    return DateTime(ny,m,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (+)(dt::Date,y::Year)
    oy,m,d = _day2date(_days(dt)); ny = oy+y.years; ld = _lastdayofmonth(ny,m)
    return Date(ny,m,d <= ld ? d : ld)
end
function (-)(dt::DateTime,y::Year)
    oy,m,d = _day2date(_days(dt)); ny = oy-y.years; ld = _lastdayofmonth(ny,m)
    return DateTime(ny,m,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (-)(dt::Date,y::Year)
    oy,m,d = _day2date(_days(dt)); ny = oy-y.years; ld = _lastdayofmonth(ny,m)
    return Date(ny,m,d <= ld ? d : ld)
end
function (+)(dt::DateTime,z::Month) 
    y,m,d = _day2date(_days(dt))
    ny = yearwrap(y,m,z.months)
    mm = monthwrap(m,z.months); ld = _lastdayofmonth(ny,mm)
    return DateTime(ny,mm,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (+)(dt::Date,z::Month) 
    y,m,d = _day2date(_days(dt))
    ny = yearwrap(y,m,z.months)
    mm = monthwrap(m,z.months); ld = _lastdayofmonth(ny,mm)
    return Date(ny,mm,d <= ld ? d : ld)
end
function (-)(dt::DateTime,z::Month) 
    y,m,d = _day2date(_days(dt))
    ny = yearwrap(y,m,-z.months)
    mm = monthwrap(m,-z.months); ld = _lastdayofmonth(ny,mm)
    return DateTime(ny,mm,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (-)(dt::Date,z::Month) 
    y,m,d = _day2date(_days(dt))
    ny = yearwrap(y,m,-z.months)
    mm = monthwrap(m,-z.months); ld = _lastdayofmonth(ny,mm)
    return Date(ny,mm,d <= ld ? d : ld)
end
(+)(x::Date,y::Week) = return Date(x.instant + 7*y.weeks)
(-)(x::Date,y::Week) = return Date(x.instant - 7*y.weeks)
(+)(x::Date,y::Day)  = return Date(x.instant + y.days)
(-)(x::Date,y::Day)  = return Date(x.instant - y.days)
(+)(x::DateTime,y::Week)   = return UTDateTime(UTInst(value(x)+604800000*value(y)))
(-)(x::DateTime,y::Week)   = return UTDateTime(UTInst(value(x)-604800000*value(y)))
(+)(x::DateTime,y::Day)    = return UTDateTime(UTInst(value(x)+86400000 *value(y)))
(-)(x::DateTime,y::Day)    = return UTDateTime(UTInst(value(x)-86400000 *value(y)))
(+)(x::DateTime,y::Hour)   = return UTDateTime(UTInst(value(x)+3600000  *value(y)))
(-)(x::DateTime,y::Hour)   = return UTDateTime(UTInst(value(x)-3600000  *value(y)))
(+)(x::DateTime,y::Minute) = return UTDateTime(UTInst(value(x)+60000    *value(y)))
(-)(x::DateTime,y::Minute) = return UTDateTime(UTInst(value(x)-60000    *value(y)))
(+)(x::DateTime,y::Second)      = return UTDateTime(UTInst(value(x)+1000*y.s))
(-)(x::DateTime,y::Second)      = return UTDateTime(UTInst(value(x)-1000*y.s))
(+)(x::DateTime,y::Millisecond) = return UTDateTime(UTInst(value(x)+y.ms))
(-)(x::DateTime,y::Millisecond) = return UTDateTime(UTInst(value(x)-y.ms))
(+)(y::Period,x::TimeType) = x + y
(-)(y::Period,x::TimeType) = x - y
typealias TimeTypePeriod Union(TimeType,Period)
(+){T<:TimeTypePeriod}(x::TimeTypePeriod, y::AbstractArray{T}) = reshape([x + y[i] for i in 1:length(y)], size(y))
(+){T<:TimeTypePeriod}(x::AbstractArray{T}, y::TimeTypePeriod) = reshape([x[i] + y for i in 1:length(x)], size(x))
(-){T<:TimeTypePeriod}(x::TimeTypePeriod, y::AbstractArray{T}) = reshape([x - y[i] for i in 1:length(y)], size(y))
(-){T<:TimeTypePeriod}(x::AbstractArray{T}, y::TimeTypePeriod) = reshape([x[i] - y for i in 1:length(x)], size(x))

# Temporal Expressions
function recur{T<:TimeType}(fun::Function,start::T,stop::T,step::Period=Day(1);inclusion=true)
    a = T[]
    negate = inclusion ? identity : (!)
    i = start
    while i <= stop
        negate(fun(i)) && (push!(a,i))
        i += step
    end
    return a
end
# TODO: Allow Array{Function} as 1st argument? with and=true keyword?