using Libdl
import Base.Libc: free

const libtermcolor = Ref{Ptr{Nothing}}()

function __init__()
    libtermcolor[] = dlopen(joinpath(@__DIR__, "../include/termcolor/libtermcolor.so"))
end
    
@enum Colors begin
    RED
    GREEN
    BLUE
    YELLOW
    MAGENTA
    CYAN
    WHITE
    GREY
end

@enum Styles begin
    BOLD
    UNDERLINE
    ITALIC
end

@kwdef struct StyledString
    original::String
    result::String
end

const colorMap::Dict{Colors, String} = Dict(
    RED => "red",
    GREEN => "green",
    BLUE => "blue",
    YELLOW => "yellow",
    MAGENTA => "magenta",
    CYAN => "cyan",
    WHITE => "white",
    GREY => "grey",
)

const styleMap::Dict{Styles, String} = Dict(
    BOLD => "bold",
    UNDERLINE => "underline",
    ITALIC => "italic",
)

function color(c::Colors, string::String)::StyledString
    symbol = get(colorMap, c, nothing)
    if isnothing(symbol)
        throw("no such 16 color")
    end

    f = dlsym(libtermcolor[], :color)
    p = ccall(f, Cstring, (Cstring, Cstring), symbol, string)

    result = unsafe_string(p)
    free(p)

    return StyledString(original = string, result = result)
end

function background(color::Colors, string::String)::StyledString
    symbol = get(colorMap, color, nothing)
    if isnothing(symbol)
        throw("no such 16 color")
    end

    f = dlsym(libtermcolor[], :background)
    cstring = ccall(f, Cstring, (Cstring, Cstring), symbol, string)
    p = pointer(cstring)
    result = unsafe_string(p)
    free(p)

    return StyledString(original = string, result = result)
end

function style(s::Styles, string::String)::StyledString
    symbol = get(styleMap, s, nothing)
    if isnothing(symbol)
        throw("no such style")
    end

    f = dlsym(libtermcolor[], :style)
    cstring = ccall(f, Cstring, (Cstring, Cstring), symbol, string)
    p = pointer(cstring)
    result = unsafe_string(p)
    free(p)

    return StyledString(original = string, result = result)
end

