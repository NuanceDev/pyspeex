cimport cython
cimport cython.view
import logging
from speex cimport *
from libc.stdlib cimport free, malloc
from libc.string cimport memcpy

logger = logging.getLogger(__name__)


speex_cmd_types = {
    'enh'               : bool,
    'frame_size'        : int,
    'quality'           : int,
    'mode'              : int,
    'low_mode'          : int,
    'high_mode'         : int,
    'vbr'               : bool,
    'vbr_quality'       : float,
    'complexity'        : int,
    'bitrate'           : int,
    'sampling_rate'     : int,
    'relative_quality'  : float,
    'vad'               : bool,
    'abr'               : int,
    'dtx'               : bool,
    'submode_encoding'  : bool,
    'lookahead'         : int,
    'plc_tuning'        : int,
    'vbr_max_bitrate'   : int,
    'highpass'          : bool,
    'activity'          : int
}

speex_cmds = {
    'SPEEX_SET_ENH' : SPEEX_SET_ENH,
    'SPEEX_GET_ENH' : SPEEX_GET_ENH,
    'SPEEX_GET_FRAME_SIZE' : SPEEX_GET_FRAME_SIZE,
    'SPEEX_SET_QUALITY' : SPEEX_SET_QUALITY,
    'SPEEX_SET_MODE' : SPEEX_SET_MODE,
    'SPEEX_GET_MODE' : SPEEX_GET_MODE,
    'SPEEX_SET_LOW_MODE' : SPEEX_SET_LOW_MODE,
    'SPEEX_GET_LOW_MODE' : SPEEX_GET_LOW_MODE,
    'SPEEX_SET_HIGH_MODE' : SPEEX_SET_HIGH_MODE,
    'SPEEX_GET_HIGH_MODE' : SPEEX_GET_HIGH_MODE,
    'SPEEX_SET_VBR' : SPEEX_SET_VBR,
    'SPEEX_GET_VBR' : SPEEX_GET_VBR,
    'SPEEX_SET_VBR_QUALITY' : SPEEX_SET_VBR_QUALITY,
    'SPEEX_GET_VBR_QUALITY' : SPEEX_GET_VBR_QUALITY,
    'SPEEX_SET_COMPLEXITY' : SPEEX_SET_COMPLEXITY,
    'SPEEX_GET_COMPLEXITY' : SPEEX_GET_COMPLEXITY,
    'SPEEX_SET_BITRATE' : SPEEX_SET_BITRATE,
    'SPEEX_GET_BITRATE' : SPEEX_GET_BITRATE,
    'SPEEX_SET_SAMPLING_RATE' : SPEEX_SET_SAMPLING_RATE,
    'SPEEX_GET_SAMPLING_RATE' : SPEEX_GET_SAMPLING_RATE,
    'SPEEX_GET_RELATIVE_QUALITY' : SPEEX_GET_RELATIVE_QUALITY,
    'SPEEX_SET_VAD' : SPEEX_SET_VAD,
    'SPEEX_GET_VAD' : SPEEX_GET_VAD,
    'SPEEX_SET_ABR' : SPEEX_SET_ABR,
    'SPEEX_GET_ABR' : SPEEX_GET_ABR,
    'SPEEX_SET_DTX' : SPEEX_SET_DTX,
    'SPEEX_GET_DTX' : SPEEX_GET_DTX,
    'SPEEX_SET_SUBMODE_ENCODING' : SPEEX_SET_SUBMODE_ENCODING,
    'SPEEX_GET_SUBMODE_ENCODING' : SPEEX_GET_SUBMODE_ENCODING,
    'SPEEX_GET_LOOKAHEAD' : SPEEX_GET_LOOKAHEAD,
    'SPEEX_SET_PLC_TUNING' : SPEEX_SET_PLC_TUNING,
    'SPEEX_GET_PLC_TUNING' : SPEEX_GET_PLC_TUNING,
    'SPEEX_SET_VBR_MAX_BITRATE' : SPEEX_SET_VBR_MAX_BITRATE,
    'SPEEX_GET_VBR_MAX_BITRATE' : SPEEX_GET_VBR_MAX_BITRATE,
    'SPEEX_SET_HIGHPASS' : SPEEX_SET_HIGHPASS,
    'SPEEX_GET_HIGHPASS' : SPEEX_GET_HIGHPASS,
    'SPEEX_GET_ACTIVITY' : SPEEX_GET_ACTIVITY
}

SPEEX_NB_MODES = _SPEEX_NB_MODES
SPEEX_MODEID_NB = _SPEEX_MODEID_NB
SPEEX_MODEID_WB = _SPEEX_MODEID_WB
SPEEX_MODEID_UWB = _SPEEX_MODEID_UWB


