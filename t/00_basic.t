use v6;
use Test;
use File::Spec::Case;

plan 1;

if (cwd.IO ~~ :w) {
	"casetol.tmp".IO.e or spurt "casetol.tmp", "temporary test file, delete after reading";
	is $Unix.case-tolerant("casetol.tmp"), so "CASETOL.TMP".IO.e,
		"case-tolerant is {so "CASETOL.TMP".IO.e} in cwd";
	unlink "casetol.tmp";
}
else { skip "case-tolerant, no write access in cwd", 1; } 
