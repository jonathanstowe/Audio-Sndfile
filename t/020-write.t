#!perl6

use v6;
use lib 'lib';
use Test;
use Shell::Command;

use Audio::Sndfile;

my $test-output = "t/test-output".IO;

$test-output.mkdir unless $test-output.d;

my @tests = (
                {
                    type => Audio::Sndfile::Info::CAF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.caf",
                    format => 1572870,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::W64,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.w64",
                    format => 720902,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::W64,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.w64",
                    format => 720902,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.aifc",
                    format => 131078,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.aif",
                    format => 131078,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AU,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.au",
                    format => 196614,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::WAV,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.wav",
                    format => 65542,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::W64,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.w64",
                    format => 720902,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.aiff",
                    format => 131078,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::WAV,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.wav",
                    format => 65542,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.aifc",
                    format => 131078,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.aiff",
                    format => 131078,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.aif",
                    format => 131078,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AU,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.au",
                    format => 196614,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.aif",
                    format => 131078,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AU,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.au",
                    format => 196614,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::WAV,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.wav",
                    format => 65542,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::CAF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.caf",
                    format => 1572870,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-44100.aiff",
                    format => 131078,
                    frames => 44100,
                    sample-rate => 44100,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::CAF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-48000.caf",
                    format => 1572870,
                    frames => 48000,
                    sample-rate => 48000,
                    sections => 1,
                    seekable => True
                },
                {
                    type => Audio::Sndfile::Info::AIFF,
                    channels => 1,
                    filename => "t/data/1sec-chirp-22050.aifc",
                    format => 131078,
                    frames => 22050,
                    sample-rate => 22050,
                    sections => 1,
                    seekable => True
                }
        );

throws-like { my $obj = Audio::Sndfile.new(filename => "ook.wav", :w) }, "invalid format supplied to :w";

for @tests -> $file {
    my $basename = $file<filename>.IO.basename;

    my $obj = Audio::Sndfile.new(filename => $file<filename>, :r);

    my $cinfo;
    lives-ok { $cinfo = $obj.clone-info }, "clone-info for " ~ $file<filename>;
    ok($cinfo.format-check, "format-check on clone");
    is($cinfo.samplerate, $obj.samplerate, "samplerate the same");
    is($cinfo.channels, $obj.channels, "channels the same");
    is($cinfo.format, $obj.format, "format the same");

    my @ints = $obj.read-int(100);
    my $int-name = $test-output.child("int-$basename");

    my $int-obj;
    lives-ok { $int-obj = Audio::Sndfile.new(filename => $int-name, info => $cinfo, :w) }, "open $int-name for writing";



    my @shorts = $obj.read-short(100);
    my $short-name = $test-output.child("short-$basename");
    my @floats = $obj.read-float(100);
    my $float-name = $test-output.child("float-$basename");
    my @doubles = $obj.read-double(100);
    my $double-name = $test-output.child("double-$basename");
    $obj.close;

}

done;

END {
    rm_rf $test-output;
}

# vim: expandtab shiftwidth=4 ft=perl6
