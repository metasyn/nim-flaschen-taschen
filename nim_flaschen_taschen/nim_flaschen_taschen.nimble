# Package

version       = "0.1.0"
author        = "Alexander Johnson"
description   = "A new awesome nimble package"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nim_flaschen_taschen"]

backend       = "cpp"

# Dependencies

requires "nim >= 0.20.9"
