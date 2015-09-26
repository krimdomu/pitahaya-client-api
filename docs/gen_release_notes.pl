#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Text::Markdown 'markdown';

use lib '../lib';

my $rel_dir = $ARGV[0];

if ( !$rel_dir ) {
  print "Usage: $0 <rel-dir>\n";
  exit 1;
}

use Pitahaya::API;

use Data::Dumper;

my $api = Pitahaya::API->new(
  {
    username => "admin",
    password => "admin",
    url      => "http://localhost:3000",
  }
);

my $site     = $api->get_site("rexify.org");
my $page     = $site->get_page(27);
my @children = $page->children;

opendir(my $dh, $rel_dir);
while(my $entry = readdir($dh)) {
  if ($entry =~ m/\.html\.ep$/) {
    my ($version) = ($entry =~ m/^(.*)\.html\.ep$/);
    
    my ($rel_version_page) = grep { $_->name eq $version } @children;
    if($rel_version_page) {
      $rel_version_page->remove;
    }
    
    $rel_version_page = $page->add_to_children(
      {
        name      => "$version",
        url       => "$version",
        title     => "Release notes for $version",
        type_name => "page",
        content   => get_content_html("$rel_dir/$entry"),
      }
    );
  }
  elsif($entry =~ m/\.html\+md\.ep$/) {
    my ($version) = ($entry =~ m/^(.*)\.html\+md\.ep$/);
    
    my ($rel_version_page) = grep { $_->name eq $version } @children;
    if($rel_version_page) {
      $rel_version_page->remove;
    }
    
    $rel_version_page = $page->add_to_children(
      {
        name      => "$version",
        url       => "$version",
        title     => "Release notes for $version",
        type_name => "page",
        content   => get_content_md("$rel_dir/$entry"),
      }
    );
  }
}
closedir($dh);


sub get_content_html {
  my ($file) = @_;
  print ">> $file\n";

  my @lines = eval { local(@ARGV) = ($file); <>; };
  
  while (my $line = shift @lines) {
    last if($line =~ m/\<h1\>/);
  }
  
  chomp @lines;
  
  print "size: " . scalar(@lines) . " ($file)\n";
  return join("\n", @lines);
}

sub get_content_md {
  my ($file) = @_;
  print ">> $file\n";
  
  my $lines = eval { local(@ARGV, $/) = ($file); <>; };
  
  my @lines = split(/\n/, markdown($lines));
  
  while (my $line = shift @lines) {
    last if($line =~ m/\<h1\>/);
  }
  
  chomp @lines;
  
  print "size: " . scalar(@lines) . " ($file)\n";
  return join("\n", @lines);  
}


