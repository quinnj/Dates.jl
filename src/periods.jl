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

#=
# Date/DateTime Ranges
# Given a start and end date, how many steps/periods are in between
function Base.length{T<:TimeType,P<:Period}(r::StepRange{T,P})
    isempty(r) && return 0
    start,stop = r.start > r.stop ? (r.stop,r.start) : (r.start,r.stop)
    step = r.step < zero(r.step) ? -r.step : r.step
    t = start
    len = 1
    while (t+step) <= stop
        t += step
        len += 1
    end
    return len
end

# Given a start and stop date, calculate the difference between
# the given stop date and the last valid date given the Period step
# last = stop - steprem(start,stop,step)
Base.steprem(a::Date,b::Date,c::Day) = (b-a) % c
Base.steprem(a::DateTime,b::DateTime,c::Millisecond) = (b-a) % c
function Base.steprem(start::TimeType,stop::TimeType,step::Period)
    start,stop = start > stop ? (stop,start) : (start,stop)
    t = start
    while (t+step) <= stop
        t += step
    end
    return t
end



# Specialize for Date-Day, DateTime-Millisecond?
import Base.in
# TODO: use binary search
function in{T<:TimeType,S<:Period}(x, r::StepRange{T,S})
    isempty(r) && return false
    for d in r
        d == x && return true
    end
    return false
end
=#