module Wipe

import Format: format

export WipeItem, WipeParams, Args, LanguageEnum, runwipe

include("utils.jl")
include("color.jl")
include("command.jl")
include("dir-helper.jl")
include("wipe.jl")

function runwipe(path::String, language::LanguageEnum.T; wipe::Bool = false, ignores::Vector{String} = String[])
    args = Args(language = language, wipe = wipe, ignores = ignores)
    params = WipeParams(path, args)
    item = WipeItem(stdout, params)

    writeHeader(item)
    writeContent(item)
    writeFooter(item)
end

end # module Wipe
