import net
import strformat
import strutils
import sequtils
import sugar
import pnm


import binaryparse

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

proc `$`*(p: RGBPixel): string =
  ## String-ification of the RGBPixel type
  ## to be used when creating the PPM file
  result = @[p.red, p.green, p.blue].map(x => $x).join(" ")
  result = " " & result & " "

    
proc `$`*(o: Offset): string =
  ## String-ification of the Offset type
  ## to be used when creating the PPM file
  return fmt"#FT: {o.x} {o.y} {o.z}"
 
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

proc sendDatagram*(c: Client , packet: PPM)=
    var format = packet.formatP6 
    # format.add('\n'.uint8)
    # format.add(50.uint8)
    # format.add('\n'.uint8)
    # format.add(50.uint8)
    # format.add('\n'.uint8)
    # format.add(10.uint8)
    # echo format
    c.socket.sendTo(c.address, c.port, format.addr, format.len)

proc makePPM*(c: Client, height, width: int, data: seq[RGBPixel], offset: Offset = Offset()): PPM =
  var ppmBody = newSeq[uint8]()
  for i, p in data.pairs:
    ppmBody.add(p.red.uint8)
    ppmBody.add(p.green.uint8)
    ppmBody.add(p.blue.uint8)

  result = newPPM(ppmFileDiscriptorP6, width, height, ppmBody)