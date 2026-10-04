return function(options)
    local version = options.version
    local tools = fetch {
        url = "https://github.com/clojure/brew-install/releases/download/" .. version
            .. "/clojure-tools.zip",
        sha256 = options.sha256.tools,
        prepare = function(input, output)
            extract { path = input, to = output, strip_components = 1 }
        end
    }
    local launcher = fetch {
        url = "https://github.com/borkdude/deps.clj/releases/download/v" .. version
            .. "/deps.clj-" .. version .. "-standalone.jar",
        sha256 = options.sha256.launcher
    }
    local java = options.jdk .. "/bin/java" .. host.exe_suffix
    local program = java
    local ok = pcall(exec, {
        "rlwrap", "--version", stdout = "discard", stderr = "discard"
    })
    if ok then
        program = { "rlwrap", "-m", "-r", "-q", '\\"', "-b", [[(){}[],^%#@";:']], java }
    end

    return {
        program, "-jar", launcher,
        env = {
            JAVA_CMD = java,
            JAVA_HOME = options.jdk,
            PATH = prepend_path(options.jdk .. "/bin"),
            DEPS_CLJ_TOOLS_VERSION = version,
            DEPS_CLJ_TOOLS_DIR = tools
        }
    }
end
