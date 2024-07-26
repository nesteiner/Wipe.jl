import Base: show, convert, print
using EnumX

@enumx LanguageEnum begin
    NodeModules
    Node
    Target
    Rust
end

@kwdef struct Args
    language::LanguageEnum.T
    wipe::Bool
    ignores::Vector{String}
end

@enumx DirectoryEnum begin
    NodeModules
    Target
end

function convert(::Type{LanguageEnum.T}, value::String)::LanguageEnum.T
    result = strip(lowercase(value))

    return if result == "node_modules"
        LanguageEnum.NodeModules
    elseif result == "node"
        LanguageEnum.Node
    elseif result == "target"
        LanguageEnum.Target
    elseif result == "rust"
        LanguageEnum.Rust
    else
        throw("Valid options are: rust | node")
    end
end

function show(io::IO, value::LanguageEnum.T)
    value = if value == LanguageEnum.NodeModules
        "node_modules"
    elseif value == LanguageEnum.Node
        "node"
    elseif value == LanguageEnum.Rust
        "rust"
    elseif value == LanguageEnum.Target
        "target"
    end

    show(io, value)
end

print(io::IO, value::LanguageEnum.T) = show(io, value)

function convert(::Type{DirectoryEnum.T}, value::LanguageEnum.T)::DirectoryEnum.T
    return if value == LanguageEnum.Node || value == LanguageEnum.NodeModules
        DirectoryEnum.NodeModules
    else
        DirectoryEnum.Target
    end
end

function show(io::IO, value::DirectoryEnum.T)
    result = if value == DirectoryEnum.NodeModules
        "node_modules"
    else
        "target"
    end

    show(io, result)
end

print(io::IO, value::DirectoryEnum.T) = show(io, value)