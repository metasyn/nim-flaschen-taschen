# Inspired via the gray-scott section of https://www.labri.fr/perso/nrougier/from-python-to-numpy/ 
# which BSD licensed (Copyright (2017) Nicolas P. Rougier - BSD license)
import math, random

import arraymancer

import ./nim_flaschen_taschen

# Parameters from http://www.aliensaint.com/uo/java/rd/
# -----------------------------------------------------

let 
  Du = 0.16
  Dv = 0.08
  F = 0.035
  k = 0.065
# Du, Dv, F, k = 0.14, 0.06, 0.035, 0.065  # Bacteria 2
# Du, Dv, F, k = 0.16, 0.08, 0.060, 0.062  # Coral
# Du, Dv, F, k = 0.19, 0.05, 0.060, 0.062  # Fingerprint
# Du, Dv, F, k = 0.10, 0.10, 0.018, 0.050  # Spirals
# Du, Dv, F, k = 0.12, 0.08, 0.020, 0.050  # Spirals Dense
# Du, Dv, F, k = 0.10, 0.16, 0.020, 0.050  # Spirals Fast
# Du, Dv, F, k = 0.16, 0.08, 0.020, 0.055  # Unstable
# Du, Dv, F, k = 0.16, 0.08, 0.050, 0.065  # Worms 1
# Du, Dv, F, k = 0.16, 0.08, 0.054, 0.063  # Worms 2
# Du, Dv, F, k = 0.16, 0.08, 0.035, 0.060  # Zebrafish

const
    n = 256
    r = 20
    starting = n.floorDiv(2) - r
    ending = n.floorDiv(2) + r

var
    Z = zeros[float]([n+2, n+2])
    U = zeros[float]([n+2, n+2])
    V = zeros[float]([n+2, n+2])
    u = U[1..^1, 1..^1] .+ 1.0
    v = V[1..^1, 1..^1]


U[starting..ending, starting..ending] = 0.50
V[starting..ending, starting..ending] = 0.25

u += (randomTensor[float]([n, n], 1) .- 1'f32) * 0.05'f32
v += (randomTensor[float]([n, n], 1) .- 1'f32) * 0.05'f32

# def update(frame):
#     global U, V, u, v, im

#     for i in range(10):
#         Lu = (                  U[0:-2, 1:-1] +
#               U[1:-1, 0:-2] - 4*U[1:-1, 1:-1] + U[1:-1, 2:] +
#                                 U[2:  , 1:-1])
#         Lv = (                  V[0:-2, 1:-1] +
#               V[1:-1, 0:-2] - 4*V[1:-1, 1:-1] + V[1:-1, 2:] +
#                                 V[2:  , 1:-1])
#         uvv = u*v*v
#         u += (Du*Lu - uvv + F*(1-u))
#         v += (Dv*Lv + uvv - (F+k)*v)

#     im.set_data(V)
#     im.set_clim(vmin=V.min(), vmax=V.max())