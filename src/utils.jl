const prefixes = ["", "K", "M", "G", "T", "P"]

formatNumber(number::Number) = format(number, commas = true)

function prefixNumber(number::Number)::String
    magnitude = 1
    while abs(number) >= 1000
        magnitude += 1
        number /= 1000.0
    end

    return format("{:.1f}{}", number, prefixes[magnitude])
end 