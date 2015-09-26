#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=2 sw=2 tw=0:
# vim: set expandtab:
   
package Pitahaya::API;

use Moo;
use Mojo::UserAgent;
use Mojo::UserAgent::CookieJar;

use Pitahaya::API::Exception::Login;
use Pitahaya::API::Exception::SiteNotFound;

use Pitahaya::API::Site;

my ($ua, $cookies);

has username => (is => 'ro');
has password => (is => 'ro');
has url      => (is => 'ro');

has session => (is => 'ro');
has ua => (
  is => 'rw', 
  lazy => 1,
  default => sub {
    $ua      ||= Mojo::UserAgent->new;
    $cookies ||= Mojo::UserAgent::CookieJar->new;
    $ua->cookie_jar($cookies);

    return $ua;
  },
);


sub get_site {
  my ($self, $site_name) = @_;
  return Pitahaya::API::Site->new({api => $self, name => $site_name});
}

before get_site => sub {
  my ($self) = @_;
  if(!$self->{__login__}) {
    $self->_login();
  }
};

sub _login {
  my ($self) = @_;
  my $tx = $self->ua->post($self->url . "/admin/login", json => {
    username => $self->username,
    password => $self->password,
  });

  if($tx->success) {
    $self->{__login__} = 1;
  }
  else {
    my $ref = $tx->res->json;
    my $message = "Unknown Error";
    if($ref && exists $ref->{error}) {
      $message = $ref->{error};
    }

    Pitahaya::API::Exception::Login->throw({
      message => $message,
    });
  }
}


1;
