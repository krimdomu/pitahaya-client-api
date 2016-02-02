#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::API::Site;

use Moo;

use Pitahaya::API::Exception::SiteNotFound;
use Pitahaya::API::Page;

extends 'Pitahaya::API::BaseObject';

has name          => ( is => 'rwp' );
has skin          => ( is => 'rwp' );
has virtual_hosts => ( is => 'rwp' );
has c_date        => ( is => 'rwp' );
has id            => ( is => 'rwp' );
has data          => ( is => 'rwp' );
has m_date        => ( is => 'rwp' );
has root_page_id  => ( is => 'rwp' );

sub BUILD {
  my ($self) = @_;

  my $tx =
    $self->api->ua->get( $self->api->url . "/admin/site/" . $self->name );
  if ( $tx->success ) {
    my $ref = $tx->res->json;
    for my $key ( keys %{$ref} ) {
      my $func = "_set_$key";
      $self->$func( $ref->{$key} );
    }
  }
  else {
    my $ref     = $tx->res->json;
    my $message = "Unknown Error";
    if ( $ref && exists $ref->{error} ) {
      $message = $ref->{error};
    }

    Pitahaya::API::Exception::SiteNotFound->throw(
      {
        message => $message,
      }
    );
  }
}

sub get_page {
  my ( $self, $id ) = @_;
  return Pitahaya::API::Page->new( site => $self, api => $self->api, id => $id );
}


1;
