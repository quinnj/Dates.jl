abstract AbstractTime

abstract Period     <: AbstractTime
abstract DatePeriod <: Period
abstract TimePeriod <: Period

immutable Year <: DatePeriod
    value::Int64
    Year(x::Integer) = new(int64(x))
end
immutable Month <: DatePeriod
    value::Int64
    Month(x::Integer) = new(int64(x))
end
immutable Week <: DatePeriod
    value::Int64
    Week(x::Integer) = new(int64(x))
end
immutable Day <: DatePeriod
    value::Int64
    Day(x::Integer) = new(int64(x))
end

immutable Hour <: TimePeriod
    value::Int64
    Hour(x::Integer) = new(int64(x))
end
immutable Minute <: TimePeriod
    value::Int64
    Minute(x::Integer) = new(int64(x))
end
immutable Second <: TimePeriod
    value::Int64
    Second(x::Integer) = new(int64(x))
end
immutable Millisecond <: TimePeriod
    value::Int64
    Millisecond(x::Integer) = new(int64(x))
end

# Instant types represent different monotonically increasing timelines
abstract Instant{P<:Period} <: AbstractTime

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
end 

typealias UTDateTime DateTime{UTInstant{Millisecond},ISOCalendar}

immutable Date <: TimeType
    instant::UTInstant{Day}
end

# Convert y,m,d to # of Rata Die days
const MONTHDAYS = Int64[306,337,0,31,61,92,122,153,184,214,245,275]
function totaldays(y,m,d)
    z = m < 3 ? y - 1 : y
    mdays = MONTHDAYS[m]::Int64
    return d + mdays + 365z + fld(z,4) - fld(z,100) + fld(z,400) - 306
end

# DateTime constructor with defaults
function DateTime(y::Integer,m::Integer=1,d::Integer=1,
                  h::Integer=0,mi::Integer=0,s::Integer=0,ms::Integer=0)
    0 < m < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    rata = ms + 1000*(s + 60mi + 3600h + 86400*totaldays(y,m,d))
    return UTDateTime(UTM(rata))
end

function Date(y::Integer,m::Integer=1,d::Integer=1)
    0 < m < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    return Date(UTD(totaldays(y,m,d)))
end