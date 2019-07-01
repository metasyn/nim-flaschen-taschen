import logging
import random
import os

import client/flaschen_taschen

const defaultLog = "/tmp/nim-flaschen-taschen.log"

when isMainModule:
  randomize()
  addHandler(newFileLogger(defaultLog, fmtStr = verboseFmtStr))
  info("Starting client")
  let
    client = newClient("localhost", 1337)
    width = 10
    height = 10
    maxpixels = width * height

  var pixels = newSeq[RGBPixel](maxpixels)

  #while true:

  for i in 0 ..< maxpixels:
    #pixels[i] = RGBPixel(red: rand(255), green: rand(255), blue: rand(255))
    pixels[i] = RGBPixel(red: 20, green: 20, blue: 20)

# let offset = Offset(x: 10, y: 20, z: 0)
  let data = client.makePPM(height, width, pixels)# offset)
  client.sendDatagram(data)

  # sleep(100)

