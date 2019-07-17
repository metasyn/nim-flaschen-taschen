# Stdlib
import logging, random, os, streams, net, strformat, strutils, sequtils, sugar, random, math

# External
import pnm, docopt

const defaultLog = "/tmp/nim-flaschen-taschen.log"

let doc = """
nim_flaschen_taschen: nim client to the flaschen taschen at noisebridge


Usage:
    nim_flaschen_taschen send <pattern> [--width=<int>] [--height=<int>] [--x=<int>] [--y=<int>] [--z=<int>] [--host=<string>] [--port=<int>]
    nim_flaschen_taschen (-h | --help)
    nim_flaschen_taschen --version

Args:
    <pattern>             The pattern to display - one of: random, blank, walk

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

randomize()

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

proc makePPM*(height, width: int, data: seq[RGBPixel], offset: Offset = Offset()): PPM =
  ## Takes a long array of seq[RGBPixel]
  var ppmBody = newSeq[uint8]()
  for i, p in data.pairs:
    ppmBody.add(p.red.uint8)
    ppmBody.add(p.green.uint8)
    ppmBody.add(p.blue.uint8)

  result = newPPM(ppmFileDiscriptorP6, width, height, ppmBody)

proc makePPM*(height, width: int, data: seq[seq[RGBPixel]], offset: Offset = Offset()): PPM =
  ## Takes a seq[seq[RGBPixel]] - basically a matrix
  let count = height * width
  var pixels = newSeq[RGBPixel](count)

  for i, row in data.pairs:
    let rowOffset = i * width
    for j, pixel in row.pairs:
      pixels[j + rowOffset] = pixel

  result = makePPM(height, width, pixels, offset)

proc blankMatrix*(height, width: int, transparent: bool = false): seq[seq[RGBPixel]] =
  ## Gives you a blank matrix to use
  var val = 1
  if transparent:
    val = 0

  result = newSeq[seq[RGBPixel]](height)
  for i in 0 ..< result.len:
      result[i] = newSeq[RGBPixel](width)
      for j in 0 ..< width:
        # Zero means transparent
        result[i][j] = RGBPixel(red: val, green: val, blue: val)

proc dim*(pixel: RGBPixel, transparent: bool = false): RGBPixel =
  var val = 1
  if transparent:
    val = 0
  let
    red = max(val, pixel.red - 1)
    green = max(val, pixel.green - 1)
    blue = max(val, pixel.blue - 1)
  result = RGBPixel(red: red, green: green, blue: blue)

proc dim*(matrix: var seq[seq[RGBPixel]], transparent: bool = false) =
  let
    height = matrix.high
    width = matrix[0].high
  for i in 0 ..< height:
    for j in 0 ..< width:
      matrix[i][j] = matrix[i][j].dim(transparent)


## Color utils


proc makeColorGradient(frequency1, frequency2, frequency3: float32, phase1, phase2, phase3, center = 128, width = 127, num: int = 50): seq[RGBPixel]=
  result = newSeq[RGBPixel](num)
  for i in 0 ..< num:
    let
      red = sin(frequency1 * i.float32 + phase1.float32) * width.float32 + center.float32
      green = sin(frequency2 * i.float32 + phase2.float32) * width.float32 + center.float32
      blue = sin(frequency3 * i.float32 + phase3.float32) * width.float32 + center.float32
    result[i] = RGBPixel(red: red.trunc.int, green: green.trunc.int, blue: blue.trunc.int)

proc pastels(): seq[RGBPixel] =
  ## Gives you 100 pastels to use
  result = makeColorGradient(0.5, 0.5, 0.3, 0, 2, 4, 170, 50, 100);
  

## Patterns

proc random(c: Client, height, width: int, offset: Offset) =
  ## Each pixel is a random color.
  let count = height * width
  var pixels = newSeq[RGBPixel](count)
  while true:
      for i in 0 ..< count:
          pixels[i] = RGBPixel(red: rand(255), green: rand(255), blue: rand(255))
      let data = makePPM(height, width, pixels)
      c.sendDatagram(data, offset)
      sleep(1000)


proc blank(c: Client, height, width: int, offset: Offset) =
  let count = height * width
  var pixels = newSeq[RGBPixel](count)
  for i in 0..<count:
    pixels[i] = RGBPixel(red: 1, green: 1, blue: 1)
  let data = makePPM(height, width, pixels)
  while true:
    c.sendDatagram(data, offset)
    sleep(1000)


proc walk(c: Client, height, width: int, offset: Offset) =
  var
    matrix = blankMatrix(height, width, transparent=false)
    # Row and column pointers
    i = 0
    j = 0
    count = 0

  # Seed the first value
  matrix[i][j] = RGBPixel(red: rand(255), green: rand(255), blue: rand(255))

  # Choose a rainbow color palette
  let palette = pastels()

  while true:
    # Keep track of previous coordinate

    let choice = rand(1.0)
    # Left
    if choice <= 0.25:
      i -= 1
    # Right
    elif choice <= 0.50:
      i += 1
    # Down
    elif choice <= 0.75:
      j -= 1
    # Up
    else:
      j += 1

    i = (i + width) mod width
    j = (j + height) mod height

    let color = palette[count mod palette.len]
    count += 1
    matrix.dim()
    matrix[i][j] = color

    let data = makePPM(height, width, matrix)
    c.sendDatagram(data, offset)
    sleep(5)
    


when isMainModule:
  addHandler(newFileLogger(defaultLog, fmtStr = verboseFmtStr))

  let args  = docopt(doc, version = "nim_flaschen_taschen 1.0")

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
      offset = Offset(x: x, y: y, z: z)


    case $args["<pattern>"]:
      of "random": 
        client.random(height, width, offset)
      of "walk":
        client.walk(height, width, offset)
      of "blank":
        client.blank(height, width, offset)
      else:
        echo "Unknown pattern."


