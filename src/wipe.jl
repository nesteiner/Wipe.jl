const SPACING_FILES = 12
const SPACING_SIZE = 18
const SPACING_PATH = 9

@kwdef struct WipeParams
    wipe::Bool
    path::String
    language::LanguageEnum.T
    ignores::Vector{String}
end

WipeParams(path::String, args::Args) = WipeParams(
    wipe=args.wipe,
    path=path,
    language=args.language,
    ignores=args.ignores
)

@kwdef mutable struct WipeItem
    params::WipeParams
    stdout::IO
    previousInfo::Union{Nothing,DirInfo}
    wipeInfo::Union{Nothing,DirInfo}
    ignoreInfo::Union{Nothing,DirInfo}
end

WipeItem(stdout::IO, params::WipeParams) = WipeItem(
    stdout=stdout,
    params=params,
    previousInfo=nothing,
    wipeInfo=nothing,
    ignoreInfo=nothing
)

function writeHeader end
function writeContent end
function writeFooter end
function writeSummary end
function writeSpacedLine end
function writelnSpacedLine end


function writeHeader(wipe::WipeItem)
    styledString = if wipe.params.wipe
        color(RED, style(BOLD, "[Wiping]").result)
    else
        color(GREEN, style(BOLD, "[DRY RUNNING]").result)
    end

    print(wipe.stdout, styledString.result)

    directory = convert(DirectoryEnum.T, wipe.params.language)

    let string1 = color(CYAN, string(directory)).result
        string2 = color(CYAN, wipe.params.path).result
        println(" Recursively search for all \"$string1\" forlders in $string2...")
    end

    flush(wipe.stdout)
end

function writeContent(wipe::WipeItem)
    directory = convert(DirectoryEnum.T, wipe.params.language)
    paths = pathsToDelete(wipe.params.path, directory)

    if !isempty(paths)
        println(wipe.stdout)
        writelnSpacedLine(wipe, color(CYAN, "Files #"), color(CYAN, "Size"), "", color(CYAN, "Path"))
        wipe.previousInfo = dirsize(wipe.params.path)
    end

    wipeInfo = DirInfo(dirCount=length(paths), fileCount=0, size=0)
    ignoreInfo = DirInfo(dirCount=0, fileCount=0, size=0)
    pathsIgnored = wipe.params.ignores

    for path in paths
        dirinfo = dirsize(path)
        ignored = any(p -> startswith(path, p), pathsIgnored)

        writeSpacedLine(
            wipe,
            fileCountFormatted(dirinfo),
            sizeFormatted(dirinfo),
            "",
            path
        )

        if ignored
            ignoreInfo.dirCount += 1
            ignoreInfo.fileCount += dirinfo.fileCount
            ignoreInfo.size += dirinfo.size
        else
            wipeInfo.fileCount += dirinfo.fileCount
            wipeInfo.size += dirinfo.size
        end

        if ignored
            print(wipe.stdout, " $(color(YELLOW, "[Ignored]"))")
        elseif wipe.params.wipe
            rm(path, recursive=true)
        end

        println(wipe.stdout)
        flush(wipe.stdout)
    end

    wipe.wipeInfo = wipeInfo
    wipe.ignoreInfo = ignoreInfo
end

function writeFooter(wipe::WipeItem)
    wipeInfo::DirInfo = wipe.wipeInfo

    println(wipe.stdout)

    if wipeInfo.dirCount > 0
        writeSummary(wipe)

        if !wipe.params.wipe
            let string1 = color(RED, "cargo wipe $(wipe.params.language) -w").result
                string2 = color(RED, "USE WITH CAUTION!").result

                println(wipe.stdout, "Run $string1 to wipe all folders found. $string2")
            end
        else
            println(wipe.stdout, color(GREEN, "All clear!"))
        end
    else
        println(wipe.stdout, color(GREEN, "All clear!"))
    end
end

function writeSummary(wipe::WipeItem)
    previousInfo::DirInfo = wipe.previousInfo
    wipeInfo::DirInfo = wipe.wipeInfo
    ignoreInfo::DirInfo = wipe.ignoreInfo

    after = DirInfo(
        dirCount = previousInfo.dirCount - wipeInfo.dirCount,
        fileCount = previousInfo.fileCount - wipeInfo.fileCount,
        size = previousInfo.size - wipeInfo.size
    )    
    
    writelnSpacedLine(
        wipe,
        color(CYAN, "Files #"),
        color(CYAN, "Size"),
        "",
        color(CYAN, wipe.params.path)
    )

    label = if wipe.params.wipe 
        "Previously"
    else
        "Currently"
    end

    writelnSpacedLine(
        wipe,
        fileCountFormatted(previousInfo),
        sizeFormatted(previousInfo),
        "",
        label
    )

    if ignoreInfo.dirCount > 0
        writelnSpacedLine(
            wipe,
            color(YELLOW, fileCountFormatted(ignoreInfo)),
            color(YELLOW, sizeFormatted(ignoreInfo)),
            "",
            "Ignored"
        )
    end

    label = if wipe.params.wipe
        "Wiped"
    else
        "Can wipe"
    end

    writelnSpacedLine(
        wipe,
        color(RED, fileCountFormatted(wipeInfo)),
        color(RED, sizeFormatted(wipeInfo)),
        "",
        color(RED, label)
    )

    label = if wipe.params.wipe 
        "Now"
    else
        "After Wipe"
    end

    writelnSpacedLine(
        wipe,
        color(GREEN, fileCountFormatted(after)),
        color(GREEN, sizeFormatted(after)),
        "",
        color(GREEN, label)
    )

    println(wipe.stdout)
    flush(wipe.stdout)
end

function writeSpacedLine(
    wipe::WipeItem, 
    column1::Union{StyledString, String}, 
    column2::Union{StyledString, String}, 
    column3::Union{StyledString, String}, 
    column4::Union{StyledString, String})

    string1 = if column1 isa StyledString
        column1.original
    else
        column1
    end

    string2 = if column2 isa StyledString
        column2.original
    else
        column2
    end

    string3 = if column3 isa StyledString
        column3.original
    else
        column3
    end

    string4 = if column4 isa StyledString
        column4.original
    else
        column4
    end
    
    output = format("{:>$SPACING_FILES}{:>$SPACING_SIZE}{:>$SPACING_PATH}{}", string1, string2, string3, string4)

    for column in  [column1, column2, column3, column4]
        if column isa StyledString
            replace!(output, column.original => column.result)
        end
    end

    print(wipe.stdout, output)

end


function writelnSpacedLine(
    wipe::WipeItem, 
    column1::Union{StyledString, String}, 
    column2::Union{StyledString, String}, 
    column3::Union{StyledString, String}, 
    column4::Union{StyledString, String})

    string1 = if column1 isa StyledString
        column1.original
    else
        column1
    end

    string2 = if column2 isa StyledString
        column2.original
    else
        column2
    end

    string3 = if column3 isa StyledString
        column3.original
    else
        column3
    end

    string4 = if column4 isa StyledString
        column4.original
    else
        column4
    end
    
    output = format("{:>$SPACING_FILES}{:>$SPACING_SIZE}{:>$SPACING_PATH}{}", string1, string2, string3, string4)

    for column in  [column1, column2, column3, column4]
        if column isa StyledString
            output = replace(output, column.original => column.result)
        end
    end

    println(wipe.stdout, output)
end

