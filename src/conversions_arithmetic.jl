### truncation
Base.trunc(dt::Date,p::Type{Year}) = Date(UTD(totaldays(year(dt),1,1)))
Base.trunc(dt::Date,p::Type{Month}) = firstdayofmonth(dt)
Base.trunc(dt::Date,p::Type{Day}) = dt

Base.trunc(dt::DateTime,p::Type{Year}) = DateTime(trunc(Date(dt),Year))
Base.trunc(dt::DateTime,p::Type{Month}) = DateTime(trunc(Date(dt),Month))
Base.trunc(dt::DateTime,p::Type{Day}) = DateTime(Date(dt))
Base.trunc(dt::DateTime,p::Type{Hour}) = dt - Minute(minute(dt)) - Second(second(dt)) - Millisecond(millisecond(dt))
Base.trunc(dt::DateTime,p::Type{Minute}) = dt - Second(second(dt)) - Millisecond(millisecond(dt))
Base.trunc(dt::DateTime,p::Type{Second}) = dt - Millisecond(millisecond(dt))
Base.trunc(dt::DateTime,p::Type{Millisecond}) = dt

### Conversions
const UNIXEPOCH = value(DateTime(1970)) #Rata Die milliseconds for 1970-01-01T00:00:00 UTC
function unix2date(x)
    rata = UNIXEPOCH + int64(1000*x)
    return DateTime(UTM(rata))
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
    return DateTime(UTM(rata))
end
# Returns # of julian days since -4713-11-24T12:00:00 UTC
date2julian(dt::DateTime) = (value(dt) - JULIANEPOCH)/86400000.0

# Instant arithmetic
for op in (:+,:*,:%,:/)
    @eval ($op)(x::Instant,y::Instant) = throw(ArgumentError("Operation not defined for Instants"))
end
(+)(x::Instant) = x
(-){T<:Instant}(x::T,y::T) = x.periods - y.periods

# DateTime arithmetic
for op in (:+,:*,:%,:/)
    @eval ($op)(x::TimeType,y::TimeType) = throw(ArgumentError("Operation not defined for TimeTypes"))
end
(+)(x::TimeType) = x
(-){T<:TimeType}(x::T,y::T) = x.instant - y.instant

function (+)(dt::DateTime,y::Year)
    oy,m,d = yearmonthday(dt); ny = oy+value(y); ld = daysinmonth(ny,m)
    return DateTime(ny,m,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (+)(dt::Date,y::Year)
    oy,m,d = yearmonthday(dt); ny = oy+value(y); ld = daysinmonth(ny,m)
    return Date(ny,m,d <= ld ? d : ld)
end
function (-)(dt::DateTime,y::Year)
    oy,m,d = yearmonthday(dt); ny = oy-value(y); ld = daysinmonth(ny,m)
    return DateTime(ny,m,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (-)(dt::Date,y::Year)
    oy,m,d = yearmonthday(dt); ny = oy-value(y); ld = daysinmonth(ny,m)
    return Date(ny,m,d <= ld ? d : ld)
end

# Date/DateTime-Month arithmetic
# monthwrap adds two months with wraparound behavior (i.e. 12 + 1 == 1)
monthwrap(m1,m2) = (v = mod1(m1+m2,12); return v < 0 ? 12 + v : v)
# yearwrap takes a starting year/month and a month to add and returns
# the resulting year with wraparound behavior (i.e. 2000-12 + 1 == 2001)
yearwrap(y,m1,m2) = y + fld(m1 + m2 - 1,12)

function (+)(dt::DateTime,z::Month) 
    y,m,d = yearmonthday(dt)
    ny = yearwrap(y,m,value(z))
    mm = monthwrap(m,value(z)); ld = daysinmonth(ny,mm)
    return DateTime(ny,mm,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (+)(dt::Date,z::Month) 
    y,m,d = yearmonthday(dt)
    ny = yearwrap(y,m,value(z))
    mm = monthwrap(m,value(z)); ld = daysinmonth(ny,mm)
    return Date(ny,mm,d <= ld ? d : ld)
end
function (-)(dt::DateTime,z::Month) 
    y,m,d = yearmonthday(dt)
    ny = yearwrap(y,m,-value(z))
    mm = monthwrap(m,-value(z)); ld = daysinmonth(ny,mm)
    return DateTime(ny,mm,d <= ld ? d : ld,hour(dt),minute(dt),second(dt))
end
function (-)(dt::Date,z::Month) 
    y,m,d = yearmonthday(dt)
    ny = yearwrap(y,m,-value(z))
    mm = monthwrap(m,-value(z)); ld = daysinmonth(ny,mm)
    return Date(ny,mm,d <= ld ? d : ld)
end
(+)(x::Date,y::Week) = return Date(UTD(value(x) + 7*value(y)))
(-)(x::Date,y::Week) = return Date(UTD(value(x) - 7*value(y)))
(+)(x::Date,y::Day)  = return Date(UTD(value(x) + y))
(-)(x::Date,y::Day)  = return Date(UTD(value(x) - y))
(+)(x::DateTime,y::Week)   = return DateTime(UTM(value(x)+604800000*value(y)))
(-)(x::DateTime,y::Week)   = return DateTime(UTM(value(x)-604800000*value(y)))
(+)(x::DateTime,y::Day)    = return DateTime(UTM(value(x)+86400000 *value(y)))
(-)(x::DateTime,y::Day)    = return DateTime(UTM(value(x)-86400000 *value(y)))
(+)(x::DateTime,y::Hour)   = return DateTime(UTM(value(x)+3600000  *value(y)))
(-)(x::DateTime,y::Hour)   = return DateTime(UTM(value(x)-3600000  *value(y)))
(+)(x::DateTime,y::Minute) = return DateTime(UTM(value(x)+60000    *value(y)))
(-)(x::DateTime,y::Minute) = return DateTime(UTM(value(x)-60000    *value(y)))
(+)(x::DateTime,y::Second)      = return DateTime(UTM(value(x)+1000*value(y)))
(-)(x::DateTime,y::Second)      = return DateTime(UTM(value(x)-1000*value(y)))
(+)(x::DateTime,y::Millisecond) = return DateTime(UTM(value(x)+value(y)))
(-)(x::DateTime,y::Millisecond) = return DateTime(UTM(value(x)-value(y)))
(+)(y::Period,x::TimeType) = x + y
(-)(y::Period,x::TimeType) = x - y

(.+){T<:TimeType}(x::AbstractArray{T}, y::Period) = reshape([i + y for i in x], size(x))
(.-){T<:TimeType}(x::AbstractArray{T}, y::Period) = reshape([i - y for i in x], size(x))
(.+){T<:TimeType}(y::Period, x::AbstractArray{T}) = x .+ y
(.-){T<:TimeType}(y::Period, x::AbstractArray{T}) = x .- y

# Temporal Expressions
# TODO: Allow Array{Function} as 1st argument? with and=true keyword?
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