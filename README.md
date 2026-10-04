# .cmd plugins

Load a plugin with `plugin(url, sha256)`. Each plugin returns a factory; call it
inside a task to download and prepare its dependencies only when needed. Pin the
plugin URL to a commit and supply its source SHA-256, independently of the hashes
for the downloaded tools.

## `ninja.lua`

`ninja { version = "...", sha256 = hashes }` returns the Ninja executable path.
`hashes` is indexed by OS (`linux`, `macos`, `windows`) and architecture (`x64`,
`arm64`).

## `liberica_jdk.lua`

`liberica_jdk { version = "...", sha256 = hashes }` returns the Java home
directory, with `bin/java` directly inside it on every platform. Use a complete Liberica version
including its build number, such as `25.0.2+12`. The plugin downloads standard
JDK archives from [Liberica's GitHub releases](https://github.com/bell-sw/Liberica/releases).
It supports Linux, macOS, and Windows on x64 and ARM64; Linux uses the glibc build.
Select a release with archives for all the platforms your project supports.

For example, after loading the factories as `liberica_jdk` and `clj`:

```lua
local jdk_options = {
    version = "25.0.2+12",
    sha256 = {
        linux = {
            x64 = "8dc3f4451b0affe00a6d4da0aa2331240bf7d142a353ff529673501f8bd09c4a",
            arm64 = "9bc4b2eb7be2b7d1e481bf83c6c86db5375b5e56925b083d3d4ef210dcf6e0b8"
        },
        macos = {
            x64 = "461e34d4caac11f73aeceb7cd82b2818dae865727580651526b24cb14a1f0d85",
            arm64 = "0795aa8b3631839a8ab41a94cb94ea56727fa62e2749919553d8965ab3d21b6f"
        },
        windows = {
            x64 = "704e5d6ff0b6de67461d12403a9864d211fa9c64187efa185dfa70dfbb130f33",
            arm64 = "db682beab88c4f186f05f558a2cfc08cf7b672eb5675f34bb2e7ec2b7504c275"
        }
    }
}

return {
    java = function(...)
        local home = liberica_jdk(jdk_options)
        exec {
            env = { JAVA_HOME = home, PATH = prepend_path(home .. "/bin") },
            home .. "/bin/java" .. host.exe_suffix, ...
        }
    end,
    clj = function(...)
        local command = clj {
            jdk = liberica_jdk(jdk_options),
            version = "1.12.6.1673",
            sha256 = {
                launcher = "49e8cf2de68709c1748a703906df2121b54c8371109d31bbb1d36dd6850b87fa",
                tools = "bb2f8a9f3fa94834813bd437b2a28b857c2f4b7267cb80168c0c6b910f883d4f"
            }
        }
        exec { command, ... }
    end
}
```

Run `./.cmd java -version`, `./.cmd clj -M:test`, or `./.cmd clj -T:build uber`.

## `clj.lua`

`clj { jdk = home, version = "...", sha256 = { launcher = "...", tools = "..." } }`
returns a command table for use with `exec` or `spawn`. `jdk` is a Java home
directory, from `liberica_jdk` or another source. Outer commands can override its
working directory and environment using the usual .cmd command composition.

The plugin downloads the [deps.clj standalone launcher jar](https://github.com/borkdude/deps.clj/releases)
and the official [Clojure tools ZIP](https://github.com/clojure/brew-install/releases).
Choose a CLI version published by both projects. Both downloads are platform
independent and verified by the supplied hashes. The tools archive includes the
tools uberjar, `exec.jar`, and supporting EDN files; no shell installer is needed.
The launcher uses the supplied JDK for both dependency resolution and execution.

The CLI version is independent of the project's Clojure language version, which
is selected in `deps.edn`. Maven and Git dependencies use normal Clojure resolution
and caches. Pass `-Srepro` to ignore user `deps.edn` configuration. The command
automatically uses `rlwrap` when it is available on PATH, with the standard `clj`
editing flags. Otherwise it runs directly; installing `rlwrap` is optional.
