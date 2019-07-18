# nim-flaschen-taschen

A nim client for the [Flaschen Taschen](https://github.com/hzeller/flaschen-taschen) at [Noisebridge](https://noisebridge.net).

# Usage

```
nim_flaschen_taschen: nim client to the flaschen taschen at noisebridge


Usage:
    nim_flaschen_taschen pattern <pattern> [--width=<int>] [--height=<int>] [--x=<int>] [--y=<int>] [--z=<int>] [--host=<string>] [--port=<int>]
    nim_flaschen_taschen (-h | --help)
    nim_flaschen_taschen --version

Args:
    <pattern>             The pattern to display - one of: random, walk, blank

Options:
    --host=<string>       Host to use [default: ft.noise]
    --port=<int>          Port to use [default: 1337]
    --width=<int>         Width to use [default: 45]
    --height=<int>        Width to use [default: 45]
    --x=<int>             X value of the offset [default: 0]
    --y=<int>             Y value of the offset [default: 0]
    --z=<int>             Z value of the offset [default: 1]
    -h --help             Show this screen.
    --version             Show the version.
```

# Developer Pre-requisites 

* nim
* nimble

Install both by using [choosenim](https://github.com/dom96/choosenim).


# Building

```bash
cd nim_flaschen_taschen
nimble build
```

# Todo

- [x] implement a CLI interface for sending simple patterns
- [ ] implement a way of sending a particular image via the CLI (such as:)
    - [ ] png
    - [ ] jpg
- [ ] implement a way of sending videos via the CLI (such as:)
    - [ ] mpv4
    - [ ] mkv
    - [ ] avi
    - [ ] flv ?
- [ ] add tests & setup CI
- [ ] publish binary for darwin/linux/windows
- [ ] publish as a nimble package at https://nimble.directory

# License

MIT

# Contibutors

* Xander Johnson @metasyn
