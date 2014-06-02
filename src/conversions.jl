# Conversion/Promotion
Date(dt::TimeType) = convert(Date,dt)
DateTime(dt::TimeType) = convert(DateTime,dt)
Base.convert(::Type{DateTime},dt::Date) = DateTime(UTM(value(dt)*86400000))
Base.convert(::Type{Date},dt::DateTime) = Date(UTD(days(dt)))
Base.convert{R<:Real}(::Type{R},x::DateTime) = convert(R,value(x))
Base.convert{R<:Real}(::Type{R},x::Date)     = convert(R,value(x))

@vectorize_1arg DateTime Date
@vectorize_1arg Date DateTime

### External Conversions
const UNIXEPOCH = value(DateTime(1970)) #Rata Die milliseconds for 1970-01-01T00:00:00Z
function unix2datetime(x)
    rata = UNIXEPOCH + int64(1000*x)
    return DateTime(UTM(rata))
end
unix2date(x) = Date(unix2datetime(x))
# Returns unix seconds since 1970-01-01T00:00:00Z
datetime2unix(dt::DateTime) = (value(dt) - UNIXEPOCH)/1000.0
date2unix(dt::Date) = datetime2unix(DateTime(dt))
now() = unix2datetime(time())
today() = Date(now())

rata2datetime(days) = DateTime(yearmonthday(days)...)
rata2date(days) = Date(yearmonthday(days)...)
datetime2rata(dt::DateTime) = days(dt)
date2rata(dt::Date) = days(dt)

# Julian conversions
const JULIANEPOCH = value(DateTime(-4713,11,24,12))
function julian2datetime(f)
    rata = JULIANEPOCH + int64(86400000*f)
    return DateTime(UTM(rata))
end
julian2date(f) = Date(julian2datetime(f))
# Returns # of julian days since -4713-11-24T12:00:00Z
datetime2julian(dt::DateTime) = (value(dt) - JULIANEPOCH)/86400000.0
date2julian(dt::Date) = datetime2julian(DateTime(dt))

@vectorize_1arg Any unix2datetime
@vectorize_1arg Any unix2date
@vectorize_1arg DateTime datetime2unix
@vectorize_1arg Date date2unix
@vectorize_1arg Any rata2datetime
@vectorize_1arg Any rata2date
@vectorize_1arg DateTime datetime2rata
@vectorize_1arg Date date2rata
@vectorize_1arg Any julian2datetime
@vectorize_1arg Any julian2date
@vectorize_1arg DateTime datetime2julian
@vectorize_1arg Date date2julian

export unix2datetime, datetime2unix, unix2date, date2unix, now, today, 
       rata2datetime, datetime2rata, rata2date, date2rata, 
       julian2datetime, datetime2julian, julian2date, date2julian
