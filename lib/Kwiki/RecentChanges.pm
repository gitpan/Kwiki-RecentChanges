package Kwiki::RecentChanges;
use strict;
use warnings;
use Kwiki::Plugin '-Base';
use Kwiki::Installer '-base';
our $VERSION = '0.10';

const class_id => 'recent_changes';
const class_title => 'Recent Changes';
const css_file => 'recent_changes.css';
const screen_template => 'recent_changes_screen.html';

sub register {
    my $registry = shift;
    $registry->add(action => 'recent_changes');
    $registry->add(toolbar => 'recent_changes_button', 
                   template => 'recent_changes_button.html',
                  );
    $registry->add(preference => 'recent_changes_depth', 
                   object => $self->recent_changes_depth,
                  );
}

sub recent_changes_depth {
    my $p = $self->new_preference('recent_changes_depth');
    $p->query('What time interval should "Recent Changes" display?');
    $p->type('pulldown');
    my $choices = [
        1 => 'Last 24 hours',
        2 => 'Last 2 Days',
        3 => 'Last 3 Days',
        7 => 'Last Week',
        14 => 'Last 2 Weeks',
        30 => 'Last Month',
        60 => 'Last 2 Months',
        90 => 'Last 3 Months',
    ];
    $p->choices($choices);
    $p->default(7);
    return $p;
}

sub recent_changes {
    my $depth_object = $self->preferences->recent_changes_depth;
    my $depth = $depth_object->value;
    my $label = +{@{$depth_object->choices}}->{$depth};
    my $pages;
    @$pages = sort { 
        $b->modified_time <=> $a->modified_time 
    } $self->pages->all_since($depth * 1440);
    $self->render_screen( 
        pages => $pages,
        screen_title => "Changes in the $label:",
    );
}

1;

__DATA__

=head1 NAME 

Kwiki::RecentChanges - Kwiki Recent Changes Plugin

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 AUTHOR

Brian Ingerson <ingy@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
__template/tt2/recent_changes_button.html__
<!-- BEGIN recent_changes_button.html -->
<a href="[% script_name %]?action=recent_changes" accesskey="c" title="Recent Changes">
[% INCLUDE recent_changes_button_icon.html %]
</a>
<!-- END recent_changes_button.html -->
__template/tt2/recent_changes_button_icon.html__
<!-- BEGIN recent_changes_button_icon.html -->
Changes
<!-- END recent_changes_button_icon.html -->
__template/tt2/recent_changes_screen.html__
<!-- BEGIN recent_changes_screen.html -->
[% INCLUDE kwiki_layout_begin.html %]
<table class="recent_changes">
[% FOR page = pages %]
<tr>
<td class="page_id">[% page.kwiki_link %]</td>
<td class="edit_by">[% page.edit_by_link %]</td>
<td class="edit_time">[% page.edit_time %]</td>
</tr>
[% END %]
</table>
[% INCLUDE kwiki_layout_end.html %]
<!-- END recent_changes_screen.html -->
__css/recent_changes.css__
table.recent_changes {
    width: 100%;
}

table.recent_changes td {
    white-space: nowrap;
    padding: .2em 1em .2em 1em;
}

table.recent_changes td.page_id   { 
    text-align: left;
}
table.recent_changes td.edit_by   { 
    text-align: center;
}
table.recent_changes td.edit_time { 
    text-align: right;
}
