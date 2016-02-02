#
# (c) Jan Gehring <jan.gehring@gmail.com>
#
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:

package Pitahaya::API::Page;

use Carp;
use Moo;
use Data::Dumper;
use Pitahaya::API::Exception::PageNotFound;

extends 'Pitahaya::API::BaseObject';

has id                => ( is => 'rwp' );
has site              => ( is => 'rwp' );
has rel_date          => ( is => 'rwp' );
has site_id           => ( is => 'rwp' );
has content           => ( is => 'rwp' );
has keywords          => ( is => 'rwp' );
has type_id           => ( is => 'rwp' );
has type_name         => ( is => 'rwp' );
has url               => ( is => 'rwp' );
has creator_id        => ( is => 'rwp' );
has m_date            => ( is => 'rwp' );
has c_date            => ( is => 'rwp' );
has active            => ( is => 'rwp' );
has hidden            => ( is => 'rwp' );
has name              => ( is => 'rwp' );
has data              => ( is => 'rwp' );
has description       => ( is => 'rwp' );
has navigation        => ( is => 'rwp' );
has level             => ( is => 'rwp' );
has lft               => ( is => 'rwp' );
has title             => ( is => 'rwp' );
has lock_date         => ( is => 'rwp' );
has rgt               => ( is => 'rwp' );
has content_type_id   => ( is => 'rwp' );
has content_type_name => ( is => 'rwp' );

sub BUILD {
  my ($self) = @_;

  my $tx =
    $self->api->ua->get(
    $self->api->url . "/admin/" . $self->site->name . "/page/" . $self->id,
    { Accept => "application/json" } );

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

    Pitahaya::API::Exception::PageNotFound->throw(
      {
        message => $message,
      }
    );
  }
}

sub children {
  my ($self) = @_;

  my $tx = $self->api->ua->get(
    $self->api->url
      . "/admin/"
      . $self->site->name
      . "/page/tree/children/"
      . $self->id,
    { Accept => "application/json" }
  );

  if ( $tx->success ) {
    my $ref = $tx->res->json;
    my @ret;
    for my $child ( @{$ref} ) {
      push @ret,
        Pitahaya::API::Page->new(
        { site => $self->site, api => $self->api, id => $child->{id} } );
    }

    return @ret;
  }
}

sub update {
  my ($self, %opt) = @_;
  for my $k (keys %opt) {
    my $set_func = "_set_$k";
    $self->$set_func($opt{$k});
  }

  $opt{__utf8_check__} = '%C3%96';
  
  my $tx = $self->api->ua->put(
    $self->api->url . "/admin/" . $self->site->name . "/page/" . $self->id,
    { Accept => "application/json" },
    json => \%opt
  );

  if ( $tx->success ) {
    return 1;
  }
  
  confess "Error updating page.";
}

sub add_to_children {
  my ( $self, $data ) = @_;

  my $tx = $self->api->ua->post(
    $self->api->url . "/admin/" . $self->site->name . "/page/" . $self->id,
    { Accept => "application/json" },
    json => $data
  );

  if ( $tx->success ) {
    my $ref = $tx->res->json;
    return Pitahaya::API::Page->new(
      site => $self->site,
      api  => $self->api,
      id   => $ref->{id}
    );
  }
}

sub remove {
  my ($self) = @_;

  my $tx =
    $self->api->ua->delete(
    $self->api->url . "/admin/" . $self->site->name . "/page/" . $self->id,
    { Accept => "application/json" } );

  if ( $tx->success ) {
    my $ref = $tx->res->json;
    return 1;
  }

  return 0;
}

sub is_leaf {
  my ($self) = @_;
  if ( $self->lft + 1 == $self->rgt ) {
    return 1;
  }

  return 0;
}

1;
