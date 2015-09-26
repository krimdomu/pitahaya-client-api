package Pitahaya::API::Exception::Base;

use Moo;
with 'Throwable';

has message => (is => 'ro');

1;
