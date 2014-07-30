using Dates
using Base.Test

cd("C:/Users/karbarcca/.julia/v0.3/Dates/test")

include("C:/Users/karbarcca/.julia/v0.3/Dates/src/Dates.jl"); using Dates
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
