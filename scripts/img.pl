#!/usr/bin/perl

use strict;
use warnings;

use English;

use File::Spec;
use FindBin '$Bin';
use Data::Dumper;
use File::Copy;
use Data::UUID;
use File::Glob;
use Pod::Usage;
use Getopt::Long;
use File::Basename;
use Digest::MD5::File qw(file_md5_hex);

our $VERSION = '0.1';

my ($dryrun, $debug, $help, $man);
my $verbose = 1;

my (@dirs, $outdir);
# $outdir = './';

GetOptions(
    'dryrun'   => \$dryrun,
    'verbose+' => \$verbose,
    'debug'    => \$debug,
    'help'     => \$help,
    'man'      => \$man,
    'quiet'    => sub { $verbose = 0; },
    'dir=s'    => \@dirs,
    'out=s'    => \$outdir,
);

pod2usage(1) if ($help || ! @dirs);
pod2usage(-exitstatus => 0, -verbose => 2) if ($man);

if ($outdir && $outdir !~ m!/$!) {
	$outdir .= '/';
}

my (@files);
my @argv_globbed = map { File::Glob::bsd_glob($_) } @dirs;

for ( @argv_globbed ) {
    push( @files, -d $_ ? all_in( { recurse => 1, start => $_ } ) : $_ )
}

my $count = scalar @files;

print "Processing $count files\n" if ($verbose || $debug);

my %hashfiles;
foreach my $file (@files) {
	my $md5sum = file_md5_hex($file);
	push @{ $hashfiles{$md5sum} }, $file;
}

print "Removing duplicates and renaming files\n" if ($debug);

for my $hash (keys %hashfiles) {
	my @item = @{ $hashfiles{$hash} };
	my $itemcount = scalar @item;
	move_file(shift @item);
	if ($itemcount > 1) {
		for my $ofile ( @item) {
			print "Deleting dupe '$ofile'\n" if ($debug);
			unlink $ofile;
		}
	}
}

sub new_id {
    return lc Data::UUID->new->create_str();
}

sub move_file {
	my ($filename) = @_;
	my ($name, $path, $suffix) = fileparse($filename, qr/\.[^.]*/);
	my $new_filename = ($outdir || $path) . new_id() . $suffix;
	print "Moving '$filename' to '$new_filename'\n" if ($debug);
	move($filename, $new_filename);
	return 1;
}

=pod

=head1 NAME

img.pl - Organize and rename a bunch of files

=head1 DESCRIPTION

B<img.pl> will take all of the files passed to it and attempt to remove all
duplicates before renaming base on unique UUIDs.

=head1 SYNOPSIS

img.pl [options]

 Options:
   --help            brief help message
   --man             full documentation
   --dryrun          Prepare everything but don't make the http post
   --verbose         (default on) print some useful information
   --debug           Display debug information.
   --quiet           Don't display anything.

   --entries=123     [REQUIRED] A csv of entries to flood
   --user_id=1       [REQUIRED 1.9.0+] The user_id to match
   --cons=5          Number of parallel requests to make (Default 5)
   --jobs=5          Number of requests to make, note that this number is
                     multiplied by 1,000. (Default 5)

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--dryrun>

Do not perform any action, just prepare for it.

=item B<--verbose>

Display verbose status information.

=item B<--debug>

Display debug information.

=item B<--quiet>

Do not display ANYTHING. This is discouraged.

=item B<--dir>

One or more directories containing files.

  --dir=*
  --dir=tmp/*
  --dir=tmp/* --dir=tmp2/*
  --dir=tmp/*.jpg --dir=tmp2/*.gif

=item B<--out>

The directory that all of the agregated files will be moved to.

=back

=cut