def _speex_getter(name):
    return speex_cmds.get('SPEEX_GET_' + name.upper())

def _speex_setter(name):
    return speex_cmds.get('SPEEX_SET_' + name.upper())
    

cdef class SpeexCoder(object):
    cdef SpeexBits _bits
    cdef void* _state

    cdef _coder_ctl(self, cmd, void* ptr):
        pass

    cdef _ctl(self, cmd, void* ptr):
        error = self._coder_ctl(cmd, ptr)
        if error == -1:
            raise TypeError("'%s' in wrong state" % type(self).__name__)
        elif error == -2:
            raise TypeError('Invalid parameter')
            
    def __getattr__(self, name):
        cmd = _speex_getter(name)
        if cmd is None:
            if _speex_setter(name):
                raise AttributeError("'%s' object attribute '%s' is write-only" %
                                     (type(self).__name__, name))
            else:
                # Cython doesn't play nice with Python superclasses and __setattr__
                # so just raise the expected exception
                raise AttributeError("'%s' object has no attribute '%s'" % 
                                     (type(self).__name__, name))
        
        cdef int int_value
        cdef float float_value
        cdef bint bint_value
        ctype = speex_cmd_types[name]
        if ctype == int:
            self._ctl(cmd, &int_value)
            return int_value

        elif ctype == float:
            self._ctl(cmd, &float_value)
            return float_value

        elif ctype == bool:
            self._ctl(cmd, &bint_value)
            return bint_value

        else:
            raise TypeError("Invalid type '%s' for attribute '%s'" %
                            (ctype, name))
        
    def __setattr__(self, name, value):
        cmd = _speex_setter(name)
        if cmd is None:
            if _speex_getter(name):
                raise AttributeError("'%s' object attribute '%s' is read-only" %
                                     (type(self).__name__, name))
            else:
                # Cython doesn't play nice with Python superclasses and __setattr__
                # so just raise an exception
                raise AttributeError("'%s' object has no attribute '%s'" % 
                                     (type(self).__name__, name))
        
        cdef int int_value
        cdef float float_value
        cdef bint bint_value
        ctype = speex_cmd_types[name]
        if ctype == int:
            int_value = value
            self._ctl(cmd, &int_value)

        elif ctype == float:
            float_value = value
            self._ctl(cmd, &float_value)

        elif ctype == bool:
            bint_value = value
            self._ctl(cmd, &bint_value)

        else:
            raise TypeError("Invalid type '%s' for attribute '%s'" %
                            (ctype, name))

    
cdef class SpeexEncoder(SpeexCoder):
    def __init__(self, mode, **kwargs):
        speex_bits_init(&self._bits)
        self._state = speex_encoder_init(speex_lib_get_mode(mode))

        for key, value in kwargs.iteritems():
            setattr(self, key, value)
        
    def __dealloc__(self):
        speex_bits_destroy(&self._bits)
        if self._state is not NULL:
            speex_encoder_destroy(self._state)
        
    cdef _coder_ctl(self, cmd, void* ptr):
        return speex_encoder_ctl(self._state, cmd, ptr)
        
    def encode(self, pcm):
        frame_bytes = self.frame_size * 2
        if len(pcm) % frame_bytes != 0:
            raise ValueError('PCM buffer must be a multiple of frame size')
            
        speex_bits_reset(&self._bits)
        for i in xrange(0, len(pcm), frame_bytes):
            frame = pcm[i:i + frame_bytes]
            speex_encode_int(self._state,
                             <spx_int16_t*><char*>frame,
                             &self._bits)
            
        speex_bits_insert_terminator(&self._bits)
        size = speex_bits_nbytes(&self._bits)
        cdef char* tmp = <char*> malloc(size)
        size = speex_bits_write(&self._bits, tmp, size)
        vocoded = tmp[:size]
        free(tmp)
        return vocoded


cdef class SpeexDecoder(SpeexCoder):
    cdef int _frame_size
    
    def __init__(self, mode, **kwargs):
        speex_bits_init(&self._bits)
        self._state = speex_decoder_init(speex_lib_get_mode(mode))

        for key, value in kwargs.iteritems():
            setattr(self, key, value)

        self._frame_size = self.frame_size

    def __dealloc__(self):
        speex_bits_destroy(&self._bits)
        if self._state is not NULL:
            speex_decoder_destroy(self._state)
        
    cdef _coder_ctl(self, cmd, void* ptr):
        return speex_decoder_ctl(self._state, cmd, ptr)
        
    def decode(self, vocoded):
        frame_bytes = self.frame_size * 2
        cdef char* frame = <char*> malloc(frame_bytes)
        pcm = b''
        speex_bits_read_from(&self._bits, vocoded, len(vocoded));
        while speex_decode_int(self._state, &self._bits, <spx_int16_t*> frame) == 0:
            pcm += frame[:frame_bytes]

        free(frame)
        return pcm

    
