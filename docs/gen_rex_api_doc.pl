#!/usr/bin/env perl

use lib '../lib';

my $rex_dir = $ARGV[0];
my $path_prefix = $ARGV[1];
my $version = "1.4";

$path_prefix ||= "";

if ( !$rex_dir ) {
  print "Usage: $0 <rex-dir>\n";
  exit 1;
}

use Pod::HtmlEasy;
use Pitahaya::API;
use Pitahaya::API::Content::Filter::Pod;

use Data::Dumper;

my $pod2html = Pod::HtmlEasy->new();

my $api = Pitahaya::API->new(
  {
    username => "admin",
    password => "admin",
    url      => "http://localhost:3000",
  }
);

my $filter = Pitahaya::API::Content::Filter::Pod->new;

my $site     = $api->get_site("rexify.org");
my $page     = $site->get_page(29);
my @children = $page->children;

my ($api_version_page) = grep { $_->name eq $version } @children;
if($api_version_page) {
  $api_version_page->remove;
}

$api_version_page = $page->add_to_children(
  {
    name      => "$version",
    title     => "API Documentation for Version $version",
    type_name => "api_version",
  }
);

my @dirs = ($rex_dir);

for my $dir (@dirs) {
  opendir( my $dh, $dir ) or die($!);
  while ( my $entry = readdir($dh) ) {
    next if ( $entry =~ m/^\./ );
    if ( -d "$dir/$entry" ) {
      push @dirs, "$dir/$entry";
      next;
    }

    if ( $entry =~ m/\.pm$/ ) {
      generate_doc("$dir/$entry");
    }
  }
  closedir($dh);
}

sub generate_doc {
  my ($file) = @_;

  my $mod_path = $file;
  $mod_path =~ s/\Q$rex_dir\E\///;

  my $html    = qx{pod2html $file 2>/dev/null};
  my $content = $filter->filter($html);

  my @lines = grep { $_ !~ m/^\s*$/ } split(/\n/, $content);

  if(scalar @lines == 0) { 
    return;
  }

  if($path_prefix) {
    $mod_path = "$path_prefix/$mod_path";
  }

  # Rex.pm
  # Rex/Cron.pm
  # Rex/Commands/Run.pm

  my @path_parts = split( /\//, $mod_path );

  my $current_page = $api_version_page;    #->children();

  for my $path_part (@path_parts) {
    my ($path_part_page) =
      grep { $_->name eq $path_part } $current_page->children();
    if ( !$path_part_page ) {
      my $page_type = "api_folder";

      if ( $path_part =~ m/\.pm$/ ) {
        $page_type = "api_item";
      }

      print "> creating page: $path_part ($mod_path)\n";
      $path_part_page = $current_page->add_to_children(
        {
          name      => $path_part,
          title     => $path_part,
          type_name => $page_type,
          data      => {
            search_info => "API version $version",
          },
          ( $page_type eq "api_item" ? ( content => $content ) : () )
        }
      );
    }

    $current_page = $path_part_page;
  }

}

