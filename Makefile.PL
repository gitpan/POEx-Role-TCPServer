
use strict;
use warnings;



use ExtUtils::MakeMaker 6.11;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'POEx::Role::TCPServer',
                       'DISTNAME' => 'POEx-Role-TCPServer',
                       'AUTHOR' => 'Nicholas Perez <nperez@cpan.org>',
                       'ABSTRACT' => 'Moose Role for turning ordinary objects into POE TCP Servers',
                       'EXE_FILES' => [],
                       'VERSION' => '0.100171',
                       'LICENSE' => 'gpl',
                       'PREREQ_PM' => {
                                        'POEx::Role::SessionInstantiation' => '0.092800',
                                        'MooseX::Declare' => '0.32',
                                        'ExtUtils::MakeMaker' => '6.11',
                                        'Moose' => '0.93',
                                        'POE' => '1.281'
                                      }
                     );


delete $WriteMakefileArgs{LICENSE}
  unless eval { ExtUtils::MakeMaker->VERSION(6.31) };

WriteMakefile(%WriteMakefileArgs);



