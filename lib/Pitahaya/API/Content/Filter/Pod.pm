#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Pitahaya::API::Content::Filter::Pod;

use Moo;
use Mojo::DOM;

sub filter {
  my ($self, $content) = @_;
  my $dom = Mojo::DOM->new($content);

  my $body = $dom->find('body')->first;
  return $body->content;
}

1;
