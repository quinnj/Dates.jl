const RMONTHS = ["january"=>1,"february"=>2,"march"=>3,"april"=>4,
                 "may"=>5,"june"=>6,"july"=>7,"august"=>8,"september"=>9,
                 "october"=>10,"november"=>11,"december"=>12]
const RMONTHSABBR = ["jan"=>1,"feb"=>2,"mar"=>3,"apr"=>4,
                     "may"=>5,"jun"=>6,"jul"=>7,"aug"=>8,"sep"=>9,
                     "oct"=>10,"nov"=>11,"dec"=>12]

# DateTime Parsing
# TODO: Handle generic offsets, i.e. +08:00, -05:00
type DateFormat
    year::Regex
    month::Regex
    monthoption::Int
    day::Regex
    sep::String
end
type TimeFormat
    regs::Array{Regex,1}
    tms::Array{String,1}
end
type DateTimeFormat
    date::DateFormat
    time::TimeFormat
    sep::String
end
# y-m-d
function date_regex(f,i,sep,monthoption)
    endregex = isdefined(sep,i) ? "(?=\\$(sep[i]))" : "\$"
    if monthoption == 0
        i == 1        ? Regex("^\\d{1,4}(?=\\$(sep[i]))") : 
        i == endof(f) ? Regex("(?<=\\$(sep[i-1]))\\d{1,4}$endregex") :
                        Regex("(?<=\\$(sep[i-1]))\\d{1,4}(?=\\$(sep[i]))")
    else
        i == 1        ? Regex("^.+?(?=\\$(sep[i]))") : 
        i == endof(f) ? Regex("(?<=\\$(sep[i-1])).+?$endregex") : 
                        Regex("(?<=\\$(sep[i-1])).+?(?=\\$(sep[i]))")
    end
end
function DateFormat(dt::String)
    sep = matchall(r"\W",dt)
    sep = map(x->x[1],sep)
    y = m = d = r""
    monthoption = 0
    if length(sep) == 0 #separator-less format strings
        sep = r"([ymd])(?!\1)" #match character changes
        st = 1
        for i in eachmatch(sep,dt)
            mat = dt[st:i.offset]
            if 'y' in mat
                y = st == 1 ? Regex("^\\d{$(length(st:i.offset))}") :
                    st == 3 ? Regex("(?<=^\\d{2})\\d{$(length(st:i.offset))}") :
                    Regex("\\d{$(length(st:i.offset))}\$")
            elseif 'm' in mat
                m = st == 1 ? Regex("^\\d{$(length(st:i.offset))}") :
                    st == 3 ? Regex("(?<=^\\d{2})\\d{$(length(st:i.offset))}") :
                    st == 5 ? Regex("(?<=^\\d{4})\\d{$(length(st:i.offset))}") :
                    Regex("\\d{$(length(st:i.offset))}\$")
            else
                d = st == 1 ? Regex("^\\d{$(length(st:i.offset))}") :
                    st == 3 ? Regex("(?<=^\\d{2})\\d{$(length(st:i.offset))}") :
                    st == 5 ? Regex("(?<=^\\d{4})\\d{$(length(st:i.offset))}") :
                    Regex("\\d{$(length(st:i.offset))}\$")
            end
            st = i.offset+1
        end
        sep = ""
    else
        f = split(dt,sep,0,false)
        for i = 1:length(f)
            if 'y' in f[i]
                y = date_regex(f,i,sep,0)
            elseif 'm' in f[i]
                l = length(f[i])
                monthoption = l > 3 ? 2 : l > 2 ? 1 : 0
                m = date_regex(f,i,sep,monthoption)
            else # contains(f[i],"d")
                d = date_regex(f,i,sep,0)
            end
        end
    end
    return DateFormat(y,m,monthoption,d,sep)
