#Period types
value{P<:Period}(x::P) = x.value

# The default constructors for Periods work well in almost all cases
# P(x) = new((convert(Int64,x))
# The following definitions are for Period-specific safety
for p in (:Year,:Month,:Week,:Day,:Hour,:Minute,:Second,:Millisecond)
    # This ensures that we can't convert between Periods
    @eval $p(x::Period) = throw(ArgumentError("Can't convert $(typeof(x)) to $($p)"))
    # Unless the Periods are the same type
    @eval $p(x::$p) = x
    # Convenience method for show()
    @eval _units(x::$p) = " " * lowercase(string($p)) * (abs(value(x)) == 1 ? "" : "s")
    # Don't allow misuse of Periods on Date/DateTime
    @eval $p(x::TimeType) = throw(ArgumentError("$($p)() is for constructing the $($p) type. Use $(lowercase(string($p)))(dt) instead"))
end
# Now we're safe to define Period-Number conversions
# Anything an Int64 can convert to, a Period can convert to
Base.convert{T<:Number}(::Type{T},x::Period) = convert(T,value(x))
# Error quickly if x can't convert losslessly to Int64
Base.convert{P<:Period}(::Type{P},x::Number) = P(convert(Int64,x))

#Print/show/traits
Base.string{P<:Period}(x::P) = string(value(x),_units(x))
Base.show(io::IO,x::Period) = print(io,string(x))
Base.zero{P<:Period}(::Union(Type{P},P)) = P(0)
Base.one{P<:Period}(::Union(Type{P},P)) = P(1)
Base.typemin{P<:Period}(::Type{P}) = P(typemin(Int64))
Base.typemax{P<:Period}(::Type{P}) = P(typemax(Int64))


(-){P<:Period}(x::P) = P(-value(x))
<{P<:Period}(x::P,y::P) = <(value(x),value(y))
=={P<:Period}(x::P,y::P) = ==(value(x),value(y))
< {R<:Real}(x::Period,y::R) = throw(ArgumentError("Can't compare Period-$R"))
=={R<:Real}(x::Period,y::R) = throw(ArgumentError("Can't compare Period-$R"))
< {R<:Real}(y::R,x::Period) = throw(ArgumentError("Can't compare Period-$R"))
=={R<:Real}(y::R,x::Period) = throw(ArgumentError("Can't compare Period-$R"))

<(x::Period,y::Period) = throw(ArgumentError("Can't compare Periods of different types"))
==(x::Period,y::Period) = throw(ArgumentError("Can't compare Periods of different types"))

#Period Arithmetic:
import Base.div
let vec_ops = [:.+,:.-,:.*,:.%,:div]
    for op in [:+,:-,:*,:%,vec_ops]
        @eval begin
        #Period-Period
        ($op){P<:Period}(x::P,y::P) = P(($op)(value(x),value(y)))
        #Period-Integer
        ($op){P<:Period}(x::P,y::Integer) = P(($op)(value(x),int64(y)))
        ($op){P<:Period}(x::Integer,y::P) = P(($op)(int64(x),value(y)))
        #Period-Real
        ($op){P<:Period}(x::P,y::Real) = P(($op)(value(x),convert(Int64,y)))
        ($op){P<:Period}(x::Real,y::P) = P(($op)(convert(Int64,x),value(y)))
        end
        #Vectorized
        if op in vec_ops
            @eval begin
            ($op){P<:Period}(x::AbstractArray{P}, y::P) = reshape([$op(i,y) for i in x], size(x))
            ($op){P<:Period}(y::P, x::AbstractArray{P}) = reshape([$op(i,y) for i in x], size(x))
            end
        end
    end
end

