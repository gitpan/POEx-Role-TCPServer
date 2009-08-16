
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  DISTNAME  => 'POEx-Role-TCPServer',
  NAME      => 'POEx::Role::TCPServer',
  AUTHOR    => 'Nicholas\ Perez\ \<nperez\@cpan\.org\>',
  ABSTRACT  => 'Moose\ Role\ for\ turning\ ordinary\ objects\ into\ POE\ TCP\ Servers',
  VERSION   => '0.092280',
  EXE_FILES => [ qw() ],
  (eval { ExtUtils::MakeMaker->VERSION(6.31) } ? (LICENSE => 'gpl') : ()),
  PREREQ_PM    => {
    "POEx::Role::SessionInstantiation" => '0.092280',
  },
);
