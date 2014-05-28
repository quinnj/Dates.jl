using Dates
using Base.Test

include("test/test_types.jl")
include("test/test_periods.jl")
include("test/test_accessors.jl")
include("test/test_query.jl")
include("test/test_arithmetic.jl")
include("test/test_conversions.jl")
include("test/test_ranges.jl")
include("test/test_adjusters.jl")
include("test/test_io.jl")


#TODO
 #formatting/parsing
 #test coverage/coveralls.io
 #docs update

#NEED TESTS
 
#IDEAS
 #research JSR-310, PHP? javascript? go? C#? for API completeness
 #round(dt,period)
 #add(dt,y,m,d,h,mi,s,ms); sub(dt,y,m,d,h,mi,s,ms); many ariths at once?
 #conversions: ruby? python? javascript? etc.
 #make TimeStamp fully parameterized (Instant, TimeZone, Calendar)
  #have datetime field + nanosecond field?
 #d"2014-01-01"
 #dt"2014-01-01"