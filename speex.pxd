cdef extern from "speex/speex_types.h":
   ctypedef int spx_int16_t
   ctypedef int spx_uint16_t
   ctypedef int spx_int32_t
   ctypedef int spx_uint32_t


cdef extern from "speex/speex_bits.h":
    ctypedef struct SpeexBits:
        pass

    void speex_bits_init(SpeexBits*)
    void speex_bits_init_buffer(SpeexBits*, void*, int)
    void speex_bits_set_bit_buffer(SpeexBits*, void*, int)
    void speex_bits_destroy(SpeexBits*)
    void speex_bits_reset(SpeexBits*)
    void speex_bits_rewind(SpeexBits*)
    void speex_bits_read_from(SpeexBits*, char*, int)
    void speex_bits_read_whole_bytes(SpeexBits*, char*, int)
    int speex_bits_write(SpeexBits*, char*, int)
    int speex_bits_write_whole_bytes(SpeexBits*, char*, int)
    void speex_bits_pack(SpeexBits*, int, int)
    int speex_bits_unpack_signed(SpeexBits*, int)
    unsigned int speex_bits_unpack_unsigned(SpeexBits*, int)
    int speex_bits_nbytes(SpeexBits*)
    unsigned int speex_bits_peek_unsigned(SpeexBits*, int)
    int speex_bits_peek(SpeexBits*)
    void speex_bits_advance(SpeexBits*, int)
    int speex_bits_remaining(SpeexBits*)
    void speex_bits_insert_terminator(SpeexBits*)


cdef extern from "speex/speex_header.h":
    ctypedef struct SpeexMode:
        pass

    ctypedef struct _SpeexHeader "SpeexHeader":
        char *speex_string
        char *speex_version
        spx_int32_t speex_version_id
        spx_int32_t header_size
        spx_int32_t rate
        spx_int32_t mode
        spx_int32_t mode_bitstream_version
        spx_int32_t nb_channels
        spx_int32_t bitrate
        spx_int32_t frame_size
        spx_int32_t vbr
        spx_int32_t frames_per_packet
        spx_int32_t extra_headers
        spx_int32_t reserved1
        spx_int32_t reserved2

    void speex_init_header(_SpeexHeader*, int, int, SpeexMode*)
    char *speex_header_to_packet(_SpeexHeader*, int*)
    _SpeexHeader *speex_packet_to_header(char*, int)
    void speex_header_free(void*)


cdef extern from "speex/speex.h":
    int SPEEX_SET_ENH
    int SPEEX_GET_ENH

    int SPEEX_GET_FRAME_SIZE

    int SPEEX_SET_QUALITY

    int SPEEX_SET_MODE
    int SPEEX_GET_MODE

    int SPEEX_SET_LOW_MODE
    int SPEEX_GET_LOW_MODE

    int SPEEX_SET_HIGH_MODE
    int SPEEX_GET_HIGH_MODE

    int SPEEX_SET_VBR
    int SPEEX_GET_VBR

    int SPEEX_SET_VBR_QUALITY
    int SPEEX_GET_VBR_QUALITY

    int SPEEX_SET_COMPLEXITY
    int SPEEX_GET_COMPLEXITY

    int SPEEX_SET_BITRATE
    int SPEEX_GET_BITRATE

    int SPEEX_SET_HANDLER

    int SPEEX_SET_USER_HANDLER

    int SPEEX_SET_SAMPLING_RATE
    int SPEEX_GET_SAMPLING_RATE

    int SPEEX_RESET_STATE

    int SPEEX_GET_RELATIVE_QUALITY

    int SPEEX_SET_VAD
    int SPEEX_GET_VAD

    int SPEEX_SET_ABR
    int SPEEX_GET_ABR

    int SPEEX_SET_DTX
    int SPEEX_GET_DTX

    int SPEEX_SET_SUBMODE_ENCODING
    int SPEEX_GET_SUBMODE_ENCODING

    int SPEEX_GET_LOOKAHEAD

    int SPEEX_SET_PLC_TUNING
    int SPEEX_GET_PLC_TUNING

    int SPEEX_SET_VBR_MAX_BITRATE
    int SPEEX_GET_VBR_MAX_BITRATE

    int SPEEX_SET_HIGHPASS
    int SPEEX_GET_HIGHPASS

    int SPEEX_GET_ACTIVITY

    int SPEEX_SET_PF
    int SPEEX_GET_PF

    int SPEEX_MODE_FRAME_SIZE

    int SPEEX_SUBMODE_BITS_PER_FRAME

    int SPEEX_LIB_GET_MAJOR_VERSION
    int SPEEX_LIB_GET_MINOR_VERSION
    int SPEEX_LIB_GET_MICRO_VERSION
    int SPEEX_LIB_GET_EXTRA_VERSION
    int SPEEX_LIB_GET_VERSION_STRING

    cdef int _SPEEX_NB_MODES "SPEEX_NB_MODES"
    cdef int _SPEEX_MODEID_NB "SPEEX_MODEID_NB"
    cdef int _SPEEX_MODEID_WB "SPEEX_MODEID_WB"
    cdef int _SPEEX_MODEID_UWB "SPEEX_MODEID_UWB"

    ctypedef struct SpeexMode:
        pass

    void *speex_encoder_init(SpeexMode*)
    void speex_encoder_destroy(void*)
    int speex_encode(void*, float*, SpeexBits*)
    int speex_encode_int(void*, spx_int16_t*, SpeexBits*)
    int speex_encoder_ctl(void*, int, void*)

    void *speex_decoder_init(SpeexMode*)
    void speex_decoder_destroy(void*)
    int speex_decode(void*, SpeexBits*, float*)
    int speex_decode_int(void*, SpeexBits*, spx_int16_t*)
    int speex_decoder_ctl(void*, int, void*)

    int speex_mode_query(SpeexMode*, int, void*)

    int speex_lib_ctl(int, void*)

    extern SpeexMode speex_nb_mode
    extern SpeexMode speex_wb_mode
    extern SpeexMode speex_uwb_mode
    extern SpeexMode* speex_mode_list
    SpeexMode* speex_lib_get_mode(int)


