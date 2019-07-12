import logging
import random
import os
import streams
import pnm
import net
import strformat
import strutils
import sequtils
import sugar
import pnm
import random

const defaultLog = "/tmp/nim-flaschen-taschen.log"


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
  randomize()
  addHandler(newFileLogger(defaultLog, fmtStr = verboseFmtStr))
  info("Starting client")
  let
    client = newClient("ft.noise", 1337)
    width = 20
    height = 20
    maxpixels = width * height

  var pixels = newSeq[RGBPixel](maxpixels)

  let repeat = true

  while true:

    for i in 0 ..< maxpixels:
      pixels[i] = RGBPixel(red: rand(255), green: rand(255), blue: rand(255))

    let data = client.makePPM(height, width, pixels)
    let offset = Offset(x: 0, y: 0, z: 4)

    client.sendDatagram(data, offset)

    if repeat:
      sleep(100)
    else:
     break 

