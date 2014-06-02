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


#TODO
 #docs update
 #Timezones.jl

#NEED TESTS
 
#IDEAS
 #research JSR-310, PHP? javascript? go? C#? for API completeness
 #round(dt,period)
 #add(dt,y,m,d,h,mi,s,ms); sub(dt,y,m,d,h,mi,s,ms); many ariths at once?
 #conversions: ruby? python? javascript? etc.
 #make TimeStamp fully parameterized (Instant, Calendar)
  #have datetime field + nanosecond + timezone field?
 #d"2014-01-01"
 #dt"2014-01-01"
