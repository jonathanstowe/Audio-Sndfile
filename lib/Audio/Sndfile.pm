use NativeCall;

class Audio::Sndfile {

    use Audio::Sndfile::Info;

    # The opaque type returned from open
    my class File is repr('CPointer') {

        sub sf_close(File $file) returns int32 is native('libsndfile') { * }

        method close() {
            sf_close(self);
        }

        sub sf_error(File $file) returns int32 is native('libsndfile') { * }

        method error-number() {
            sf_error(self);
        }
        sub sf_strerror(File $file) returns Str is native('libsndfile') { * }

        method error() {
            sf_strerror(self);
        }

        method !read-read(Int $frames, Audio::Sndfile::Info $info, &read-sub, $buff) returns Array {
            $buff[$frames * $info.channels] = 0;

            my $rc = &read-sub(self, $buff, $frames);

            my @tmp_arr =  (^($rc * $info.channels)).map({ $buff[$_] });
            
            @tmp_arr;
        }

        sub sf_readf_short(File , CArray[int16], int64) returns int64 is native('libsndfile') { * }

        method read-short(Int $frames, Audio::Sndfile::Info $info) returns Array {
            my $buff =  CArray[int16].new;
            self!read-read($frames, $info, &sf_readf_short, $buff);
        }

        sub sf_readf_int(File , CArray[int32], int64) returns int64 is native('libsndfile') { * }

        method read-int(Int $frames, Audio::Sndfile::Info $info) returns Array {
            my $buff =  CArray[int32].new;
            self!read-read($frames, $info, &sf_readf_int, $buff);
        }

        sub sf_readf_double(File , CArray[num64], int64) returns int64 is native('libsndfile') { * }

        method read-double(Int $frames, Audio::Sndfile::Info $info) returns Array {
            my $buff =  CArray[num64].new;
            self!read-read($frames, $info, &sf_readf_double, $buff);
        }

        sub sf_readf_float(File , CArray[num32], int64) returns int64 is native('libsndfile') { * }

        method read-float(Int $frames, Audio::Sndfile::Info $info) returns Array {
            my $buff =  CArray[num32].new;
            self!read-read($frames, $info, &sf_readf_float, $buff);
        }

        sub sf_write_sync(File) is native('libsndfile') { * }

        method sync() {
            sf_write_sync(self);
        }

    }

    enum OpenMode (:Read(0x10), :Write(0x20), :ReadWrite(0x30));

    has Str  $.filename;
    has File $!file handles <close>; 
    has Audio::Sndfile::Info $.info;
    has OpenMode $.mode;

    sub sf_version_string() returns Str is native('libsndfile') { * }

    method library-version() returns Str {
        sf_version_string();
    }

    sub sf_open(Str $filename, int32 $mode, Audio::Sndfile::Info $info) returns File is native('libsndfile') { * }

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

    method read-short(Int $frames) returns Array {
        $!file.read-short($frames, $!info);
    }

    method read-int(Int $frames) returns Array {
        $!file.read-int($frames, $!info);
    }
        
    method read-float(Int $frames) returns Array {
        $!file.read-float($frames, $!info);
    }
        
    method read-double(Int $frames) returns Array {
        $!file.read-double($frames, $!info);
    }
}

multi sub infix:<~~> (Audio::Sndfile:D $as, Audio::Sndfile::Info::Format $type) { $as.info.type == $type }

# vim: expandtab shiftwidth=4 ft=perl6
