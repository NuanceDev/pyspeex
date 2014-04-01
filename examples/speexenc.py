import sys
from speex import *

def psize(size):
    buffer = b''
    mask = 0
    while (size > 0):
        buffer = bytes([(size % 2**7) | mask]) + buffer
        mask = 0x80
        size >>= 7
    return buffer


if len(sys.argv) < 3:
    print('usage: %s pcm_file speex_file')

pcm = open(sys.argv[1], 'rb').read()
encoder = WBEncoder()
vocoded = b''
packet_size = encoder.frame_size * 2 * 1
print('frame size: %d' % encoder.frame_size)
for i in range(0, len(pcm), packet_size):
    packet = pcm[i:i + packet_size]
    if len(packet) != packet_size:
        end = len(pcm) - len(pcm) % (encoder.frame_size * 2)
        packet = pcm[i:end]
        
    raw = encoder.encode(packet)
    vocoded += psize(len(raw)) + raw
    
open(sys.argv[2], 'wb+').write(vocoded)
