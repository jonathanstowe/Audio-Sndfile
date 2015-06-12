use NativeCall;

class Audio::Sndfile::Info is repr('CStruct') {
    has int64     $.frames;
    has int32     $.samplerate;
    has int32     $.channels;
    has int32     $.format;
    has int32     $.sections;
    has int32     $.seekable;

    sub  sf_format_check(Audio::Sndfile::Info $info) returns int32 is native('libsndfile') { * }

    # Masks to get at the parts of format
    constant SUBMASK    = 0x0000FFFF;
    constant TYPEMASK   = 0x0FFF0000;
    constant ENDMASK    = 0x30000000;

    # the endian-ness of the data
    enum End( :File(0x00000000), :Little(0x10000000), :Big(0x20000000), :Cpu(0x30000000));

    # The basic format of the file
    enum Format(
        :WAV(0x010000),
        :AIFF(0x020000),
        :AU(0x030000),
        :RAW(0x040000),
        :PAF(0x050000),
        :SVX(0x060000),
        :NIST(0x070000),
        :VOC(0x080000),
        :IRCAM(0x0A0000),
        :W64(0x0B0000),
        :MAT4(0x0C0000),
        :MAT5(0x0D0000),
        :PVF(0x0E0000),
        :XI(0x0F0000),
        :HTK(0x100000),
        :SDS(0x110000),
        :AVR(0x120000),
        :WAVEX(0x130000),
        :SD2(0x160000),
        :FLAC(0x170000),
        :CAF(0x180000),
        :WVE(0x190000),
        :OGG(0x200000),
        :MPC2K(0x210000),
        :RF64(0x220000)
    );

    # the subformat or encoding of the data
    enum Subformat(
        :PCM_S8(0x0001),
        :PCM_16(0x0002),
        :PCM_24(0x0003),
        :PCM_32(0x0004),
        :PCM_U8(0x0005),
        :FLOAT(0x0006),
        :DOUBLE(0x0007),
        :ULAW(0x0010),
        :ALAW(0x0011),
        :IMA_ADPCM(0x0012),
        :MS_ADPCM(0x0013),
        :GSM610(0x0020),
        :VOX_ADPCM(0x0021),
        :G721_32(0x0030),
        :G723_24(0x0031),
        :G723_40(0x0032),
        :DWVW_12(0x0040),
        :DWVW_16(0x0041),
        :DWVW_24(0x0042),
        :DWVW_N(0x0043),
        :DPCM_8(0x0050),
        :DPCM_16(0x0051),
        :VORBIS(0x0060)
    );
    method format-check() returns Bool {
        sf_format_check(self) == 1 ?? True !! False;
    }

    method type() returns Format {
        Format($!format +& TYPEMASK);
    }

    method sub-type() returns Subformat {
        Subformat($!format +& SUBMASK);
    }

    method endian() returns End {
        End($!format +& ENDMASK);
    }

    method duration() returns Duration {
        Duration.new($!frames/$!samplerate);
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
