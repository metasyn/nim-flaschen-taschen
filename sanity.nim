import net
import random
import sequtils

randomize(123)

let
    address = "localhost"
    port = 1337.Port
    socket = newSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)

var arrayData: array[86, uint8]
var seqData = newSeq[uint8](86)

for i in 0..<86:
    let value = rand(255).uint8
    arrayData[i] = value
    seqData[i] = value

assert arrayData == seqData

socket.sendTo(address, port, arrayData.addr, arrayData.len)

socket.sendTo(address, port, seqData.addr, seqData.len)

