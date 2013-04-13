class File::Spec::Case;

method default_case_tolerant ($OS = $*OS) {
	so $OS eq any <MacOS Mac VMS darwin Win32 MSWin32 os2 dos NetWare symbian cygwin Cygwin epoc>;
}

method always_case_tolerant  ($OS = $*OS) {
	so $OS eq any <MacOS Mac VMS os2 dos>;
}

method case-tolerant (Str:D $path = $*CWD, $write_ok as Bool = True ) {
	# This code should be platform independent, but feel free to add local override

	$path.IO.e or fail "Invalid path given";
	my @dirs = self.splitdir(self.rel2abs($path));
	my @searchabledirs;

	# try looking at each component of $path to see if has letters
	loop (my $i = +@dirs; $i--; $i <= 0) {
		my $p = self.catdir(@dirs[0..$i]);
		push(@searchabledirs, $p) if $p.IO.d;

		last if $p.IO.l;
		next unless @dirs[$i] ~~ /<+alpha-[_]>/;

		return self!case-tolerant-folder: @dirs[0..($i-1)], @dirs[$i];
	}

	# If nothing in $path contains a letter, search for nearby files, including up the tree
	# This doesn't actually look recursively; don't want to add File::Find as a dependency
	for @searchabledirs -> $d {
		my @filelist = dir($d).grep(/<+alpha-[_]>/);
		next unless @filelist.elems;

		# anything with <alpha> will do
		return self!case-tolerant-folder: $d, @filelist[0];
	}

	# If we couldn't find anything suitable, try writing a test file
	if $write_ok {
		for @searchabledirs.grep({.IO.w}) -> $d {
			my $filelc = self.catdir( $d, 'filespec.tmp');  #because 8.3 filesystems...
			my $fileuc = self.catdir( $d, 'FILESPEC.TMP');
			if $filelc.IO.e or $fileuc.IO.e { die "Wait, where did the file matching <alpha> come from??"; }
			try {
				spurt $filelc, 'temporary test file for p6 File::Spec, feel free to delete';
				my $result = $fileuc.IO.e;
				unlink $filelc;
				return $result;
			}
			CATCH { unlink $filelc if $filelc.IO.e; }
		}
	}

	# Okay, we don't have write access... give up and just return the platform default
	return self.default-case-tolerant;

}

method !case-tolerant-folder( \updirs, $curdir ) {
	return False unless self.catdir( |updirs, $curdir.uc).IO.e
			 && self.catdir( |updirs, $curdir.lc).IO.e;
	return +dir(self.catdir(|updirs)).grep(/:i ^ $curdir $/) <= 1;
	# this could be faster by comparing inodes of .uc and .lc
	# but we can't guarantee POSIXness of every platform that calls this
}



