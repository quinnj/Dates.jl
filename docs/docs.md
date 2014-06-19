Date and DateTime Functionality
===============================

Getting Started
---------------
To install and load the package:
```julia
Pkg.add("Dates")
using Dates
```

TimeTypes
---------

The `Dates` module provides two `TimeType` types: `Date` and `DateTime`, representing different levels of precision/resolution. The `Date` type has a day precision while the `DateTime` type provides a millisecond precision. The motivation for distinct types is simple, some operations are much simpler, both in terms of code and mental reasoning, when the complexities of greater precision don't have to be dealt with. For example, since the `Date` type has a "day-precision" (i.e. no hours, minutes, or seconds), it means that normal considerations for time zones, daylight savings/summer time, and leap seconds are unneccesary. Users should take care to think about the level precision they will actually require and choose a `TimeType` appropriately, remembering that the simpler the date type, the faster, more efficient, and less complex the code will be.

Both `Date` and `DateTime` are immutable, and wrap `Int64` `UTInstant` types, which represent continuously increasing machine timelines based fundamentally on the UT second<sup>[1]</sup>. A `Date` is represented by "yyyy-mm-dd", while a `DateTime` goes by the ISO standard "yyyy-mm-ddTHH:MM:SS.sZ". The `DateTime` type is *timezone-unaware* (in Python parlance) or can be considered a *LocalDateTime* (as in Java 8). Additional time zone functionality can be added through the `Timezones.jl` [package](https://github.com/quinnj/Timezones.jl/), which compiles the [Olsen Time Zone Database](http://www.iana.org/time-zones).

Both `Date` and `DateTime` are based on ISO 8601 standards following the proleptic Gregorian calendar, which means that the normal calendar we think of toady, which was implemented as it currently stands in 1582, is applied retroactively back through time. So even though the folks in 1582 fast-forwarded 10 days and didn't experience October 5-14, these are valid dates for the `ISOCalendar` (non-ISO implementations sometimes switch to the Julian calendar before Oct 14, 1582).

The ISO 8601 standard is also particular about BC/BCE dates. In common text, the date 1-12-31 BC/BCE was followed by 1-1-1 AD/CE, thus no year 0 exists. The ISO standard however states that 1 BC/BCE is year 0, so `0000-12-31` is the day before `0001-01-01`, and year `-0001` (yes, negative 1 for the year) is 2 BC/BCE, year `-0002` is 3 BC/BCE, etc.

[1]: <sub>The notion of the UT second is actually quite fundamental. There are basically two different notions of time as we know it, one based on the physical rotation of the earth (one full rotation = 1 day), the other actually based on the SI second (a fixed, constant value). These are radically different! Think about it, a "UT second" defined relative to the rotation of the earth  may have a different absolute length depending on the day! Anyway, the fact that the `Dates` package bases `Date` and `DateTime` on UT seconds is a simplifying assumption so that things like leap seconds and all their complexity can be avoided. This is better than most datetime libraries who either ignore them completely or grossly misunderstand how they work. Basing types on the UT second basically means that every minute has 60 seconds and every day has 24 hours.</sub>

Constructors
------------
`Date` and `DateTime` types can be constructed by parts with integers or Period types, by parsing, or through adjusters (more on them later)::
```julia
  julia> DateTime(2013)
  2013-01-01T00:00:00Z

  julia> DateTime(2013,7)
  2013-07-01T00:00:00Z

  julia> DateTime(2013,7,1)
  2013-07-01T00:00:00Z

  julia> DateTime(2013,7,1,12)
  2013-07-01T12:00:00Z

  julia> DateTime(2013,7,1,12,0)
  2013-07-01T12:00:00Z

  julia> DateTime(2013,7,1,12,0,0)
  2013-07-01T12:00:00Z

  julia> Date(2013)
  2013-01-01

  julia> Date(2013,7)
  2013-07-01

  julia> Date(2013,7,1)
  2013-07-01

  julia> Date(Year(2013),Month(7),Day(1))
  2013-07-01

  julia> Date(Month(7),Year(2013))
  2013-07-01
```
`Date` or `DateTime` parsing is accomplished by the use of format strings. The easiest way to understand is to see some examples in action. Also refer to the function reference below for additional information::
```julia

```
Durations/Comparisons
---------------------

Finding the length of time between two `Date` or `DateTime` is straightforward. The difference between `Date` is returned in the number of `Day`, and `DateTime` in the number of `Millisecond`. Similarly, comparing `TimeType` is a simple matter of comparing the underlying machine instants::
```julia
  julia> dt = Date(2012,2,29)
  2012-02-29

  julia> dt2 = Date(2000,2,1)
  2000-02-01

  julia> dump(dt)
  Date
    instant: UTInstant{Day}
      periods: Day
        value: Int64 734562

  julia> dump(dt2)
  Date
  instant: UTInstant{Day}
    periods: Day
      value: Int64 730151

  julia> dt > dt2
  true

  julia> dt != dt2
  true

  julia> dt + dt2
  Operation not defined for TimeTypes

  julia> dt * dt2
  Operation not defined for TimeTypes

  julia> dt / dt2
  Operation not defined for TimeTypes

  julia> dt - dt2
  4411 days

  julia> dt2 - dt
  -4411 days

  julia> dt = DateTime(2012,2,29)
  2012-02-29T00:00:00Z

  julia> dt2 = DateTime(2000,2,1)
  2000-02-01T00:00:00Z

  julia> dt - dt2
  381110402000 milliseconds
```
TimeType-Period Arithmetic
--------------------------

The `Dates` module's approach to `Period` arithmetic tries to be very simple and clear while still giving the user flexibility and options. It's good practice when using any language/date framework to be familiar with how period arithmetic is handled as there is no strong consensus and some [tricky issues](http://msmvps.com/blogs/jon_skeet/archive/2010/12/01/the-joys-of-date-time-arithmetic.aspx) to deal with (though much less so for day-precision types).

The `Dates` module tries to follow the simple principle of trying to change as little as possible when doing `Period` arithmetic. This approach is also often known as *calendrical* arithmetic or what you would probably guess if someone were to ask you. Why all the fuss about this? Let's take a classic example: add 1 month to January 31st, 2014. What's the answer? Javascript will say March 3 (assumes 31 days). PHP says March 2 (assumes 30 days). The fact is, there is no one right answer. In `Dates`, it would give the result of February 28th. How does it figure that out? I like to think of the classic 7-7-7 gambling game in casinos:
![777](http://www.ngamesonline.net/slider/slideimg-24.jpg)

Now just imagine that instead of 7-7-7, the slots are Year-Month-Day, or in our example, 2014-01-31. When you ask to add 1 month to this date, `Dates` increments the month slot, 2014-02-31, then lets the day number stay if it isn't greater than the last valid day of the new month; if it is (as in our case), it adjusts the day down to the last valid day (28). What are weird things about this approach (because any strategy you employ will have weirdness...)? Go ahead and add another month to our date, `2014-02-28 + Month(1) == 2014-03-28`. What? Were you expecting the last day of March? Nope, sorry, remember the 7-7-7 slots. As few slots as possible are going to change, so we first increment the month slot by 1, 2014-03-28, and boom, we're done because that's a valid date. The other ramification of this approach is an occasional loss in associativity (adding things in different orders results in different outcomes). For example:
```julia
julia> (Date(2014,1,29)+Day(1)) + Month(1)
2014-02-28

julia> (Date(2014,1,29)+Month(1)) + Day(1)
2014-03-01
```
What's going on there? In the first line, we're adding 1 day to January 29th, which results in 2014-01-30; then we add 1 month, so we get 2014-02-30, which then adjusts down to 2014-02-28. In the second example, we add 1 month *first*, where we get 2014-02-29, which adjusts down to 2014-02-28, and *then* add 1 day, which finally results in 2014-03-01. Tricky? Perhaps. What do you need to remember? Don't try to get fancy by forcing associativity. Another point to help in reasoning about Period arithmetic is that, in the presence of multiple Periods, `Dates` will always perform the operations based on the Period *types*, not their value or order, meaning `Year` will always be added first, then `Month`, then `Week`, etc. Hence the following *does* result in associativity::
```julia
julia> Date(2014,1,29) + Day(1) + Month(1)
2014-03-01

julia> Date(2014,1,29) + Month(1) + Day(1)
2014-03-01
```

Query Functions
---------------

Adjuster Functions
------------------


Period Types
------------

Periods are a human view of discrete, sometimes irregular durations of time. Consider 1 month; it could represent, in days, a value of 28, 29, 30, or 31 depending on the year and month context. Or 1 year could represent 365 or 366 days in the case of a leap year. These points are relevant when `Date/DateTime-Period` arithmetic is considered (which is discussed below). Despite their irregular nature, `Period` types in Julia are useful when working with `TimeType`. `Period` types are simple wrappers of a `Int64` type and constructed by wrapping any `Integer` type, i.e. `Year(1)` or `Month(3)`. Arithmetic between `Period` of the same type behave like `Integer`, and `Period-Real` arithmetic promotes the `Real` to the `Period` type:

```julia
  julia> y1 = Year(1)
  1 year

  julia> y2 = Year(2)
  2 years

  julia> y3 = Year(10)
  10 years

  julia> y1 + y2
  3 years

  julia> div(y3,y2)
  5 years

  julia> y3 - y2
  8 years

  julia> y3 * y2
  20 years

  julia> y3 % y2
  0 years

  julia> y1 + 20
  21 years

  julia> div(y3,3) # truncates
  3 years
 ```

Function Reference
------------------

.. currentmodule:: Base

.. function:: `DateTime(y, [m, [d,] [h,] [mi,] [s,] [ms]])`

   Construct a DateTime type by parts. Arguments must be of type
   `::Integer`. Returned DateTime corresponds to ISO 8601,Z.

.. function:: `DateTime([y::Year, [m::Month,] [d::Day,] [h::Hour,] [mi::Minute,] [s::Second,] [ms::Millisecond]])`

   Constuct a DateTime type by `Period` type parts. Arguments must be
   in order of greatest value (Year) to least (Millisecond).

.. function:: `DateTime(dt::String, [format::String=ISODateTimeFormat]; sep::String="")`

   Construct a DateTime type by parsing a `dt` string given a `format` string.
   The default format string is `ISODateTimeFormat` which is how
   DateTime types are represented. The `sep` keyword specifies the substring that
   separates the date and time parts of a DateTime string. If no `sep` is provided,
   a best guess for a non-word character is sought that divides the date and time
   components. The following codes can be used for constructing format strings:

   | Code            |  Matches   | Comment
   | --------------- |  --------  | ----------------------------
   | `yy`            | 96         | Returns year of `0096`
   | `yyyy`          | 1996       | Returns year of `1996`
   | `m` or `mm`     | 1, 01      | Matches 1 or 2-digit months
   | `mmm`           | Jan        | Matches abbreviated months
   | `mmmm`          | January    | Matches full month names
   | `d` or `dd`     | 1, 01      | Matches 1 or 2-digit days
   | `HH`            | 00         | Matches hours
   | `MM`            | 00         | Matches minutes
   | `SS`            | 00         | Matches seconds
   | `.s`            | .500       | Matches milliseconds

.. function:: `Date(y, [m, [d,])`

   Construct a Date type by parts. Arguments must be of type
   `::Integer`. Returned Date corresponds to ISO 8601.

.. function:: `Date([y::Year, [m::Month,] [d::Day])`

   Constuct a Date type by `Period` type parts. Arguments must be
   in order of greatest value (Year) to least (Day).

.. function:: `Date(dt::String, [format::String=ISODateTimeFormat]; sep::String="")`

   Construct a Date type by parsing a `dt` string given a `format` string.
   The default format string is `ISODateFormat` which is how
   Date types are represented. Same codes and rules for DateTime types
   apply for Dates.
.. currentmodule:: Base.Time

Period Constructors
-------------------

.. function:: `Year(y::Integer)`

   Construct a `Year` Period type with the given `Integer` value.

.. function:: `Month(y::Integer)`

   Construct a `Month` Period type with the given `Integer` value.

.. function:: `Week(y::Integer)`

   Construct a `Week` Period type with the given `Integer` value.

.. function:: `Day(y::Integer)`

   Construct a `Day` Period type with the given `Integer` value.

.. function:: `Hour(y::Integer)`

   Construct a `Hour` Period type with the given `Integer` value.

.. function:: `Minute(y::Integer)`

   Construct a `Minute` Period type with the given `Integer` value.

.. function:: `Second(y::Integer)`

   Construct a `Second` Period type with the given `Integer` value.

.. function:: `Millisecond(y::Integer)`

   Construct a `Millisecond` Period type with the given `Integer` value.

Accessor Functions
------------------

.. function:: `year(dt::TimeType) -> Int64`

   Return the year part of a Date or DateDates.

.. function:: `month(dt::TimeType) -> Int64`

   Return the month part of a Date or DateDates.

.. function:: `week(dt::TimeType) -> Int64`

   Return the ISO 8601 week number of a Date or DateDates.

.. function:: `day(dt::TimeType) -> Int64`

   Return the day part of a Date or DateDates.

.. function:: `hour(dt::TimeType) -> Int64`

   Return the hour part of a DateDates.

.. function:: `minute(dt::TimeType) -> Int64`

   Return the minute part of a DateDates.

.. function:: `second(dt::TimeType) -> Int64`

   Return the second part of a DateDates.

.. function:: `millisecond(dt::TimeType) -> Int64`

   Return the millisecond part of a DateDates.

Date Functions
--------------

.. function:: `now() -> DateTime`

   Returns a DateTime type corresponding to the user's system
   time, converted toZ.

.. function:: `monthname(dt::TimeType) -> String`

   Return the full name of the month of the Date or DateDates.

.. function:: `monthabbr(dt::TimeType) -> String`

   Return the abbreviated month name of the Date or DateDates.

.. function:: `dayname(dt::TimeType) -> String`

   Return the full day name corresponding to the day of the week
   of the Date or DateDates.

.. function:: `dayabbr(dt::TimeType) -> String`

   Return the abbreviated name corresponding to the day of the week
   of the Date or DateDates.

.. function:: `isleap(dt::TimeType) -> Bool`

   Returns if the year of the Date or DateTime is a leap year.

.. function:: `lastdayofmonth(dt::TimeType) -> TimeType`

   Returns a Date or DateTime corresponding to the last day of the
   month of the Date or DateDates.

.. function:: `firstdayofmonth(dt::TimeType) -> TimeType`

   Similar to `lastdayofmonth`, but for the 1st day of the month.

.. function:: `dayofweek(dt::TimeType) -> Int`

   Returns the day of the week of the Date or DateTime as an `Int`.
   0 => Sunday, 1 => Monday...6 => Saturday

.. function:: `dayofweekofmonth(dt::TimeType) -> Int`

   Returns the number of the day of the week of the Date or DateTime
   in the month. For example, if the day of the week for a Date is 1
   (Monday), `dayofweekofmonth` will return a value between 1 and 5
   corresponding to the 1st Monday, 2nd Monday...5th Monday of the month.

.. function:: `daysofweekinmonth(dt::TimeType) -> 4 or 5`

   Returns 4 or 5, corresponding to the total number of days of the week
   for the given Date or DateDates.

.. function:: `firstdayofweek(dt::TimeType) -> TimeType`

   Returns a Date or DateTime corresponding to midnight Sunday of the
   week of the given Date or DateDates.

.. function:: `lastdayofweek(dt::TimeType) -> TimeType`

   Returns a Date or DateTime corresponding to midnight Saturday of the
   week of the given Date or DateDates.

.. function:: `dayofyear(dt::TimeType) -> Int`

   Returns the day of the year for the Date or DateDates.

.. function:: `recur(fun::Function, start::TimeType, stop::TimeType[, step::Period]; inclusion=true) -> Array{TimeType,1}`

   `recur` takes a boolean function as 1st argument (or used with a `do` block), and will
   apply the boolean function for each Date or DateTime from `start` to `stop` incrementing
   by `step`. If the boolean function returns `true`, the evaluated Date or DateTime is
   "included" in the returned `Array`. The `inclusion` keyword specifies whether the boolean
   function will "include" or "exclude" the TimeType from the set.


Conversion Functions
--------------------

.. function:: `unix2date(x::Float64) -> DateTime`

   Takes the number of seconds since unix epoch `1970-01-01T00:00:00Z`
   and converts to the corresponding DateDates.

.. function:: `date2unix(dt::DateTime) -> Float64`

   Takes the given DateTime and returns the number of seconds since
   the unix epoch as a `Float64`.

.. function:: `julian2date(j) -> DateTime`

   Takes the number of Julian calendar days since epoch
   `-4713-11-24T12:00:00` and returns the corresponding DateDates.
.. function:: `date2julian(dt::DateTime) -> Float64`

   Takes the given DateTime and returns teh number of Julian calendar days
   since the julian epoch as a `Float64`.

.. function:: `ratadays2date(days) -> DateTime`

   Takes the number of Rata Die days since epoch `0000-12-31T00:00:00`
   and returns the corresponding DateDates.

.. function:: `date2ratadays(dt::TimeType) -> Int64`

   Returns the number of Rata Die days since epoch from the
   given Date or DateDates.


Constants
---------

Days of the Week:

  `Sunday`     = `Sun` = 0

  `Monday`     = `Mon` = 1

  `Tuesday`    = `Tue` = 2

  `Wednesday`  = `Wed` = 3

  `Thursday`   = `Thu` = 4

  `Friday`     = `Fri` = 5

  `Saturday`   = `Sat` = 6

Months of the Year:

  `January`    = `Jan` = 1

  `February`   = `Feb` = 2

  `March`      = `Mar` = 3

  `April`      = `Apr` = 4

  `May`        = `May` = 5

  `June`       = `Jun` = 6

  `July`       = `Jul` = 7

  `August`     = `Aug` = 8

  `September`  = `Sep` = 9

  `October`    = `Oct` = 10

  `November`   = `Nov` = 11

  `December`   = `Dec` = 12
