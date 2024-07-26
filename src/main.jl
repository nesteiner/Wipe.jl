import Pkg
Pkg.activate("/home/steiner/workspace/Wipe.jl")

using Wipe
using ArgumentParser

panic() = throw("usage: julia main.jl <language> [-w] [-i/--ignores <ignores...>]")

function main()
    flag = Flag(name ="wipe", short = "-w", defaultValue = false)
    positioned = Positioned(String, name = "language", index = 1)
    argument = Argument(Vector{String}, name = "ignores", short = "-i", long = "--ignores", require = false)


    if !haspositioned(ARGS, positioned)
        panic()
    end

    result = parseArguments(target = ARGS, flags = [flag], positions = [positioned], arguments = [argument])
    language = convert(LanguageEnum.T, result["language"])
        
    
    runwipe(pwd(), language, wipe = result["wipe"], ignores = get(result, "ignores", String[]))
end

main()