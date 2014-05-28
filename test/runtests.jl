using Dates
using Base.Test

include("test_types.jl")
include("test_periods.jl")
include("test_accessors.jl")
include("test_query.jl")
include("test_arithmetic.jl")
include("test_conversions.jl")
include("test_ranges.jl")
include("test_adjusters.jl")
include("test_io.jl")

# Adjusters


#TODO

#d"2014-01-01"
#dt"2014-01-01"

 #massage recur
 #research JSR-310, PHP? javascript? go? C#? for API completeness
 #round(dt,period)
 #add(dt,y,m,d,h,mi,s,ms); sub(dt,y,m,d,h,mi,s,ms); many adjusts at once?
 
 #pair with recur
  #tonext(dt,dayofweek); tonext(func,dt)
  #toprev(dt,dayofweek); toprev(func,dt)
  #tolast(dt,dayofweek,precision=Month); tolast(func,dt,precision=Month)
  #tofirst(dt,dayofweek,precision=Month); tofirst(func,dt,precision=Month)
 #formatting/parsing
 #conversions: ruby? python? javascript? etc.
 #make TimeStamp fully parameterized (Instant, TimeZone, Calendar)
  #have datetime field + nanosecond field?
#NEED TESTS
 