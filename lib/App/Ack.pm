package App::Ack;

use warnings;
use strict;

=head1 NAME

App::Ack

=head1 DESCRIPTION

A container for functions for the ack program.

=head1 VERSION

Version 2.999_06

=cut

our $VERSION;
our $COPYRIGHT;
BEGIN {
    $VERSION = '2.999_06';
    $COPYRIGHT = 'Copyright 2005-2019 Andy Lester.';
}
our $STANDALONE = 0;
our $ORIGINAL_PROGRAM_NAME;

our $fh;

BEGIN {
    $fh = *STDOUT;
}


our %types;
our %type_wanted;
our %mappings;
our %ignore_dirs;

our $is_filter_mode;
our $output_to_pipe;

our $is_windows;

our $debug_nopens = 0;

# Line ending, changes to "\0" if --print0.
our $ors = "\n";

BEGIN {
    # These have to be checked before any filehandle diddling.
    $output_to_pipe  = not -t *STDOUT;
    $is_filter_mode = -p STDIN;

    $is_windows      = ($^O eq 'MSWin32');
}

=head1 SYNOPSIS

If you want to know about the F<ack> program, see the F<ack> file itself.

No user-serviceable parts inside.  F<ack> is all that should use this.

=head1 FUNCTIONS

=head2 warn( @_ )

Put out an ack-specific warning.

=cut

sub warn {
    return CORE::warn( _my_program(), ': ', @_, "\n" );
}

=head2 die( @msgs )

Die in an ack-specific way.

=cut

sub die {
    return CORE::die( _my_program(), ': ', @_, "\n" );
}

sub _my_program {
    require File::Basename;
    return File::Basename::basename( $0 );
}


sub thpppt {
    my $y = q{_   /|,\\'!.x',=(www)=,   U   };
    $y =~ tr/,x!w/\nOo_/;

    App::Ack::print( "$y ack $_[0]!\n" );
    exit 0;
}

