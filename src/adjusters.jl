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

#pair with recur
  #tonext(dt,dayofweek); tonext(func,dt)
  #toprev(dt,dayofweek); toprev(func,dt)
  #tolast(dt,dayofweek,precision=Month); tolast(func,dt,precision=Month)
  #tofirst(dt,dayofweek,precision=Month); tofirst(func,dt,precision=Month)

#return the next Date that falls on dow
tonext(dt::Date,dow)
#return the next Date where func evals true using step in incrementing
tonext(func::Callable,dt::Date,step::Period)

tonext(dt::Date,dow;precision=Year)
