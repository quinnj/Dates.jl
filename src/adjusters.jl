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

# Adjusters
firstdayofweek(dt::Date) = Date(UTD(value(dt) - dayofweek(dt) + 1))
firstdayofweek(dt::DateTime) = DateTime(firstdayofweek(Date(dt)))
lastdayofweek(dt::Date) = Date(UTD(value(dt) + (7-dayofweek(dt))))
lastdayofweek(dt::DateTime) = DateTime(lastdayofweek(Date(dt)))
@vectorize_1arg TimeType firstdayofweek
@vectorize_1arg TimeType lastdayofweek

firstdayofmonth(dt::Date) = Date(UTD(value(dt)-day(dt)+1))
firstdayofmonth(dt::DateTime) = DateTime(firstdayofmonth(Date(dt)))
function lastdayofmonth(dt::Date) 
    y,m,d = yearmonthday(dt)
    return Date(UTD(value(dt)+daysinmonth(y,m)-d))
end
lastdayofmonth(dt::DateTime) = DateTime(lastdayofmonth(Date(dt)))

@vectorize_1arg TimeType firstdayofmonth
@vectorize_1arg TimeType lastdayofmonth

firstdayofyear(dt::Date) = Date(UTD(value(dt)-dayofyear(dt)+1))
firstdayofyear(dt::DateTime) = DateTime(firstdayofyear(Date(dt)))
function lastdayofyear(dt::Date)
    y,m,d = yearmonthday(dt)
    return Date(UTD(value(dt)+daysinyear(y)-dayofyear(y,m,d)))
end

@vectorize_1arg TimeType firstdayofyear
@vectorize_1arg TimeType lastdayofyear

@vectorize_1arg TimeType firstdayofquarter
@vectorize_1arg TimeType lastdayofquarter


abstract Adjuster <: AbstractTime

immutable DOWAdjuster  <: Adjuster 

end
immutable FuncAdjuster <: Adjuster 

end

# Temporal Adjusters
function recur{T<:TimeType}(fun::Function,start::T,stop::T,step::Period=Day(1),negate::Bool=true)
    a = T[]
    n = negate ? identity : (!)
    i = start
    while i <= stop
        n(fun(i)) && (push!(a,i))
        i += step
    end
    return a
end

# Return the next TimeType that falls on dow
function tonext(dt::TimeType,dow::Int)
    d = Day(1)
    while dayofweek(dt) != dow
        dt += d
    end
    return dt
end
# Return the next TimeType where func evals true using step in incrementing
function tonext(func::Function,dt::TimeType,step::Period=Day(1),negate::Bool=true)

end

# Return the previous TimeType that falls on dow
function toprev(dt::TimeType,dow::Int)
    d = Day(-1)
    while dayofweek(dt) != dow
        dt += d
    end
    return dt
end
# Return the previous TimeType where func evals true using step in incrementing
function toprev(func::Function,dt::TimeType,step::Period=Day(1),negate::Bool=true)

end

# Return the first TimeType that falls on dow in the Month or Year
function tofirst(dt::TimeType,dow::Int,precision::Union(Type{Year},Type{Month})=Month)
    d = Day(-1)
    while dayofweek(dt) != dow
        dt += d
    end
    return dt
end
# Return the first TimeType where func evals true using step in incrementing in the Month or Year
function tofirst(func::Function,dt::TimeType,step::Period=Day(1),negate::Bool=true,precision::Union(Type{Year},Type{Month})=Month)

end

# Return the last TimeType that falls on dow in the Month or Year
function tolast(dt::TimeType,dow::Int,precision::Union(Type{Year},Type{Month})=Month)

end
# Return the last TimeType where func evals true using step in incrementing in the Month or Year
function tolast(func::Function,dt::TimeType,step::Period=Day(1),negate::Bool=true,precision::Union(Type{Year},Type{Month})=Month)

end