local architectures = { x64 = "amd64", arm64 = "aarch64" }

return function(options)
    local version = options.version:gsub("%+", "%%2B")
    local name = "bellsoft-jdk" .. version .. "-" .. host.os .. "-"
        .. architectures[host.arch] .. (host.os == "windows" and ".zip" or ".tar.gz")
    local directory = fetch {
        url = "https://github.com/bell-sw/Liberica/releases/download/" .. version .. "/" .. name,
        sha256 = options.sha256[host.os][host.arch],
        prepare = function(input, output)
            extract { path = input, to = output, strip_components = 1 }
        end
    }

    return directory
end
