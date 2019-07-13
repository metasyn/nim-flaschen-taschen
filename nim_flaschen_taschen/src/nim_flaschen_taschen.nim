# Stdlib
import logging, random, os, streams, net, strformat, strutils, sequtils, sugar, random

# Em xternal
import pnm, docopt

const defaultLog = "/tmp/nim-flaschen-taschen.log"

let doc = """
nim_flaschen_taschen: nim client to the flaschen taschen at noisebridge


Usage:
    nim_flaschen_taschen send <pattern> [--width=<int>] [--height=<int>] [--x=<int>] [--y=<int>] [--z=<int>] [--host=<string>] [--port=<int>]
    nim_flaschen_taschen (-h | --help)
    nim_flaschen_taschen --version

Args:
    <pattern>             The pattern to display - one of: random

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
"""


type
  Client* = object
    address*: string
    port*: Port
    socket: Socket

  RGBPixel* = object
    red*: int
    green*: int
    blue*: int

  Offset* = object
    x*: int
    y*: int
    z*: int
 
proc newClient*(address: string, port: int): Client =
  ## Simply creates a new Flaschen-Taschen client
  ## Args:
  ##   address: the address we want to send UDP packets to
  ##   port: the port number to send to 
  result = Client(
    socket: newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP),
    address: address,
    port: port.Port,
  )

proc sendDatagram*(c: Client , packet: PPM, offset: Offset = Offset())=
    ## Takes a PPM packet, adds the offset, then adds sends it via the client
    ## Args:
    ##   client: the client that holds the socket information
    ##   packet: the PPM data
    ##   offset: the offset to use

    ## Conver the PPM to P6 format
    var format = packet.formatP6

    ## We need to send the offset as
    for item in @[offset.x, offset.y, offset.z]:
      # Convert item to a string, then to chars, then to uints
      format.add('\n'.uint8)
      let
        strItem = $item
        uints = strItem.map(x => x.char).map(x => x.uint8)

      for num in uints:
        format.add(num)

    c.socket.sendTo(c.address, c.port, format[0].addr, format.len)

proc makePPM*(c: Client, height, width: int, data: seq[RGBPixel], offset: Offset = Offset()): PPM =
  var ppmBody = newSeq[uint8]()
  for i, p in data.pairs:
    ppmBody.add(p.red.uint8)
    ppmBody.add(p.green.uint8)
    ppmBody.add(p.blue.uint8)

  result = newPPM(ppmFileDiscriptorP6, width, height, ppmBody)

when isMainModule:
  addHandler(newFileLogger(defaultLog, fmtStr = verboseFmtStr))

  let args  = docopt(doc, version = "nim_flaschen_taschen 1.0")
  echo args

  if args["send"]:

    let
      host = $args["--host"]
      port = parseInt($args["--port"])
      client = newClient(host, port)
      width = parseInt($args["--width"])
      height = parseInt($args["--height"])
      x = parseInt($args["--x"])
      y = parseInt($args["--y"])
      z = parseInt($args["--z"])
      maxpixels = width * height

    var pixels = newSeq[RGBPixel](maxpixels)

    let repeat = true
    while true:

      case $args["<pattern>"]:
        of "random": 
          randomize()
          for i in 0 ..< maxpixels:
            pixels[i] = RGBPixel(red: rand(255), green: rand(255), blue: rand(255))
        else:
          echo "Unknown pattern."


      let data = client.makePPM(height, width, pixels)
      let offset = Offset(x: x, y: y, z: z)

      client.sendDatagram(data, offset)

      if repeat:
        sleep(1000)
      else:
        break 

