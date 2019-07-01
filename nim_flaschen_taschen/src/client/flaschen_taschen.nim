import net
import strformat
import strutils
import sequtils
import sugar

type
  Client* = object
    address*: string
    port*: Port
    socket: Socket

type
  RGBPixel* = object
    red*: int
    green*: int
    blue*: int

proc `$`*(p: RGBPixel): string =
  ## String-ification of the RGBPixel type
  ## to be used when creating the PPM file
  result = @[p.red, p.green, p.blue].map(x => $x).join(" ")
  result = " " & result & " "

type
  Offset* = object
    x*: int
    y*: int
    z*: int
    
proc `$`*(o: Offset): string =
  ## String-ification of the Offset type
  ## to be used when creating the PPM file
  return fmt"#FT: {o.x} {o.y} {o.z}"
 
proc newClient*(address: string, port: int): Client =
  result = Client(
    address: address,
    port: Port(port),
    socket: newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP),
  )

proc sendDatagram*(c: Client , data: seq[byte]) =
    let
      dataptr = data.unsafeAddr
      datasize = data.len
    c.socket.sendTo(c.address, c.port, dataptr, datasize)

proc makePPM*(c: Client, height, width: int, data: seq[RGBPixel], offset: Offset = Offset()): seq[byte] =
  let header = @["P6", fmt"{width} {height}", $offset, "255"].join("\n") & "\n"
  result = cast[seq[byte]](header.toSeq())
  var thing = header.toOpenArray[byte](0, header.high)

  readV
  
  for i, pixel in data.pairs:
    if len(result) mod 70 == 0:
      result = result & cast[byte]("\n")
    result = result & pixel.red & pixel.green & pixel.blue