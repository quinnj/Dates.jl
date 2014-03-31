abstract AbstractTime

abstract Period     <: AbstractTime
abstract DatePeriod <: Period
abstract TimePeriod <: Period

immutable Year <: DatePeriod
    years::Int64
    Year(x::Integer) = new(int64(x))
end
immutable Month <: DatePeriod
    months::Int64
    Month(x::Integer) = new(int64(x))
end
immutable Week <: DatePeriod
    weeks::Int64
    Week(x::Integer) = new(int64(x))
end
immutable Day <: DatePeriod
    days::Int64
    Day(x::Integer) = new(int64(x))
end

immutable Hour <: TimePeriod
    h::Int64
    Hour(x::Integer) = new(int64(x))
end
immutable Minute <: TimePeriod
    m::Int64
    Minute(x::Integer) = new(int64(x))
end
immutable Second <: TimePeriod
    s::Int64
    Second(x::Integer) = new(int64(x))
end
immutable Millisecond <: TimePeriod
    ms::Int64
    Millisecond(x::Integer) = new(int64(x))
end

# Instant types represent different monotonically increasing timelines
abstract Instant

# UTInstant is based on UT seconds, or 1/86400th of a turn of the earth
immutable UTInstant{P<:Period} <: Instant
    t::P
end

# Convenience default constructor
UTInst(x) = UTInstant(Millisecond(x))

# Calendar types provide dispatch rules for interpretating instant 
# timelines in human-readable form. Calendar types are used as
# type tags in the DateTime type for dispatching to methods
# implementing the Instant=>Human-Form conversion rules.
abstract Calendar

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
    instant::Day
    # This is to prevent Date(2013) from auto-converting to
    # Date(Day(2013))
    Date(x::Day) = new(x)
end

# Convert y,m,d to # of Rata Die days
const MONTHDAYS = [306,337,0,31,61,92,122,153,184,214,245,275]
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
    return UTDateTime(UTInst(rata))
end

function Date(y,m=1,d=1)
    0 < m < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    return Date(Day(totaldays(y,m,d)))
end