#include "nix/expr/eval-error.hh"
#include "nix/expr/eval.hh"
#include "nix/expr/primops.hh"
#include "nix/expr/value.hh"
#include "nix/util/config-global.hh"
#include <cstdio>
#include <memory>

using namespace nix;

// Defines a custom configuration settings, instantiates the settings, and
// registers it globally.
struct MySettings : Config {
  Setting<bool> enableShellEval{this, false, "enable-shell",
                                "Whether the 'shell' primop is enabled"};
};
MySettings mySettings;
static GlobalConfig::Register rs(&mySettings);

// exec_shell_command executes a shell command and returns its output.
std::string exec_shell_command(const std::string_view &command) {
  // Open a pipe to execute the command.
  std::string commandStr(command);
  std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(commandStr.c_str(), "r"),
                                                pclose);
  if (!pipe) {
    throw std::runtime_error("failed to execute command: " + commandStr);
  }

  // Read the command output.
  std::ostringstream stream;
  std::array<char, 128> buffer;
  while (fgets(buffer.data(), buffer.size(), pipe.get())) {
    stream << buffer.data();
  }
  std::string output = stream.str();

  // Remove trailing newline if present.
  if (!output.empty() && output.back() == '\n') {
    output.pop_back();
  }

  return output;
}

// prim_shell defines the 'shell' primop.
//
// The 'shell' primop is a builtin which takes in a shell command to execute
// and returns its output.
static void prim_shell(EvalState &state, const PosIdx pos, Value **args,
                       Value &v) {
  if (mySettings.enableShellEval) {
    auto command =
        state.forceString(*args[0], pos, "expected a string argument");
    auto output = exec_shell_command(command);
    v.mkString(output);
  } else {
    state.error<EvalError>("the 'shell' primop is disabled")
        .atPos(pos)
        .debugThrow();
  }
}

static RegisterPrimOp rp({
    .name = "__shell",
    .args = {"c"},
    .fun = prim_shell,
});

// Plugin entrypoint (keeping it to remind me that it exists).
extern "C" void nix_plugin_entry() {}
