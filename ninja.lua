---@type dotcmd.Env|_G
local _ENV = _ENV

local names = {
    linux = { x64 = "linux", arm64 = "linux-aarch64" },
    macos = { x64 = "mac", arm64 = "mac" },
    windows = { x64 = "win", arm64 = "winarm64" },
}

return function(options)
    local version = options.version
    local name = names[host.os][host.arch]
    local directory = fetch {
        url = "https://github.com/ninja-build/ninja/releases/download/v" .. version
            .. "/ninja-" .. name .. ".zip",
        sha256 = options.sha256[host.os][host.arch],
        prepare = function(input, output)
            extract(input, output)
        end,
    }

    return directory .. "/ninja" .. (host.os == "windows" and ".exe" or "")
end
