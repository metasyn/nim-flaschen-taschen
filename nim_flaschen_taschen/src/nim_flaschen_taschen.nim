import logging
import random
import os
import streams
import pnm

import client/flaschen_taschen

const defaultLog = "/tmp/nim-flaschen-taschen.log"

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
    let offset = Offset(x: 10, y: 10, z: 4)

    client.sendDatagram(data, offset)

    if repeat:
      sleep(100)
    else:
     break 

