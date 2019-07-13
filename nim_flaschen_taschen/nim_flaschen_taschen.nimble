# Package

version       = "0.1.0"
author        = "Xander Johnson @metasyn"
description   = "A client for the Flaschen-Taschen at Noisebridge"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["nim_flaschen_taschen"]

backend       = "cpp"

# Dependencies

requires "nim >= 0.20"
requires "pnm >= 1.1.1"
requires "docopt >= 0.6.8"