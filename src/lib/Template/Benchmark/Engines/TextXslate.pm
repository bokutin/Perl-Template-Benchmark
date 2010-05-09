package Template::Benchmark::Engines::TextXslate;

use warnings;
use strict;

use base qw/Template::Benchmark::Engine/;

#  0.1008 changed the API needed for uncached_string.
use Text::Xslate 0.1008;

our $VERSION = '1.00';

our %feature_syntaxes = (
    literal_text              =>
        join( "\n", ( join( ' ', ( 'foo' ) x 12 ) ) x 5 ),
    scalar_variable           =>
        '<:= $scalar_variable :>',
    hash_variable_value       =>
        '<:= $hash_variable.hash_value_key :>',
    array_variable_value      =>
        '<:= $array_variable[ 2 ] :>',
    deep_data_structure_value =>
        '<:= $this.is.a.very.deep.hash.structure :>',
    array_loop_value          =>
        '<: for $array_loop ->($i) { :><:= $i :><: } :>',
    hash_loop_value           =>
        undef,
    records_loop_value        =>
        #  Fun japes to get around no way of escaping the literal ":".
        '<: for $records_loop ->($r) { :><:= $r.name :><:= ":" :> ' .
        '<:= $r.age :><: } :>',
    array_loop_template       =>
        '<: for $array_loop ->($i) { :><:= $i :><: } :>',
    hash_loop_template        =>
        undef,
    records_loop_template     =>
        #  Fun japes to get around no way of escaping the literal ":".
        '<: for $records_loop ->($r) { :><:= $r.name :><:= ":" :> ' .
        '<:= $r.age :><: } :>',
    constant_if_literal       =>
        '<: if 1 { :>true<: } :>',
    variable_if_literal       =>
        '<: if $variable_if { :>true<: } :>',
    constant_if_else_literal  =>
        '<: if 1 { :>true<: } else { :>false<: } :>',
    variable_if_else_literal  =>
        '<: if $variable_if_else { :>true<: } else { :>false<: } :>',
    constant_if_template      =>
        '<: if 1 { :><:= $template_if_true :><: } :>',
    variable_if_template      =>
        '<: if $variable_if { :><:= $template_if_true :><: } :>',
    constant_if_else_template =>
        '<: if 1 { :><:= $template_if_true :><: } else { :>' .
        '<:= $template_if_false :><: } :>',
    variable_if_else_template =>
        '<: if $variable_if_else { :><:= $template_if_true :><: } else { :>' .
        '<:= $template_if_false :><: } :>',
    constant_expression       =>
        '<:= 10 + 12 :>',
    variable_expression       =>
        '<:= $variable_expression_a * $variable_expression_b :>',
    complex_variable_expression =>
        '<:= ( ( $variable_expression_a * $variable_expression_b ) + ' .
        '$variable_expression_a - $variable_expression_b ) / ' .
        '$variable_expression_b :>',
    constant_function         =>
        undef,
    variable_function         =>
        undef,
    );

sub syntax_type { return( 'mini-language' ); }
sub pure_perl { return( 0 ); }

sub benchmark_descriptions
{
    return( {
        TeXs    =>
            "Text::Xslate ($Text::Xslate::VERSION)",
        } );
}

sub benchmark_functions_for_uncached_string
{
    my ( $self ) = @_;

    return( {
        TeXs =>
            sub
            {
                my $t = Text::Xslate->new(
                    cache  => 0,
                    );
                $t->render_string( $_[ 0 ], { %{$_[ 1 ]}, %{$_[ 2 ]} } );
            },
        } );
}

sub benchmark_functions_for_uncached_disk
{
    my ( $self, $template_dir ) = @_;
    my ( @template_dirs );

    @template_dirs = ( $template_dir );

    return( {
        TeXs =>
            sub
            {
                my $t = Text::Xslate->new(
                    path  => \@template_dirs,
                    cache => 0,
                    );
                $t->render( $_[ 0 ], { %{$_[ 1 ]}, %{$_[ 2 ]} } );
            },
        } );
}

sub benchmark_functions_for_disk_cache
{
    my ( $self, $template_dir, $cache_dir ) = @_;
    my ( @template_dirs );

    @template_dirs = ( $template_dir );

    return( {
        TeXs =>
            sub
            {
                my $t = Text::Xslate->new(
                    path      => \@template_dirs,
                    cache_dir => $cache_dir,
                    cache     => 2,
                    );
                $t->render( $_[ 0 ], { %{$_[ 1 ]}, %{$_[ 2 ]} } );
            },
        } );
}

sub benchmark_functions_for_shared_memory_cache
{
    my ( $self, $template_dir, $cache_dir ) = @_;

    return( undef );
}

sub benchmark_functions_for_memory_cache
{
    my ( $self, $template_dir, $cache_dir ) = @_;

    return( undef );
}

sub benchmark_functions_for_instance_reuse
{
    my ( $self, $template_dir, $cache_dir ) = @_;
    my ( @template_dirs, $t );

    @template_dirs = ( $template_dir );

    return( {
        TeXs =>
            sub
            {
                $t = Text::Xslate->new(
                    path      => \@template_dirs,
                    cache_dir => $cache_dir,
                    cache     => 2,
                    ) unless $t;
                $t->render( $_[ 0 ], { %{$_[ 1 ]}, %{$_[ 2 ]} } );
            },
        } );
}

1;

__END__

=pod

=head1 NAME

Template::Benchmark::Engines::TextXslate - Template::Benchmark plugin for Text::Xslate.

=head1 SYNOPSIS

Provides benchmark functions and template feature syntaxes to allow
L<Template::Benchmark> to benchmark the L<Text::Xslate> template
engine.

=head1 AUTHORS

Sam Graham, C<< <libtemplate-benchmark-perl at illusori.co.uk> >>

Patches contributed by: Goro Fuji.

=head1 BUGS

Please report any bugs or feature requests to C<bug-template-benchmark at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Template-Benchmark>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Template::Benchmark::Engines::TextXslate


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Template-Benchmark>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Template-Benchmark>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Template-Benchmark>

=item * Search CPAN

L<http://search.cpan.org/dist/Template-Benchmark/>

=back


=head1 ACKNOWLEDGEMENTS

Thanks to Paul Seamons for creating the the bench_various_templaters.pl
script distributed with L<Template::Alloy>, which was the ultimate
inspiration for this module.

=head1 COPYRIGHT & LICENSE

Copyright 2010 Sam Graham.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut