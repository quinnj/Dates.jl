# Date/DateTime Ranges

# Override default step; otherwise it would be Millisecond(1)
Base.colon{T<:DateTime}(start::T, stop::T) = StepRange(start, Day(1), stop)

# Given a start and end date, how many steps/periods are in between
Base.length(r::StepRange{Date,Day}) = isempty(r) ? 0 : 
    int(div(r.stop + r.step - r.start, r.step))
Base.length(r::StepRange{Date,Week}) = isempty(r) ? 0 : 
    int(div(r.stop + r.step - r.start, 7*value(r.step)))
Base.length{T<:FixedPeriod}(r::StepRange{DateTime,T}) = isempty(r) ? 0 : 
    int(div(r.stop + r.step - r.start, toms(r.step)))

# Calculate a conservative guess for how many months/years are between two dates
guess(start::Date,stop::Date,step::Month) = int(float(stop-start)/(30.436875*value(step)))
guess(start::Date,stop::Date,step::Year) = int(float(stop-start)/(365.2425*value(step)))
guess(start::DateTime,stop::DateTime,step::Month) = int(float(days(stop-start))/(30.436875*value(step)))
guess(start::DateTime,stop::DateTime,step::Year) = int(float(days(stop-start))/(365.2425*value(step)))

function _length(start,stop,step)
    start,stop = start > stop ? (stop,start) : (start,stop)
    step = step < zero(step) ? -step : step
    i = guess(start,stop,step)
    while (start+step*i) <= stop
        i += 1
    end
    return i
end

Base.length{T<:TimeType}(r::StepRange{T}) = isempty(r) ? 0 : _length(r.start,r.stop,r.step)
# Period ranges hook into Int64 overflow detection
Base.length{P<:Period}(r::StepRange{P}) = length(StepRange(value(r.start),value(r.step),value(r.stop)))

# Used to calculate the last valid date in the range given the start, stop, and step
# last = stop - steprem(start,stop,step)
Base.steprem(a::Date,b::Date,c::Day) = (b-a) % c
Base.steprem(a::Date,b::Date,c::Week) = (b-a) % (7*value(c))
Base.steprem(a::DateTime,b::DateTime,c::FixedPeriod) = (b-a) % toms(c)
Base.steprem{T<:TimeType}(a::T,b::T,step::Period) = b - (a+step*(_length(a,b,step)-1))

import Base.in
function in{T<:TimeType,S<:Period}(x::T, r::StepRange{T,S})
    isempty(r) && return false
    if step(r) < zero(S)
        for d in r
            d == x && return true
            x > d && break
        end
    else
        for d in r
            d == x && return true
            x < d && break
        end
    end
    return false
end

Base.start{T<:TimeType}(r::StepRange{T}) = 0
Base.next{T<:TimeType}(r::StepRange{T}, i) = (r.start+r.step*i,i+1)
Base.done{T<:TimeType,S<:Period}(r::StepRange{T,S}, i::Integer) = length(r) <= i