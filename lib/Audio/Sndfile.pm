use NativeCall;

=begin pod

=head1 NAME

Audio::Sndfile - read/write audio data via libsndfile

=head1 SYNOPSIS

=begin code

=end code

Other examples are available in the "examples" sub-directory of the
repository.

=head1 DESCRIPTION

This library provides a mechanism to read and write audio data files in
various formats by using the API provided by libsndfile.

A full list of the formats it is able to work with can be found at:

http://www.mega-nerd.com/libsndfile/#Features

if you need to work with formats that aren't listed then you will need to
find another library.

The interface presented is slightly simplified with regard to that of
libsndfile and whilst it does nearly everything I need it do, I have opted
to release the most useful functionality early and progressively add
features as it becomes clear how they should be implemented.


=head2 METHODS


=end pod

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

        method !read-read(Int $frames, Audio::Sndfile::Info $info, &read-sub, Mu:U $type) returns Array {

            my @buff := CArray[$type].new;
            @buff[$frames * $info.channels] = 0;

            my $rc = &read-sub(self, @buff, $frames);

            my @tmp_arr =  (^($rc * $info.channels)).map({ @buff[$_] });
            
            @tmp_arr;
        }

        method !write-write(Audio::Sndfile::Info $info, &write-sub, Mu:U $type, @items) returns Int {

            my @buff := CArray[$type].new;
            @buff[$_] = @items[$_] for ^@items.elems;

            my Int $frames = (@items.elems / $info.channels).Int;
            &write-sub(self, @buff, $frames);
        }

        sub sf_readf_short(File , CArray[int16] is rw, int64) returns int64 is native('libsndfile') { * }


        method read-short(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self!read-read($frames, $info, &sf_readf_short, int16);
        }

        sub sf_writef_short(File , CArray[int16], int64) returns int64 is native('libsndfile') { * }

        method write-short(Audio::Sndfile::Info $info, @items ) returns Int {
            self!write-write($info, &sf_writef_short, int16, @items);
        }

        sub sf_readf_int(File , CArray[int32], int64) returns int64 is native('libsndfile') { * }

        method read-int(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self!read-read($frames, $info, &sf_readf_int, int32);
        }

        sub sf_writef_int(File , CArray[int32], int64) returns int64 is native('libsndfile') { * }

        method write-int(Audio::Sndfile::Info $info, @items ) returns Int {
            self!write-write($info, &sf_writef_int, int32, @items);
        }

        sub sf_readf_double(File , CArray[num64] is rw, int64) returns int64 is native('libsndfile') { * }

        method read-double(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self!read-read($frames, $info, &sf_readf_double, num64);
        }

        sub sf_writef_double(File , CArray[num64], int64) returns int64 is native('libsndfile') { * }

        method write-double(Audio::Sndfile::Info $info, @items ) returns Int {
            self!write-write($info, &sf_writef_double, num64, @items);
        }

        sub sf_readf_float(File , CArray[num32] is rw, int64) returns int64 is native('libsndfile') { * }

        method read-float(Int $frames, Audio::Sndfile::Info $info) returns Array {
            self!read-read($frames, $info, &sf_readf_float, num32);
        }

        sub sf_writef_float(File , CArray[num32], int64) returns int64 is native('libsndfile') { * }

        method write-float(Audio::Sndfile::Info $info, @items ) returns Int {
            self!write-write($info, &sf_writef_float, num32, @items);
        }

        sub sf_write_sync(File) is native('libsndfile') { * }

        method sync() {
            sf_write_sync(self);
        }

    }

    enum OpenMode (:Read(0x10), :Write(0x20), :ReadWrite(0x30));

    has Str  $.filename;
    has File $!file handles <close error-number error>; 
    has Audio::Sndfile::Info $.info handles <format channels samplerate frames sections seekable type sub-type endian duration>;
    has OpenMode $.mode;

    sub sf_version_string() returns Str is native('libsndfile') { * }

    method library-version() returns Str {
        sf_version_string();
    }

    sub sf_open(Str $filename, int32 $mode, Audio::Sndfile::Info $info) returns File is native('libsndfile') { * }

    submethod BUILD(Str() :$!filename!, Bool :$r, Bool :$w, Bool :$rw, Audio::Sndfile::Info :$!info?,  *%info) {
        if one($r, $w, $rw ) {
            $!mode = do if $r {
                Read;
            }
            elsif $w {
                $!info //= Audio::Sndfile::Info.new(|%info);
                die "invalid format supplied to :w" if not $!info.format-check;
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

    method write-short(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-short($!info, @frames);
    }

    method read-int(Int $frames) returns Array {
        $!file.read-int($frames, $!info);
    }
        
    method write-int(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-int($!info, @frames);
    }

    method read-float(Int $frames) returns Array {
        $!file.read-float($frames, $!info);
    }
        
    method write-float(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-float($!info, @frames);
    }

    method read-double(Int $frames) returns Array {
        $!file.read-double($frames, $!info);
    }

    method write-double(@frames) returns Int {
        self!assert-frame-length(@frames);
        $!file.write-double($!info, @frames);
    }

    method !assert-frame-length(@frames) {
        if (@frames.elems % $!info.channels) != 0 {
            die "items not a multiple of channels";
        }
    }

    # minimum detail required
    method clone-info() {
        Audio::Sndfile::Info.new(
                                    samplerate  => $!info.samplerate,
                                    channels    => $!info.channels,
                                    format      => $!info.format
                                );
    }

    method Numeric() {
        $!info.type;
    }

}


# vim: expandtab shiftwidth=4 ft=perl6
