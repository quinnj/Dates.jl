#Period types
value(x::Year)          = x.years
value(x::Month)         = x.months
value(x::Week)          = x.weeks
value(x::Day)           = x.days
value(x::Hour)          = x.h
value(x::Minute)        = x.m
value(x::Second)        = x.s
value(x::Millisecond)   = x.ms
for p in (:Year,:Month,:Week,:Day,:Hour,:Minute,:Second,:Millisecond)
    @eval $p(x::$p) = x
end
convert{R<:Real}(::Type{R},x::Period) = convert(R,value(x))
convert{P<:Period}(::Type{P},x::Real) = P(int64(x))

#Print/show/traits
_units(x::Period) = " " * lowercase(string(typeof(x).name)) * (abs(value(x)) == 1 ? "" : "s")
string{P<:Period}(x::P) = string(value(x),_units(x))
show(io::IO,x::Period) = print(io,string(x))
typemin{P<:Period}(::Type{P}) = P(typemin(Int64))
typemax{P<:Period}(::Type{P}) = P(typemax(Int64))


(-){P<:Period}(x::P) = P(-value(x))
isless{P<:Period}(x::P,y::P) = isless(value(x),value(y))
isequal{P<:Period}(x::P,y::P) = isequal(value(x),value(y))

#Period Arithmetic:
for op in (:+,:-,:*,:%,:div)
    @eval begin
    #Period-Period
    ($op){P<:Period}(x::P,y::P) = P(($op)(value(x),value(y)))
    ($op){P<:Period}(x::P, y::AbstractArray{P}) = reshape([P(($op)(value(x), value(y[i]))) for i in 1:length(y)], size(y))
    ($op){P<:Period}(x::AbstractArray{P}, y::P) = reshape([P(($op)(value(x[i]), value(y))) for i in 1:length(x)], size(x))
    #Period-Real
    ($op){P<:Period}(x::P,y::Real) = P(($op)(value(x),int64(y)))
    ($op){P<:Period}(x::Real,y::P) = P(($op)(int64(x),value(y)))
    end
end

periodisless{P<:Period}(::Type{P},::Type{Year}) = true
periodisless{P<:Period}(::Type{P},::Type{Month}) = true
periodisless(::Type{Year},::Type{Month}) = false
periodisless{P<:Period}(::Type{P},::Type{Week}) = true
periodisless(::Type{Year},::Type{Week}) = false
periodisless(::Type{Month},::Type{Week}) = false
periodisless{P<:Period}(::Type{P},::Type{Day}) = true
periodisless(::Type{Year},::Type{Day}) = false
periodisless(::Type{Month},::Type{Day}) = false
periodisless(::Type{Week},::Type{Day}) = false
periodisless{P<:Period}(::Type{P},::Type{Hour}) = false
periodisless(::Type{Minute},::Type{Hour}) = true
periodisless(::Type{Second},::Type{Hour}) = true
periodisless(::Type{Millisecond},::Type{Hour}) = true
periodisless{P<:Period}(::Type{P},::Type{Minute}) = false
periodisless(::Type{Second},::Type{Minute}) = true
periodisless(::Type{Millisecond},::Type{Minute}) = true
periodisless{P<:Period}(::Type{P},::Type{Second}) = false
periodisless(::Type{Millisecond},::Type{Second}) = true
periodisless{P<:Period}(::Type{P},::Type{Millisecond}) = false

periodisless{P1<:Period,P2<:Period}(x::P1,y::P2) = periodisless(P1,P2)
isless(x::Period,y::Period) = error("Can't compare Periods of different types")
isequal(x::Period,y::Period) = error("Can't compare Periods of different types")
isless(x::Period,y::Real) = error("Can't compare Period-Real")
isequal(x::Period,y::Real) = error("Can't compare Period-Real")
isless(y::Real,x::Period) = error("Can't compare Period-Real")
isequal(y::Real,x::Period) = error("Can't compare Period-Real")

# Stores multiple periods in greatest to least order by units, not values
type CompoundPeriod
    periods::Array{Period,1}
end
function string(x::CompoundPeriod)
    s = ""
    for p in x.periods
        s *= ", " * string(p)
    end
    return s[3:end]
end
show(io::IO,x::CompoundPeriod) = print(io,string(x))
# Year(1) + Day(1)
(+){P1<:Period,P2<:Period}(x::P1,y::P2) = CompoundPeriod(sort!(Period[x,y],rev=true,lt=periodisless))
(+)(x::CompoundPeriod,y::Period) = (sort!(push!(x.periods,y) ,rev=true,lt=periodisless); return x)
# Year(1) - Month(1)
(-){P1<:Period,P2<:Period}(x::P1,y::P2) = CompoundPeriod(sort!(Period[x,-y],rev=true,lt=periodisless))
(-)(x::CompoundPeriod,y::Period) = (sort!(push!(x.periods,-y),rev=true,lt=periodisless); return x)

function DateTime(y::Year=Year(1),m::Month=Month(1),d::Day=Day(1),
                  h::Hour=Hour(0),mi::Minute=Minute(0),
                  s::Second=Second(0),ms::Millisecond=Millisecond(0))
    0 < m.months < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    rata = ms + 1000*(s.s + 60mi.m + 3600h.h + 
                         86400*totaldays(y.years,m.months,d.days))
    return UTDateTime(UTInst(rata))
end
DateTime(x::Period...) = error("Required argument order is DateTime(y,m,d,h,mi,s,ms)")
function Date(y::Year,m::Month=Month(1),d::Day=Day(1))
    0 < m.months < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    return Date(Day(totaldays(y.years,m.months,d.days)))
end
Date(x::Period...) = error("Required argument order is Date(y,m,d)")

function (+)(x::TimeType,y::CompoundPeriod)
    for p in y.periods
        x += p
    end
    return x
end
(+)(x::CompoundPeriod,y::TimeType) = y + x