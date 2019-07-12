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
    client = newClient("localhost", 1337)
    width = 5
    height = 5
    maxpixels = width * height

  var pixels = newSeq[RGBPixel](maxpixels)

  let repeat =false 

  while true:

    for i in 0 ..< maxpixels:
      pixels[i] = RGBPixel(red: rand(255), green: rand(255), blue: rand(255))

    #let offset = Offset(x: rand(10), y: rand(10), z: 10)
    var data = client.makePPM(height, width, pixels) # offset)
    client.sendDatagram(data)

    var s = open("test.ppm", fmWrite)
    s.writePPM(data)
    s.close()

    s = open("test.ppm", fmRead)
    let ppm = s.readPPM()
    s.close()

    echo data.formatP6
    echo ppm.formatP6

    if repeat:
      sleep(100)
    else:
     break 

