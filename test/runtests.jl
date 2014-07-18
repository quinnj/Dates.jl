using Dates
using Base.Test

include("types.jl")
include("periods.jl")
include("accessors.jl")
include("query.jl")
include("arithmetic.jl")
include("conversions.jl")
include("ranges.jl")
include("adjusters.jl")
include("io.jl")


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
