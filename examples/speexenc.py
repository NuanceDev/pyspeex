import sys
from speex import *

if len(sys.argv) < 3:
    print 'usage: %s pcm_file speex_file'

pcm = open(sys.argv[1]).read()
encoder = WBEncoder()
vocoded = ''
packet_size = encoder.frame_size * 2 * 2
for i in xrange(0, len(pcm), packet_size):
    packet = pcm[i:i + packet_size]
    if len(packet) != packet_size:
        break
        
    raw = encoder.encode(packet)
    vocoded += chr(len(raw)) + raw
    
open(sys.argv[2], 'w+').write(vocoded)

