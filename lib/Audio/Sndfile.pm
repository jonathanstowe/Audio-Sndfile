use NativeCall;

class Audio::Sndfile {

    use Audio::Sndfile::Info;

    # The opaque type returned from open
    my class File is repr('CPointer') {

        sub sf_close(File $file) returns int is native('libsndfile') { * }

        method close() {
            sf_close(self);
        }

        sub sf_error(File $file) returns int is native('libsndfile') { * }

        method error-number() {
            sf_error(self);
        }
        sub sf_strerror(File $file) returns Str is native('libsndfile') { * }

        method error() {
            sf_strerror(self);
        }

        sub sf_readf_short(File , CArray[int16], int64) returns int64 is native('libsndfile') { * }

        method read-short(Int $frames) returns Array {
            my $buff =  CArray[int16].new;
            $buff[$frames * 2] = 0;

            my $rc = sf_readf_short(self, $buff, $frames);

            my @tmp_arr = gather {
                                    take $buff[$_] for ^$rc;
            };
            @tmp_arr;
        }

        sub sf_readf_int(File , CArray[int32], int64) returns int64 is native('libsndfile') { * }

        method read-int(Int $frames) returns Array {
            my $buff =  CArray[int32].new;
            $buff[$frames * 2] = 0;

            my $rc = sf_readf_int(self, $buff, $frames);
            my @tmp_arr = gather {
                                    take $buff[$_] for ^$rc;
            };
            @tmp_arr;
        }
        sub sf_readf_float(File , CArray[num], int64) returns int64 is native('libsndfile') { * }

        method read-float(Int $frames) returns Array {
            my $buff =  CArray[num].new;
            $buff[$frames * 2] = 0;

            my $rc = sf_readf_int(self, $buff, $frames);
            my @tmp_arr = gather {
                                    take $buff[$_] for ^$rc;
            };
            @tmp_arr;
        }

    }

    enum OpenMode (:Read(0x10), :Write(0x20), :ReadWrite(0x30));

    has Str  $.filename;
    has File $!file handles <read-short read-int read-float>;
    has Audio::Sndfile::Info $.info;
    has OpenMode $.mode;

    sub sf_version_string() returns Str is native('libsndfile') { * }

    method library-version() returns Str {
        sf_version_string();
    }

    sub sf_open(Str $filename, int $mode, Audio::Sndfile::Info $info) returns File is native('libsndfile') { * }

    submethod BUILD(Str() :$!filename!, Bool :$r, Bool :$w, Bool :$rw, *%info) {
        if one($r, $w, $rw ) {
            $!mode = do if $r {
                Read;
            }
            elsif $w {
                $!info = Audio::Sndfile::Info.new(%info);
                Write;
            }
            else {
                ReadWrite;
            }

            $!info //= Audio::Sndfile::Info.new();

            explicitly-manage($!filename);
            $!file = sf_open($!filename, $!mode.Int, $!info);

            if $!file.error-number > 0 {
                die $!file.error;
            }
        }
        else {
            die "exactly one of ':r', ':w', ':rw' must be provided";
        }
    }
}

# vim: expandtab shiftwidth=4 ft=perl6