end
function _format(dt::String,format::DateFormat)
    y = (yy = match(format.year,dt)) == nothing ? "0" : yy.match
    m = (mm = match(format.month,dt)) == nothing ? "0" : mm.match
    m = format.monthoption == 0 ? m : format.monthoption == 1 ? 
            get(RMONTHSABBR,lowercase(m),1) : get(RMONTHS,lowercase(m),1)
    d = (dd = match(format.day,dt)) == nothing ? "0" : dd.match
    y == "" && (y = 0)
    m == "" && (m = 1)
    d == "" && (d = 1)
    return (int(y),int(m),int(d))
end
function TimeFormat(tm::String)
    regs = Array(Regex,0)
    tms = Array(String,0)
    for i = 1:(length(tm)-1)
        if tm[i] in "HMSsz" # if character
            if !in(tm[i+1],"HMSsz")
                sep = tm[i+1] == ' ' ? "\\s" : "\\$(tm[i+1])"
                if tm[i] in "HMSs"
                    push!(regs,Regex("\\d+?(?=$sep)"))
                    push!(tms,"$(tm[i])")
                else # tm[i] in "z"
                    push!(regs,Regex(".+?(?=$sep)"))
                    push!(tms,"$(tm[i])")
                end
            end
        elseif match(r"\W","$(tm[i])") != nothing # if delimiter
            sep = tm[i] == ' ' ? "\\s" : "\\$(tm[i])"
            push!(regs,Regex("$sep+"))
            push!(tms,string(tm[i]))
        else # unsupported character
           # pass
        end
        if (i+1) == endof(tm)
            if tm[i] in "HMSs"
                push!(regs,Regex("\\d+?\$"))
                push!(tms,"$(tm[i])")
            else # tm[i] in "z"
                push!(regs,Regex(".+?\$"))
                push!(tms,"$(tm[i])")
            end
            break
        end
    end
    return TimeFormat(regs,tms)
end
function _format(dt::String,f::TimeFormat)
    cursor = 1
    H = M = S = s = 0
    for i = 1:length(f.regs)
        m = match(f.regs[i],dt[cursor:end])
        t = f.tms[i]
        if t == "H"
            H = m.match
        elseif t == "M"
            M = m.match
        elseif t == "S"
            S = m.match
        elseif t == "s"
            s = m.match
        else # delimiter
           # pass 
        end
        cursor += length(m.match)
    end
    return (int(H),int(M),int(S),int(s)*10)
end
# Parses a format string
function DateTimeFormat(dt::String,sep::String="")
    if sep == ""
        sep = (s = match(r"(?<=[ymd])\W+(?=[HMSz])",dt)) == nothing ? "" : s.match
    end
    tm = ""
    if sep != ""
        dt, tm = split(dt,sep,2)
    end
    return DateTimeFormat(DateFormat(dt),TimeFormat(tm),sep)
end
function DateTime(dt::String,format::String=ISODateTimeFormat;sep::String="")
    f = DateTimeFormat(format,sep)
    return DateTime(dt,f)
end
const ISODateTimeFormat = DateTimeFormat("yyyy-mm-ddTHH:MM:SS zzz","T")
const ISODateFormat = DateFormat("yyyy-mm-dd")
function DateTime(dt::String,f::DateTimeFormat)
    if f.sep != ""
        dt, tm = split(dt,f.sep,2)
    else
        tm = ""
    end
    y, m, d = _format(dt,f.date)
    H, M, S, s = _format(tm,f.time)
    return DateTime(y,m,d,H,M,S,s)
end
function Date(dt::String,format::String=ISODateFormat)
    f = DateFormat(format)
    y, m, d = _format(dt,f)
    return Date(y,m,d)
end

function DateTime{T<:String}(y::AbstractArray{T},x::T)
    f = DateTimeFormat(x)
    return reshape([DateTime(y[i],f) for i in 1:length(y)], size(y))
end
function Date{T<:String}(y::AbstractArray{T},x::T)
    f = DateFormat(x)
    return reshape([Date(y[i],f) for i in 1:length(y)], size(y))
end
function Date{T<:String}(y::AbstractArray{T})
    return reshape([Date(y[i]) for i in 1:length(y)], size(y))
end