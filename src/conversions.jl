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
const UNIXEPOCH = value(DateTime(1970)) #Rata Die milliseconds for 1970-01-01T00:00:00 UTC
function unix2date(x)
    rata = UNIXEPOCH + int64(1000*x)
    return DateTime(UTM(rata))
end
# Returns unix seconds since 1970-01-01T00:00:00 UTC
date2unix(dt::DateTime) = (value(dt) - UNIXEPOCH)/1000.0
now() = unix2date(time())

ratadays2date(days) = yearmonthday(days)
date2ratadays(dt::TimeType) = days(dt)

# Julian conversions
const JULIANEPOCH = value(DateTime(-4713,11,24,12))
function julian2date(f)
    rata = JULIANEPOCH + int64(86400000*f)
    return DateTime(UTM(rata))
end
# Returns # of julian days since -4713-11-24T12:00:00 UTC
date2julian(dt::DateTime) = (value(dt) - JULIANEPOCH)/86400000.0

export unix2date, date2unix, now, ratadays2date, date2ratadays, julian2date, date2julian