class NBEncoder(SpeexEncoder):
    def __init__(self):
        super(NBEncoder, self).__init__(SPEEX_MODEID_NB)

        
class WBEncoder(SpeexEncoder):
    def __init__(self):
        super(WBEncoder, self).__init__(SPEEX_MODEID_WB)

        
class UWBEncoder(SpeexEncoder):
    def __init__(self):
        super(UWBEncoder, self).__init__(SPEEX_MODEID_UWB)
        
        
class NBDecoder(SpeexDecoder):
    def __init__(self):
        super(NBDecoder, self).__init__(SPEEX_MODEID_NB)

        
class WBDecoder(SpeexDecoder):
    def __init__(self):
        super(WBDecoder, self).__init__(SPEEX_MODEID_WB)

        
class UWBDecoder(SpeexDecoder):
    def __init__(self):
        super(UWBDecoder, self).__init__(SPEEX_MODEID_UWB)


cdef class SpeexHeader(object):
    cdef _SpeexHeader _header
    
    def __init__(self, rate, channels, mode):
        speex_init_header(&self._header, rate, channels, speex_lib_get_mode(mode))

    @classmethod
    def from_packet(cls, packet):
        cdef SpeexHeader self = cls.__new__(SpeexHeader)
        cdef _SpeexHeader *header = speex_packet_to_header(packet, len(packet))
        if not header:
            raise ValueError('Invalid header packet')
        
        memcpy(&self._header, header, sizeof(_SpeexHeader))
        speex_header_free(header)
        return self

    def to_packet(self):
        cdef int size
        _packet = speex_header_to_packet(&self._header, &size)
        packet = _packet[:size]
        speex_header_free(_packet)
        return packet

    def __getattr__(self, name):
        if name in self._header:
            return self._header.get(name)
        else:
            # Cython doesn't play nice with Python superclasses and __setattr__
            # so just raise the expected exception
            raise AttributeError("'%s' object has no attribute '%s'" % 
                                 (type(self).__name__, name))
        
    def __setattr__(self, name, value):
        if name == 'speex_string':
            memcpy(self._header.speex_string, <char *> value, len(value) + 1)
        elif name == 'speex_version':
            memcpy(self._header.speex_version, <char *> value, len(value) + 1)
        elif name == 'speex_version_id':
            self._header.speex_version_id = value
        elif name == 'header_size':
            self._header.header_size = value
        elif name == 'rate':
            self._header.rate = value
        elif name == 'mode':
            self._header.mode = value
        elif name == 'mode_bitstream_version':
            self._header.mode_bitstream_version = value
        elif name == 'nb_channels':
            self._header.nb_channels = value
        elif name == 'bitrate':
            self._header.bitrate = value
        elif name == 'frame_size':
            self._header.frame_size = value
        elif name == 'vbr':
            self._header.vbr = value
        elif name == 'frames_per_packet':
            self._header.frames_per_packet = value
        elif name == 'extra_headers':
            self._header.extra_headers = value
        elif name == 'reserved1':
            self._header.reserved1 = value
        elif name == 'reserved2':
            self._header.reserved2 = value
        else:
            # Cython doesn't play nice with Python superclasses and __setattr__
            # so just raise the expected exception
            raise AttributeError("'%s' object has no attribute '%s'" % 
                                 (type(self).__name__, name))
        
cdef class SpeexResampler(object):
    cdef SpeexResamplerState *_resampler

    def __init__(self, channels, input_rate, output_rate, quality = SPEEX_RESAMPLER_QUALITY_DEFAULT):
        cdef int err
        self._resampler = speex_resampler_init(channels, input_rate, output_rate, quality, &err)

    def process(self, samples, channel = 0, data_type = int):
        if data_type == int:
            return self._process_int(samples, channel)
        #elif data_type == float:
        #    return self._process_float(samples, channel)
        else:
            raise TypeError('data_type %s not supported' % str(data_type))

    cdef _process_int(self, samples, channel = 0):
        cdef spx_uint32_t in_len, out_len, offset = 0
        cdef char *out_buf
        resamples = b''

        while offset < len(samples):
            in_len = (len(samples) - offset) / sizeof(spx_int16_t)
            out_len = 4096 / sizeof(spx_int16_t)
            out_buf = <char *> malloc(4096)
            speex_resampler_process_int(self._resampler,
                                        channel,
                                        <spx_int16_t *> ((<char *> samples) + offset),
                                        &in_len,
                                        <spx_int16_t *> out_buf,
                                        &out_len)
            resamples += out_buf[:out_len * sizeof(spx_int16_t)]
            offset += in_len * sizeof(spx_int16_t)
            free(out_buf)
            
        return resamples
