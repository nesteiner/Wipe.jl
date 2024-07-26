@kwdef mutable struct DirInfo
    dirCount::Int
    fileCount::Int
    size::Int
end

fileCountFormatted(dirInfo::DirInfo) = formatNumber(dirInfo.fileCount)
sizeFormatted(dirInfo::DirInfo) = prefixNumber(dirInfo.size)

function isValidDirectory(path::String, directory::DirectoryEnum.T)::Bool
    return if directory == DirectoryEnum.Target
        filepath = joinpath(path, ".rustc_info.json")
        isfile(filepath)
    else
        filepath = joinpath(path, "node_modules")
        isdir(filepath)
    end
end

function pathsToDelete(path::String, directory::DirectoryEnum.T)::Set{String}
    result = Set{String}()
    
    for (root, dirs, files) in walkdir(path)
        if any(x -> contains(root, x), result)
            continue
        end

        for dir in dirs
            # ignore such directory: node_modules/.pnpm
            if startswith(dir, ".")
                continue
            end

            extendedPath = joinpath(root, dir)

            if isValidDirectory(extendedPath, directory)
                push!(result, extendedPath)
            end
        end
    end

    return result
end

function dirsize(path::String)::DirInfo
    result = DirInfo(dirCount = 0, fileCount = 0, size = 0)

    for (root, dirs, files) in walkdir(path)
        result.dirCount += length(dirs)
        result.fileCount += length(files)

        size = reduce(
            +, 
            map(filesize, map(x -> joinpath(root, x), files))
        )
        
        size += reduce(
            +,
            map(filesize, map(x -> joinpath(root, x), dirs))
        )
        
        result.size += size

    end

    return result
end         