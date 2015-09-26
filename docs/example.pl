#!/usr/bin/env perl

use lib '../lib';

use Pitahaya::API;
use Pitahaya::API::Content::Filter::Markdown;

use Data::Dumper;

my $api = Pitahaya::API->new({
  username => "admin",
  password => "admin",
  url      => "http://localhost:3000",
});

my $filter = Pitahaya::API::Content::Filter::Markdown->new;

my $site = $api->get_site("rexify.org");
my $page = $site->get_page(29);
my @children = $page->children;

my ($api_version_page) = grep { $_->name eq "1.3" } @children;

if(! $api_version_page) {
  $page->add_to_children({
    name => "1.3",
    type_name => "api_version",
  });
}


