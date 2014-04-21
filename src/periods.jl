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
zero{P<:Period}(::Union(Type{P},P)) = P(0)
one{P<:Period}(::Union(Type{P},P)) = P(1)
typemin{P<:Period}(::Type{P}) = P(typemin(Int64))
typemax{P<:Period}(::Type{P}) = P(typemax(Int64))


(-){P<:Period}(x::P) = P(-value(x))
isless {P<:Period}(x::P,y::P) = isless(value(x),value(y))
isequal{P<:Period}(x::P,y::P) = isequal(value(x),value(y))
isless {R<:Real}(x::Period,y::R) = throw(ArgumentError("Can't compare Period-$R"))
isequal{R<:Real}(x::Period,y::R) = throw(ArgumentError("Can't compare Period-$R"))
isless {R<:Real}(y::R,x::Period) = throw(ArgumentError("Can't compare Period-$R"))
isequal{R<:Real}(y::R,x::Period) = throw(ArgumentError("Can't compare Period-$R"))

isless(x::Period,y::Period) = throw(ArgumentError("Can't compare Periods of different types"))
isequal(x::Period,y::Period) = throw(ArgumentError("Can't compare Periods of different types"))

#Period Arithmetic:
let vec_ops = [:.+,:.-,:.*,:.%,:div]
    for op in [:+,:-,:*,:%,vec_ops]
        @eval begin
        #Period-Period
        ($op){P<:Period}(x::P,y::P) = P(($op)(value(x),value(y)))
        #Period-Integer
        ($op){P<:Period}(x::P,y::Integer) = P(($op)(value(x),int64(y)))
        ($op){P<:Period}(x::Integer,y::P) = P(($op)(int64(x),value(y)))
        #Period-Real
        #TODO: using isinteger here isn't really safe because it allows Int128 and BigInts
        # what we really need is an isint64() function
        ($op){P<:Period}(x::P,y::Real) = P(($op)(value(x),isinteger(y) ? int64(y) : throw(ArgumentError("Can't convert $y to Integer"))))
        ($op){P<:Period}(x::Real,y::P) = P(($op)(isinteger(x) ? int64(x) : throw(ArgumentError("Can't convert $y to Integer")),value(y)))
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
function string(x::CompoundPeriod)
    s = ""
    for p in x.periods
        s *= ", " * string(p)
    end
    return s[3:end]
end
show(io::IO,x::CompoundPeriod) = print(io,string(x))
# Year(1) + Day(1)
(+)(x::Period,y::Period) = CompoundPeriod(sort!(Period[x,y],rev=true,lt=periodisless))
(+)(x::CompoundPeriod,y::Period) = (sort!(push!(x.periods,y) ,rev=true,lt=periodisless); return x)
# Year(1) - Month(1)
(-)(x::Period,y::Period) = CompoundPeriod(sort!(Period[x,-y],rev=true,lt=periodisless))
(-)(x::CompoundPeriod,y::Period) = (sort!(push!(x.periods,-y),rev=true,lt=periodisless); return x)

function DateTime(y::Year=Year(1),m::Month=Month(1),d::Day=Day(1),
                  h::Hour=Hour(0),mi::Minute=Minute(0),
                  s::Second=Second(0),ms::Millisecond=Millisecond(0))
    0 < m.months < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    rata = ms + 1000*(s.s + 60mi.m + 3600h.h + 
                         86400*totaldays(y.years,m.months,d.days))
    return UTDateTime(UTInst(rata))
end
DateTime(x::Period...) = throw(ArgumentError("Required argument order is DateTime(y,m,d,h,mi,s,ms)"))
function Date(y::Year,m::Month=Month(1),d::Day=Day(1))
    0 < m.months < 13 || throw(ArgumentError("Month: $m out of range (1:12)"))
    return Date(Day(totaldays(y.years,m.months,d.days)))
end
Date(x::Period...) = throw(ArgumentError("Required argument order is Date(y,m,d)"))

function (+)(x::TimeType,y::CompoundPeriod)
    for p in y.periods
        x += p
    end
    return x
end
(+)(x::CompoundPeriod,y::TimeType) = y + x