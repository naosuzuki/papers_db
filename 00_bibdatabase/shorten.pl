#!/usr/bin/perl -- # -*-Perl-*-

######################################################################
#
# shorten.pl
#
# stole this code from nat2jour.pl to simply shorten author lists in .bbl
# files  --- K Barbary 3/30/08
#
######################################################################

$MaxAuths = 8;
$inline = 0;
$refenv = 0; $bibenv = "thebibliography";
$etal = "{et~al.}";

$usage = <<EOT;

Usage: $0 [options] INPUT [OUTPUT]

$Id: nat2jour.pl,v 1.6 2000/04/21 17:48:02 jbaker Exp $

Arguments:
  INPUT        If this is "foo", input files are "foo.tex" and "foo.bbl"
  OUTPUT       (optional) Same for output files; default appends "-aas".

Options:
  -inline      Inline the bibliography into a single LaTeX file
  -maxauth     Set maximum number of authors before truncation 
                 (8=default, 0=no limit)
  -references  Instead of a "thebibliography" environment, create a
                 "references" environment.  Also leaves out \markcite
                 commands.
  -help        Print this message and exit successfully

EOT

# Options
while (@ARGV && $ARGV[0] =~ /^-/) {
  $_ = shift(@ARGV);

  if (/^-i(nline)?$/) { $inline = 1; next; }            # -inline

  if (/^-m(axauth)?=?(\d+)?$/) {                        # -maxauth
    $MaxAuths = $2 || shift(@ARGV);
    die("$0: option -maxauth requires integer argument\n") 
      if ($MaxAuths !~ /^\d+$/);
    warn("** Lettering may be incorrect for -maxauth=$MaxAuths.\n")
      if ($MaxAuths > 0 && $MaxAuths < 3);
    next;
  }

  if (/^-r(eferences)?$/) {                             # -references
    $refenv = 1; 
    $bibenv = "references";
    next; 
  }

  if (/^-h(elp)$/) { print $usage; exit; }              # -help

  die $usage;
}

# Arguments
die $usage unless ($#ARGV == 0 || $#ARGV == 1);
$OldBibFile = $ARGV[0] . ".bbl";           # input file names
if ($#ARGV == 0 || $ARGV[0] eq $ARGV[1]) { # default output file name
  $OutputRoot = $ARGV[0] . "-short";
}
else {                                     # use argument
  $OutputRoot = $ARGV[1];
}
  
# Open input files
open(OLD_BIB, "$OldBibFile") || die("Cannot open input file $OldBibFile!\n");

# Open output files
$BibFile = $OutputRoot . ".bbl";
open(BIB, ">$BibFile") || die("Cannot open output file $BibFile!\n");


#
# Store all the \bibitem data.  Assumes \bibitem's in the input file are 
# terminated by empty lines and that no more than one \bibitem is found
# on a single line.  Expected format is:
#   \bibitem[{short_author_list(year)long_author_list}]{KEY}...
# Note the match will have problems if there are any ']' characters in
# the bibliographic entry, and other deviations from the exact format
# may wreak havoc.
#
print "Reading bib file $OldBibFile... ";
$nBib = 0;
$found = 0;
while (<OLD_BIB>) {
  if (/\\bibitem/) {              # got a new one
    $nBib++;
    $found = 1;
  }
  next if not $found;
  $item .= $_;                    # add line to the current item
  if (/^\n/) {                    # finished reading, now process
    $item =~ s/\n//g;                                  # remove newlines
    $item =~ s/\{\\natexlab\{(.*?)\}\}/\1/g;           # remove \natexlab's
    $item =~ /.*?\[\{(.*?)\((\d{4}[a-z]*)\)(.*?)\}\]\{(.*?)\}(.*)/;
    ($ShortAuth, $year, $LongAuth, $key, $ref) = ($1, $2, $3, $4, $5);
    $LongAuth = "" if (length($LongAuth) < 1);
    push @keys, $key;
    $Years{$key} = $year;                              # store for later use
    $LongAuths{$key} = $LongAuth;
    $ShortAuths{$key} = $ShortAuth;
    $Refs{$key} = $ref;
    $found = 0;
    $item = "";
  }
}
close(OLD_BIB);
warn("\n** No bibitems found in $OldBibFile!\n") if $nBib < 1;
print "done.\n";


#
# Make new .bbl bibliography file, looping over items.  
# Output format is \bibitem[long_author_list year]{key}reference
#
print "Writing $BibFile... ";
print BIB "\\begin{$bibenv}";
print BIB "{$nBib}" unless ($refenv); #KB EDIT
print BIB "\n";
print BIB "\\expandafter\\ifx\\csname natexlab\\endcsname\\relax\\def\\natexlab#1{#1}\\fi";
print BIB "\n\n";
foreach $key (@keys) {
  $ref = $Refs{$key};
  $ref =~ s/,(\s*\(.*?\)\s*)$/\1/; # get rid of "," before parenthesized note
  $nAuths = 1 + ($LongAuths{$key} =~ tr/,/,/);   # count authors
  if ($MaxAuths > 0 && $nAuths > $MaxAuths) {    # too many to list
    if ($ref !~ /(.*?)(,)?\s*(\d{4})/) {
      warn("**Can't find year in reference:\n$ref\n");
    }
    ($auths, $lastComma) = ($1, $2);
    $end = index($ref, $3);
    if ($auths =~ /\w/) {        # this avoids refs like "---, 1998, ..."
      $nCommas = $MaxAuths;        # Jones J.J., ...
      $nCommas *= 2 if not $mnras; # Jones, J.J., ...
      if ($nCommas > ($auths =~ tr/,/,/)) {
	warn("**Error trying to truncate author list:\n$ref\n");
      }
      else {
	$pos = -1;
	#for $i (1..$nCommas) {     # find the n'th comma
	for $i (1..2) {             # crop the lists earlier - KB EDIT 3/30/08
	  $pos = index($auths, ',', $pos);
	  $pos++;
	}
	substr($ref, $pos, $end-$pos-1) = " $etal$lastComma"
      }
    }
  }
  if ($refenv) {
    print BIB "\\reference ";
  }
  else {
    print BIB "\\bibitem[{$ShortAuths{$key}($Years{$key})$LongAuths{$key}}]{$key}\n";
  }
  print BIB "$ref\n\n";
}
print BIB "\\end{$bibenv}\n";
close(BIB);
print "done.\n";



