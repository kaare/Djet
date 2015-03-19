package Djetsite::Engine::Pod;

use 5.010;
use Moose;

use Pod::Simple::XHTML;
use Pod::Simple::Search;

extends 'Djet::Engine::Default';
with qw/Djet::Part::List/;

=head1 NAME

Djetsite::Engine::Pod

=head1 DESCRIPTION

Renders pod as web pages for the Djet.xyz site

=head1 METHODS

=head2 to_html

=cut

before to_html => sub {
	my $self = shift;
	my $model = $self->model;
	my $stash = $model->stash;
	my $search = Pod::Simple::Search->new;

	my $module = $model->rest_path || 'Djet::Manual';
	return unless my $path = $search->find($module);

	my $p = Pod::Simple::XHTML->new;
	$p->$_('') for qw(html_header html_footer);
	$p->output_string(\my $html);
	$p->html_encode_chars('&<>">');
	$p->perldoc_url_prefix("./");
	$p->index(1);
	$p->backlink(1);
	$p->parse_file($path);
	$stash->{title} = $module;
	$stash->{pod} = $html;
};

__PACKAGE__->meta->make_immutable;

# COPYRIGHT

__END__
