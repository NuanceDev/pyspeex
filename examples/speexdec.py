import sys
from speex import *

def usize(buffer):
    sizes = []
    for char in buffer:
        sizes.append((ord(char) & 0x7f))
        if ord(char) & 0x80 == 0:
            break

    size = 0
    for i in xrange(len(sizes)):
        size += sizes[i] * (2**7)**(len(sizes) - i - 1)
    return len(sizes), size


if len(sys.argv) < 3:
    print 'usage: %s speex_file pcm_file'

vocoded = open(sys.argv[1]).read()
decoder = WBDecoder()
i = 0
pcm = ''
while i < len(vocoded):
    header_size, packet_size = usize(vocoded[i:])
    print 'Header: %d  Packet: %d' % (header_size, packet_size)
    pcm += decoder.decode(vocoded[i + header_size:i + header_size + packet_size])
    print 'PCM length: %d' % len(pcm)
    i += header_size + packet_size
    
open(sys.argv[2], 'w+').write(pcm)

