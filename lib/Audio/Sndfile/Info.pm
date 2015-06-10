use NativeCall;

class Audio::Sndfile::Info is repr('CStruct') {
    has int64   $.frames;
    has int32     $.samplerate;
    has int32     $.channels;
    has int32     $.format;
    has int32     $.sections;
    has int32     $.seekable;

    sub  sf_format_check(Audio::Sndfile::Info $info) returns int is native('libsndfile') { * }

    method format-check() returns Bool {
        sf_format_check(self) == 1 ?? True !! False;
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
