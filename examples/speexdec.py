import sys
from speex import *

if len(sys.argv) < 3:
    print 'usage: %s speex_file pcm_file'

vocoded = open(sys.argv[1]).read()
decoder = WBDecoder()
i = 0
pcm = ''
while i < len(vocoded):
    packet_size = ord(vocoded[i])
    pcm += decoder.decode(vocoded[i + 1:i + 1 + packet_size])
    i += packet_size + 1
    
open(sys.argv[2], 'w+').write(pcm)

