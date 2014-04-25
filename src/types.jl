abstract AbstractTime

abstract Period     <: AbstractTime
abstract DatePeriod <: Period
abstract TimePeriod <: Period

immutable Year <: DatePeriod
    value::Int64
end
immutable Month <: DatePeriod
    value::Int64
end
immutable Week <: DatePeriod
    value::Int64
end
immutable Day <: DatePeriod
    value::Int64
end

immutable Hour <: TimePeriod
    value::Int64
end
immutable Minute <: TimePeriod
    value::Int64
end
immutable Second <: TimePeriod
    value::Int64
end
immutable Millisecond <: TimePeriod
    value::Int64
end

# Instant types represent different monotonically increasing timelines
abstract Instant <: AbstractTime

# UTInstant is based on UT seconds, or 1/86400th of a turn of the earth
immutable UTInstant{P<:Period} <: Instant
    periods::P
end

# Convenience default constructors
UTM(x) = UTInstant(Millisecond(x))
UTD(x) = UTInstant(Day(x))

# Calendar types provide dispatch rules for interpretating instant 
# timelines in human-readable form. Calendar types are used as
# type tags in the DateTime type for dispatching to methods
# implementing the Instant=>Human-Form conversion rules.
abstract Calendar <: AbstractTime

# ISOCalendar implements the ISO 8601 standard (en.wikipedia.org/wiki/ISO_8601)
# Notably based on the proleptic Gregorian calendar
# ISOCalendar provides interpretation rules for UTInstants to UT
immutable ISOCalendar <: Calendar end

# TimeTypes wrap Instants to provide human representations of time
abstract TimeType <: AbstractTime

# A DateTime type couples an Instant type with a Calendar type
# to provide convenient human-conversion rules carried out
# by multiple dispatch.
immutable DateTime{T<:Instant,C<:Calendar} <: TimeType
    instant::T
    DateTime(x::T) = new(x)
end 

typealias UTDateTime DateTime{UTInstant{Millisecond},ISOCalendar}

immutable Date <: TimeType
    instant::UTInstant{Day}
    Date(x::UTInstant{Day}) = new(x)
end

# Convert y,m,d to # of Rata Die days
const MONTHDAYS = Int64[306,337,0,31,61,92,122,153,184,214,245,275]
function totaldays(y,m,d)
    z = m < 3 ? y - 1 : y
    mdays = MONTHDAYS[m]::Int64
    return d + mdays + 365z + fld(z,4) - fld(z,100) + fld(z,400) - 306
end

### CONSTRUCTORS ###
# Core constructors
function DateTime(y::Int64,m::Int64=1,d::Int64=1,
                  h::Int64=0,mi::Int64=0,s::Int64=0,ms::Int64=0)
    0 < m < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    rata = ms + 1000*(s + 60mi + 3600h + 86400*totaldays(y,m,d))
    return UTDateTime(UTM(rata))
end
function Date(y::Int64,m::Int64=1,d::Int64=1)
    0 < m < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    return Date(UTD(totaldays(y,m,d)))
end

# Convenience constructors from Periods
function DateTime(y::Year=Year(1),m::Month=Month(1),d::Day=Day(1),
                  h::Hour=Hour(0),mi::Minute=Minute(0),
                  s::Second=Second(0),ms::Millisecond=Millisecond(0))
    return DateTime(value(y),value(m),value(d),
                        value(h),value(mi),value(s),value(ms))
end
DateTime(x::Period...) = throw(ArgumentError("Required argument order is DateTime(y[,m,d,h,mi,s,ms])"))

Date(y::Year,m::Month=Month(1),d::Day=Day(1)) = Date(value(y),value(m),value(d))
Date(x::Period...) = throw(ArgumentError("Required argument order is Date(y[,m,d])"))

# Fallback constructors
_c(x) = convert(Int64,x)
DateTime(y,m=1,d=1,h=0,mi=0,s=0,ms=0) = DateTime(_c(y),_c(m),_c(d),_c(h),_c(mi),_c(s),_c(ms))
Date(y,m=1,d=1) = Date(_c(y),_c(m),_c(d))

# Custom 2-arg colon constructor for DateTime
# otherwise, the default step would be Millisecond(1)
#=Base.colon{T<:DateTime}(start::T, stop::T) = Base.StepRange(start, Day(1), stop)
Base.rem{P<:Period}(::Millisecond,::P) = zero(P)
Base.div{P<:Period}(::Millisecond,::P) = zero(P)=#


# Range tests
# IO work: more robust, better, quicker errors, tests, test, tests...
# Period conversions?
# more work on recur
# perf.jl
# docs

# Longer term
 # Timezone parameter to DateTime?
 # Timezone.jl package
