use v6;
use lib "lib";
use Test;

use Audio::Sndfile;

my $f;

my $empty-file = 't/data/empty_16le_48000_2ch.wav';

throws-like { $f = Audio::Sndfile.new() }, "Required named parameter 'filename' not passed", "constructor no args";

throws-like { $f = Audio::Sndfile.new(filename => $empty-file) }, "exactly one of ':r', ':w', ':rw' must be provided", "constructor no mode";

throws-like { $f = Audio::Sndfile.new(filename => $empty-file, :r, :rw) }, "exactly one of ':r', ':w', ':rw' must be provided", "constructor multiple modes";

lives-ok { $f = Audio::Sndfile.new(filename => $empty-file, :r) }, "constructor with sensible arguments";

isa-ok($f, Audio::Sndfile);
is($f.mode, Audio::Sndfile::OpenMode::Read, "and it has Read");

ok($f.info.format-check, "the library filled in the info so it should be good");
is($f.info.channels,2, "got the expected number of channels");
is($f.info.samplerate, 48000, "got the expected samplerate");
is($f.info.format, 65538, "And it is a WAV PCM 16LE");

throws-like { $f = Audio::Sndfile.new(filename => "bogus-test-file.wav", :r) },"System error : No such file or directory.", "constructor with bogus filename";



done();
# vim: expandtab shiftwidth=4 ft=perl6