cdef extern from "speex/speex_resampler.h":
    int SPEEX_RESAMPLER_QUALITY_MAX
    int SPEEX_RESAMPLER_QUALITY_MIN
    int SPEEX_RESAMPLER_QUALITY_DEFAULT
    int SPEEX_RESAMPLER_QUALITY_VOIP
    int SPEEX_RESAMPLER_QUALITY_DESKTOP

    int RESAMPLER_ERR_SUCCESS
    int RESAMPLER_ERR_ALLOC_FAILED
    int RESAMPLER_ERR_BAD_STATE
    int RESAMPLER_ERR_INVALID_ARG
    int RESAMPLER_ERR_PTR_OVERLAP
    int RESAMPLER_ERR_MAX_ERROR

    ctypedef struct SpeexResamplerState:
        pass

    SpeexResamplerState *speex_resampler_init(spx_uint32_t, spx_uint32_t, spx_uint32_t, int, int *)
    SpeexResamplerState *speex_resampler_init_frac(spx_uint32_t, spx_uint32_t, spx_uint32_t, spx_uint32_t, spx_uint32_t, int, int *)
    void speex_resampler_destroy(SpeexResamplerState *)

    int speex_resampler_process_float(SpeexResamplerState *, spx_uint32_t, float *, spx_uint32_t *, float *, spx_uint32_t *)
    int speex_resampler_process_int(SpeexResamplerState *, spx_uint32_t, spx_int16_t *, spx_uint32_t *, spx_int16_t *, spx_uint32_t *)
    int speex_resampler_process_interleaved_float(SpeexResamplerState *, float *, spx_uint32_t *, float *, spx_uint32_t *)
    int speex_resampler_process_interleaved_int(SpeexResamplerState *, spx_int16_t *, spx_uint32_t *,spx_int16_t *, spx_uint32_t *)

    int speex_resampler_set_rate(SpeexResamplerState *, spx_uint32_t, spx_uint32_t)
    void speex_resampler_get_rate(SpeexResamplerState *, spx_uint32_t *, spx_uint32_t *)
    int speex_resampler_set_rate_frac(SpeexResamplerState *, spx_uint32_t, spx_uint32_t, spx_uint32_t, spx_uint32_t)
    void speex_resampler_get_ratio(SpeexResamplerState *, spx_uint32_t *, spx_uint32_t *)

    int speex_resampler_set_quality(SpeexResamplerState *, int)
    void speex_resampler_get_quality(SpeexResamplerState *, int *)

    void speex_resampler_set_input_stride(SpeexResamplerState *, spx_uint32_t)
    void speex_resampler_get_input_stride(SpeexResamplerState *, spx_uint32_t *)
    void speex_resampler_set_output_stride(SpeexResamplerState *, spx_uint32_t)
    void speex_resampler_get_output_stride(SpeexResamplerState *, spx_uint32_t *)

    int speex_resampler_get_input_latency(SpeexResamplerState *)
    int speex_resampler_get_output_latency(SpeexResamplerState *)

    int speex_resampler_skip_zeros(SpeexResamplerState *)
    
    int speex_resampler_reset_mem(SpeexResamplerState *)

    char *speex_resampler_strerror(int)