periodisless(::Period,::Year)        = true
periodisless(::Period,::Month)       = true
periodisless(::Year,::Month)         = false
periodisless(::Period,::Week)        = true
periodisless(::Year,::Week)          = false
periodisless(::Month,::Week)         = false
periodisless(::Period,::Day)         = true
periodisless(::Year,::Day)           = false
periodisless(::Month,::Day)          = false
periodisless(::Week,::Day)           = false
periodisless(::Period,::Hour)        = false
periodisless(::Minute,::Hour)        = true
periodisless(::Second,::Hour)        = true
periodisless(::Millisecond,::Hour)   = true
periodisless(::Period,::Minute)      = false
periodisless(::Second,::Minute)      = true
periodisless(::Millisecond,::Minute) = true
periodisless(::Period,::Second)      = false
periodisless(::Millisecond,::Second) = true
periodisless(::Period,::Millisecond) = false

# Stores multiple periods in greatest to least order by type, not values
type CompoundPeriod
    periods::Array{Period,1}
end
function Base.string(x::CompoundPeriod)
    s = ""
    for p in x.periods
        s *= ", " * string(p)
    end
    return s[3:end]
end
Base.show(io::IO,x::CompoundPeriod) = print(io,string(x))
# E.g. Year(1) + Day(1)
(+)(x::Period,y::Period) = CompoundPeriod(sort!(Period[x,y],rev=true,lt=periodisless))
(+)(x::CompoundPeriod,y::Period) = (sort!(push!(x.periods,y) ,rev=true,lt=periodisless); return x)
# E.g. Year(1) - Month(1)
(-)(x::Period,y::Period) = CompoundPeriod(sort!(Period[x,-y],rev=true,lt=periodisless))
(-)(x::CompoundPeriod,y::Period) = (sort!(push!(x.periods,-y),rev=true,lt=periodisless); return x)

function (+)(x::TimeType,y::CompoundPeriod)
    for p in y.periods
        x += p
    end
    return x
end
(+)(x::CompoundPeriod,y::TimeType) = y + x

# Date/DateTime Ranges
# Given a start and end date, how many steps/periods are in between
to_days(x::Year) = itrunc(value(x)*365.2425)
to_days(x::Month) = itrunc(value(x)*30.436875)
to_days(x::Week) = value(x)*7
to_days(x::Day) = value(x)

function Base.length{T<:TimeType,P<:Period}(r::StepRange{T,P})
    r.start > r.stop && r.step == one(r.step) && return 0
    start,stop = r.start > r.stop ? (r.stop,r.start) : (r.start,r.stop)
    step = r.step < oftype(r.step,0) ? -r.step : r.step
    t = start
    len = 1
    while (t+step) <= stop
        t += step
        len += 1
    end
    return len
end

to_ms(x::Year) = itrunc(value(x)*365.2425*86400000.0)
to_ms(x::Month) = itrunc(value(x)*30.426875*86400000.0)
to_ms(x::Week) = value(x)*7*86400000
to_ms(x::Day) = value(x)*86400000
to_ms(x::Hour) = value(x)*3600000
to_ms(x::Minute) = value(x)*60000
to_ms(x::Second) = value(x)*1000
to_ms(x::Millisecond) = value(x)

#=function Base.length{T<:DateTime,P<:Period}(r::StepRange{T,P})
    n = integer(div(r.stop+r.step - r.start, to_ms(r.step)))
    isempty(r) ? zero(n) : n
end=#

# Given a start and stop date, calculate the difference between
# the given stop date and the last valid date given the Period step
# last = stop - steprem(start,stop,step)
Base.steprem(a::Date,b::Date,c::Day) = (b-a) % c
Base.steprem(a::DateTime,b::DateTime,c::Millisecond) = (b-a) % c

function Base.steprem(start::TimeType,stop::TimeType,step::Period)
    start,stop = start > stop ? (stop,start) : (start,stop)
    step = step < oftype(step,0) ? -step : step
    t = start
    while (t+step) <= stop
        t += step
    end
    return stop - t
end

# Specialize for Date-Day, DateTime-Millisecond?
import Base.in
function in{T<:TimeType,S<:Period}(x, r::StepRange{T,S})
    step(r) == zero(S) && return x == first(r)
    for d in r
        d == x && return true
    end
    return false
end

# Need intersect