sub ackbar {
    my $x;
    $x = <<'_BAR';
 6?!I'7!I"?%+!
 3~!I#7#I"7#I!?!+!="+"="+!:!
 2?#I!7!I!?#I!7!I"+"=%+"=#
 1?"+!?*+!=#~"=!+#?"="+!
 0?"+!?"I"?&+!="~!=!~"=!+%="+"
 /I!+!?)+!?!+!=$~!=!~!="+!="+"?!="?!
 .?%I"?%+%='?!=#~$="
 ,,!?%I"?(+$=$~!=#:"~$:!~!
 ,I!?!I!?"I"?!+#?"+!?!+#="~$:!~!:!~!:!,!:!,":#~!
 +I!?&+!="+!?#+$=!~":!~!:!~!:!,!:#,!:!,%:"
 *+!I!?!+$=!+!=!+!?$+#=!~":!~":#,$:",#:!,!:!
 *I!?"+!?!+!=$+!?#+#=#~":$,!:",!:!,&:"
 )I!?$=!~!=#+"?!+!=!+!=!~!="~!:!~":!,'.!,%:!~!
 (=!?"+!?!=!~$?"+!?!+!=#~"=",!="~$,$.",#.!:!=!
 (I"+"="~"=!+&=!~"=!~!,!~!+!=!?!+!?!=!I!?!+"=!.",!.!,":!
 %I$?!+!?!=%+!~!+#~!=!~#:#=!~!+!~!=#:!,%.!,!.!:"
 $I!?!=!?!I!+!?"+!=!~!=!~!?!I!?!=!+!=!~#:",!~"=!~!:"~!=!:",&:" '-/
 $?!+!I!?"+"=!+"~!,!:"+#~#:#,"=!~"=!,!~!,!.",!:".!:! */! !I!t!'!s! !a! !g!r!e!p!!! !/!
 $+"=!+!?!+"~!=!:!~!:"I!+!,!~!=!:!~!,!:!,$:!~".&:"~!,# (-/
 %~!=!~!=!:!.!+"~!:!,!.!,!~!=!:$.!,":!,!.!:!~!,!:!=!.#="~!,!:" ./!
 %=!~!?!+"?"+!=!~",!.!:!?!~!.!:!,!:!,#.!,!:","~!:!=!~!=!:",!~! ./!
 %+"~":!~!=#~!:!~!,!.!~!:",!~!=!~!.!:!,!.",!:!,":!=":!.!,!:!7! -/!
 %~",!:".#:!=!:!,!:"+!:!~!:!.!,!~!,!.#,!.!,$:"~!,":"~!=! */!
 &=!~!=#+!=!~",!.!:",#:#,!.",+:!,!.",!=!+!?!
 &~!=!~!=!~!:"~#:",!.!,#~!:!.!+!,!.",$.",$.#,!+!I!?!
 &~!="~!:!~":!~",!~!=!~":!,!:!~!,!:!,&.$,#."+!?!I!?!I!
 &~!=!~!=!+!,!:!~!:!=!,!:!~&:$,!.!,".!,".!,#."~!+!?$I!
 &~!=!~!="~!=!:!~":!,!~%:#,!:",!.!,#.",#I!7"I!?!+!?"I"
 &+!I!7!:#~"=!~!:!,!:"~$.!=!.!,!~!,$.#,!~!7!I#?!+!?"I"7!
 %7#?!+!~!:!=!~!=!~":!,!:"~":#.!,)7#I"?"I!7&
 %7#I!=":!=!~!:"~$:"~!:#,!:!,!:!~!:#,!7#I!?#7)
 $7$+!,!~!=#~!:!~!:!~$:#,!.!~!:!=!,":!7#I"?#7+=!?!
 $7#I!~!,!~#=!~!:"~!:!,!:!,#:!=!~",":!7$I!?#I!7*+!=!+"
 "I!7$I!,":!,!.!=":$,!:!,$:$7$I!+!?"I!7+?"I!7!I!7!,!
 !,!7%I!:",!."~":!,&.!,!:!~!I!7$I!+!?"I!7,?!I!7',!
 !7(,!.#~":!,%.!,!7%I!7!?#I"7,+!?!7*
7+:!,!~#,"=!7'I!?#I"7/+!7+
77I!+!7!?!7!I"71+!7,
_BAR

    return _pic_decode($x);
}

sub cathy {
    my $x = <<'CATHY';
 0+!--+!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! $A"C!K!!! $|!
 0+!--+!
 6\! 1:!,!.! !
 7\! /.!M!~!Z!M!~!
 8\! /~!D! "M! !
 4.! $\! /M!~!.!8! +.!M# 4
 0,!.! (\! .~!M!N! ,+!I!.!M!.! 3
 /?!O!.!M!:! '\! .O!.! +~!Z!=!N!.! 4
 ..! !D!Z!.!Z!.! '\! 9=!M".! 6
 /.! !.!~!M".! '\! 8~! 9
 4M!.! /.!7!N!M!.! F
 4.! &:!M! !N"M# !M"N!M! #D!M&=! =
 :M!7!M#:! !~!M!7!,!$!M!:! #.! !O!N!.!M!:!M# ;
 8Z!M"~!N!$!D!.!N!?! !I!N!.! (?!M! !M!,!D!M".! 9
 (?!Z!M!N!:! )=!M!O!8!.!M!+!M! !M!,! !O!M! +,!M!.!M!~!Z!N!M!:! &:!~! 0
 &8!7!.!~!M"D!M!,! &M!?!=!8! !M!,!O! !M!+! !+!O!.!M! $M#~! !.!8!M!Z!.!M! !O!M"Z! %:!~!M!Z!M!Z!.! +
 &:!M!7!,! *M!.!Z!M! !8"M!.!M!~! !.!M!.!=! #~!8!.!M! !7!M! "N!Z#I! !D!M!,!M!.! $."M!,! !M!.! *
 2$!O! "N! !.!M!I! !7" "M! "+!O! !~!M! !d!O!.!7!I!M!.! !.!O!=!M!.! !M",!M!.! %.!$!O!D! +
 1~!O! "M!+! !8!$! "M! "?!O! %Z!8!D!M!?!8!I!O!7!M! #M!.!M! "M",!M! 4
 07!~! ".!8! !.!M! "I!+! !.!M! &Z!D!.!7!=!M! !:!.!M! #:!8"+! !.!+!8! !8! 3
 /~!M! #N! !~!M!$! !.!M! !.!M" &~!M! "~!M!O! "D! $M! !8! "M!,!M!+!D!.! 1
 #.! #?!M!N!.! #~!O! $M!.!7!$! "?" !?!~!M! '7!8!?!M!.!+!M"O! $?"$!D! !.!O! !$!7!I!.! 0
 $,!M!:!O!?! ".! !?!=! $=!:!O! !M! "M! !M! !+!$! (.! +.!M! !M!.! !8! !+"Z!~! $:!M!$! !.! '
 #.!8!.!I!$! $7!I! %M" !=!M! !~!M!D! "7!I! .I!O! %?!=!,!D! !,!M! !D!~!8!~! %D!M! (
 #.!M"?! $=!O! %=!N! "8!.! !Z!M! #M!~! (M!:! #.!M" &O! !M!.! !?!,! !8!.!N!~! $8!N!M!,!.! %
 *$!O! &M!,! "O! !.!M!.! #M! (~!M( &O!.! !7! "M! !.!M!.!M!,! #.!M! !M! &
 )=!8!.! $.!M!O!.! "$!.!I!N! !I!M# (7!M(I! %D"Z!M! "=!I! "M! !M!:! #~!D! '
 )D! &8!N!:! ".!O! !M!="M! "M! (7!M) %." !M!D!."M!.! !$!=! !M!,! +
 (M! &+!.!M! #Z!7!O!M!.!~!8! +,!M#D!?!M#D! #.!Z!M#,!Z!?! !~!N! "N!.! !M! +
 'D!:! %$!D! !?! #M!Z! !8!.! !M"?!7!?!7! '+!I!D! !?!O!:!M!:! ":!M!:! !M!7".!M! "8!+! !:!D! !.!M! *
 %.!O!:! $.!O!+! !D!.! #M! "M!.!+!N!I!Z! "7!M!N!M!N!?!I!7!Z!=!M'D"~! #M!.!8!$! !:! !.!M! "N!?! !,!O! )
 !.!?!M!:!M!I! %8!,! "M!.! #M! "N! !M!.! !M!.! !+!~! !.!M!.! ':!M! $M! $M!Z!$! !M!.! "D! "M! "?!M! (
 !7!8! !+!I! ".! "$!=! ":!$! "+! !M!.! !O! !M!I!M".! !=!~! ",!O! '=!M! $$!,! #N!:! ":!8!.! !D!~! !,!M!.! !:!M!.! &
 !:!,!.! &Z" #D! !.!8!."M!.! !8!?!Z!M!.!M! #Z!~! !?!M!Z!.! %~!O!.!8!$!N!8!O!I!:!~! !+! #M!.! !.!M!.! !+!M! ".!~!M!+! $
 !.! 'D!I! #?!M!.!M!,! !.!Z! !.!8! #M&O!I!?! (~!I!M"." !M!Z!.! !M!N!.! "+!$!.! "M!.! !M!?!.! "8!M! $
 (O!8! $M! !M!.! ".!:! !+!=! #M! #.!M! !+" *$!M":!.! !M!~! "M!7! #M! #7!Z! "M"$!M!.! !.! #
 '$!Z! #.!7!+!M! $.!,! !+!:! #N! #.!M!.!+!M! +D!M! #=!N! ":!O! #=!M! #Z!D! $M!I! %
 $,! ".! $.!M" %$!.! !?!~! "+!7!." !.!M!,! !M! *,!N!M!.$M!?! "D!,! #M!.! #N! +
 ,M!Z! &M! "I!,! "M! %I!M! !?!=!.! (Z!8!M! $:!M!.! !,!M! $D! #.!M!.! )
 +8!O! &.!8! "I!,! !~!M! &N!M! !M!D! '?!N!O!." $?!7! "?!~! #M!.! #I!D!.! (
 3M!,! "N!.! !D" &.!+!M!.! !M":!.":!M!7!M!D! 'M!.! "M!.! "M!,! $I! )
 3I! #M! "M!,! !:! &.!M" ".!,! !.!$!M!I! #.! !:! !.!M!?! "N!+! ".! /
 1M!,! #.!M!8!M!=!.! +~!N"O!Z"~! *+!M!.! "M! 2
 0.!M! &M!.! 8:! %.!M!Z! "M!=! *O!,! %
 0?!$! &N! )." .,! %."M! ":!M!.! 0
 0N!:! %?!O! #.! ..! &,! &.!D!,! "N!I! 0
CATHY
    return _pic_decode($x);
}

sub _pic_decode {
    my($compressed) = @_;
    $compressed =~ s/(.)(.)/$1x(ord($2)-32)/eg;
    App::Ack::print( $compressed );
    exit 0;
}

=head2 show_help()

Dumps the help page to the user.

=cut

sub show_help {
    my $help_arg = shift || 0;

    return show_help_types() if $help_arg =~ /^types?/;

    my $manual_options;
    if ( $App::Ack::STANDALONE ) {
        $manual_options = <<'END';
  --man                         Print the manual, FAQ and cookbook
END
    }
    else {
        $manual_options = <<'END';
  --man                         Print the manual
  --faq                         Print the frequently asked questions
  --cookbook                    Print a list of tips and tricks for using ack
END
    }
    chomp $manual_options;

    App::Ack::print( <<"END_OF_HELP" );
Usage: ack [OPTION]... PATTERN [FILES OR DIRECTORIES]

Search for PATTERN in each source file in the tree from the current
directory on down.  If any files or directories are specified, then
only those files and directories are checked.  ack may also search
STDIN, but only if no file or directory arguments are specified,
or if one of them is "-".

Default switches may be specified in an .ackrc file. If you want no dependency
on the environment, turn it off with --noenv.

Example: ack -i select

Searching:
  -i, --ignore-case             Ignore case distinctions in PATTERN
  -S, --[no]smart-case          Ignore case distinctions in PATTERN,
                                only if PATTERN contains no upper case.
                                Ignored if -i or -I are specified.
  -I                            Turns on case-sensitivity in PATTERN.
                                Negates -i and --smart-case.
  -v, --invert-match            Invert match: select non-matching lines
  -w, --word-regexp             Force PATTERN to match only whole words
  -Q, --literal                 Quote all metacharacters; PATTERN is literal
  --match PATTERN               Specify PATTERN explicitly. Typically omitted.

Search output:
  -l, --files-with-matches      Only print filenames containing matches
  -L, --files-without-matches   Only print filenames with no matches
  --output=expr                 Output the evaluation of expr for each line
                                (turns off text highlighting)
  -o                            Show only the part of a line matching PATTERN
                                Same as --output='\$&'
  --passthru                    Print all lines, whether matching or not
  -m, --max-count=NUM           Stop searching in each file after NUM matches
  -1                            Stop searching after one match of any kind
  -H, --with-filename           Print the filename for each match (default:
                                on unless explicitly searching a single file)
  -h, --no-filename             Suppress the prefixing filename on output
  -c, --count                   Show number of lines matching per file
  --[no]column                  Show the column number of the first match

  -A NUM, --after-context=NUM   Print NUM lines of trailing context after
                                matching lines.
  -B NUM, --before-context=NUM  Print NUM lines of leading context before
                                matching lines.
  -C [NUM], --context[=NUM]     Print NUM lines (default 2) of output context.

  --print0                      Print null byte as separator between filenames,
                                only works with -f, -g, -l, -L or -c.

  -s                            Suppress error messages about nonexistent or
                                unreadable files.


File presentation:
  --pager=COMMAND               Pipes all ack output through COMMAND.  For
                                example, --pager="less -R".  Ignored if output
                                is redirected.
  --nopager                     Do not send output through a pager.  Cancels
                                any setting in ~/.ackrc, ACK_PAGER or
                                ACK_PAGER_COLOR.
  --[no]heading                 Print a filename heading above each file's
                                results.  (default: on when used interactively)
  --[no]break                   Print a break between results from different
                                files.  (default: on when used interactively)
  --group                       Same as --heading --break
  --nogroup                     Same as --noheading --nobreak
  -p, --proximate=LINES         Separate match output with blank lines unless
                                they are within LINES lines from each other.
  -P, --proximate=0             Negates --proximate.
  --[no]underline               Print a line of carets under the matched text.
  --[no]color, --[no]colour     Highlight the matching text (default: on unless
                                output is redirected, or on Windows)
  --color-filename=COLOR
  --color-match=COLOR
  --color-colno=COLOR
  --color-lineno=COLOR          Set the color for filenames, matches, line and
                                column numbers.
  --help-colors                 Show a list of possible color combinations.
  --flush                       Flush output immediately, even when ack is used
                                non-interactively (when output goes to a pipe or
                                file).


File finding:
  -f                            Only print the files selected, without
                                searching.  The PATTERN must not be specified.
  -g                            Same as -f, but only select files matching
                                PATTERN.
  --sort-files                  Sort the found files lexically.
  --show-types                  Show which types each file has.
  --files-from=FILE             Read the list of files to search from FILE.
  -x                            Read the list of files to search from STDIN.

File inclusion/exclusion:
  --[no]ignore-dir=name         Add/remove directory from list of ignored dirs
  --[no]ignore-directory=name   Synonym for ignore-dir
  --ignore-file=FILTER:ARGS     Add filter for ignoring files.
  -r, -R, --recurse             Recurse into subdirectories (default: on)
  -n, --no-recurse              No descending into subdirectories
  --[no]follow                  Follow symlinks.  Default is off.

File type inclusion/exclusion:
  --type=X                      Include only X files, where X is a recognized
                                filetype, e.g. --php, --ruby
  --type=noX                    Exclude X files, e.g. --nophp, --no-ruby.
  -k, --known-types             Include only files of types that ack recognizes.
  --help-types                  Display all known types, and how they're defined.

File type specification:
  --type-set=TYPE:FILTER:ARGS   Files with the given ARGS applied to the given
                                FILTER are recognized as being of type TYPE.
                                This replaces an existing definition for TYPE.
  --type-add=TYPE:FILTER:ARGS   Files with the given ARGS applied to the given
                                FILTER are recognized as being type TYPE.
  --type-del=TYPE               Removes all filters associated with TYPE.

Miscellaneous:
  --version                     Display version & copyright
  --[no]env                     Ignore environment variables and global ackrc
                                files.  --env is legal but redundant.
  --ackrc=filename              Specify an ackrc file to use
  --ignore-ack-defaults         Ignore default definitions included with ack.
  --create-ackrc                Outputs a default ackrc for your customization
                                to standard output.
  --dump                        Dump information on which options are loaded
                                and where they're defined.
  --[no]filter                  Force ack to treat standard input as a pipe
                                (--filter) or tty (--nofilter)
  --help, -?                    This help
$manual_options
  --help-types                  Display all known types, and how they're defined.
  --help-colors                 Show a list of possible color combinations.
  --thpppt                      Bill the Cat
  --bar                         The warning admiral
  --cathy                       Chocolate! Chocolate! Chocolate!

Filter specifications:
    If FILTER is "ext", ARGS is a list of extensions checked against the
        file's extension.
    If FILTER is "is", ARGS must match the file's name exactly.
    If FILTER is "match", ARGS is matched as a case-insensitive regex
        against the filename.
    If FILTER is "firstlinematch", ARGS is matched as a regex the first
        line of the file's contents.

Exit status is 0 if match, 1 if no match.

ack's home page is at https://beyondgrep.com/

The full ack manual is available by running "ack --man".

This is version $VERSION of ack.  Run "ack --version" for full version info.
END_OF_HELP

    return;
 }


=head2 show_help_types()

Display the filetypes help subpage.

=cut

sub show_help_types {
    App::Ack::print( <<'END_OF_HELP' );
Usage: ack [OPTION]... PATTERN [FILES OR DIRECTORIES]

The following is the list of filetypes supported by ack.  You can
specify a file type with the --type=TYPE format, or the --TYPE
format.  For example, both --type=perl and --perl work.

Note that some extensions may appear in multiple types.  For example,
.pod files are both Perl and Parrot.

END_OF_HELP

    my @types = keys %App::Ack::mappings;
    my $maxlen = 0;
    for ( @types ) {
        $maxlen = length if $maxlen < length;
    }
    for my $type ( sort @types ) {
        next if $type =~ /^-/; # Stuff to not show
        my $ext_list = $mappings{$type};

        if ( ref $ext_list ) {
            $ext_list = join( '; ', map { $_->to_string } @{$ext_list} );
        }
        App::Ack::print( sprintf( "    --[no]%-*.*s %s\n", $maxlen, $maxlen, $type, $ext_list ) );
    }

    return;
}


=head2 show_help_colors()

Display the colors help subpage.

=cut

sub show_help_colors {
    App::Ack::print( <<'END_OF_HELP' );
ack allows customization of the colors it uses when presenting matches
onscreen.  See the "ACK COLORS" section of the ack manual (ack --man).

Here is a chart of how various color combinations appear: Each of the eight
foreground colors, on each of the eight background colors or no background
color, with and without the bold modifier.

Run ack --help-rgb-colors for a chart of the RGB colors.

END_OF_HELP

    _show_color_grid();

    return;
}


=head2 show_help_rgb()

Display the RGB help subpage.

=cut

sub show_help_rgb {
    App::Ack::print( <<'END_OF_HELP' );
ack allows customization of the colors it uses when presenting matches
onscreen.  See the "ACK COLORS" section of the ack manual (ack --man).

Here is a grid of the 216 possible RGB colors.  For the standard color
grid, run ack --help-colors.
END_OF_HELP

    _show_rgb_grid();

    return;
}


sub _show_color_grid {
    my $cell_width = 7;

    my @fg_colors = qw( black red green yellow blue magenta cyan white );
    my @bg_colors = map { "on_$_" } @fg_colors;

    App::Ack::say(
        _color_cell( '' ),
        map { _color_cell( $_ ) } @fg_colors
    );

    App::Ack::say(
        _color_cell( '' ),
        map { _color_cell( '-' x $cell_width ) } @fg_colors
    );

    for my $bg ( '', @bg_colors ) {
        App::Ack::say(
            _color_cell( '' ),
            ( map { _color_cell( $_, "$_ $bg" ) } @fg_colors ),
            $bg
        );

        App::Ack::say(
            _color_cell( 'bold' ),
            ( map { _color_cell( $_, "bold $_ $bg" ) } @fg_colors ),
            $bg
        );
        App::Ack::say();
    }

    return;
}


sub _color_cell {
    my $text  = shift;
    my $color = shift;

    my $cell_width = 7;
    $text = sprintf( '%-*s', $cell_width, $text );

    return ($color ? Term::ANSIColor::colored( $text, $color ) : $text) . ' ';
}


sub _show_rgb_grid {
    for my $r ( 0 .. 5 ) {
        for my $g ( 0 .. 5 ) {
            for my $b ( 0 ..5 ) {
                my $rgb = "$r$g$b";
                my $code = "rgb$r$g$b";

                App::Ack::print(
                    Term::ANSIColor::colored( $code, $code ),
                    Term::ANSIColor::colored( $code, "reverse $code" ),
                    ' '
                );
            }
            App::Ack::say( '' );
        }
    }
}


sub show_docs {
    my $section = shift;

    my $input;
    if ( $App::Ack::STANDALONE ) {
        # Standalone doesn't have the modules split out, so dump the entire file.
        $input = $App::Ack::ORIGINAL_PROGRAM_NAME;
    }
    else {
        my $module = "App::Ack::Docs::$section";
        eval "require $module" or App::Ack::die( "Can't load $module" );
        $input = $INC{ "App/Ack/Docs/$section.pm" };
    }

    require Pod::Usage;
    Pod::Usage::pod2usage({
        -input     => $input,
        -verbose   => 2,
        -exitval   => 0,
        -noperldoc => 1, # Use Pod::Text.
    });

    return;
}


=head2 get_version_statement

Returns the version information for ack.

=cut

sub get_version_statement {
    require Config;

    my $copyright = $App::Ack::COPYRIGHT;
    my $this_perl = $Config::Config{perlpath};
    if ($^O ne 'VMS') {
        my $ext = $Config::Config{_exe};
        $this_perl .= $ext unless $this_perl =~ m/$ext$/i;
    }
    my $ver = sprintf( '%vd', $^V );

    my $build_type = $App::Ack::STANDALONE ? 'standalone version' : 'standard build';

    return <<"END_OF_VERSION";
ack ${VERSION} ($build_type)
Running under Perl $ver at $this_perl

$copyright

This program is free software.  You may modify or distribute it
under the terms of the Artistic License v2.0.
END_OF_VERSION
}


sub print            { print {$fh} @_; return; }
sub say              { print {$fh} @_, $ors; return; }
sub print_blank_line { print {$fh} "\n"; return; }

sub set_up_pager {
    my $command = shift;

    return if App::Ack::output_to_pipe();

    my $pager;
    if ( not open( $pager, '|-', $command ) ) {
        App::Ack::die( qq{Unable to pipe to pager "$command": $!} );
    }
    $fh = $pager;

    return;
}

=head2 output_to_pipe()

Returns true if ack's input is coming from a pipe.

=cut

sub output_to_pipe {
    return $output_to_pipe;
}

=head2 exit_from_ack( $nmatches )

Exit from the application with the correct exit code.

Returns with 0 if a match was found, otherwise with 1. The number of matches is
handed in as the only argument.

=cut

sub exit_from_ack {
    my $nmatches = shift;

    my $rc = $nmatches ? 0 : 1;
    exit $rc;
}

=head2 show_types( $file )

Shows the filetypes associated with a given file.

=cut

sub show_types {
    my $file = shift;

    my @types = filetypes( $file );
    my $arrow = @types ? ' => ' : ' =>';
    App::Ack::say( $file->name, $arrow, join( ',', @types ) );

    return;
}


sub filetypes {
    my ( $file ) = @_;

    my @matches;

    foreach my $k (keys %App::Ack::mappings) {
        my $filters = $App::Ack::mappings{$k};

        foreach my $filter (@{$filters}) {
            # Clone the file.
            my $clone = $file->clone;
            if ( $filter->filter($clone) ) {
                push @matches, $k;
                last;
            }
        }
    }

    # http://search.cpan.org/dist/Perl-Critic/lib/Perl/Critic/Policy/Subroutines/ProhibitReturnSort.pm
    @matches = sort @matches;
    return @matches;
}


1; # End of App::Ack
