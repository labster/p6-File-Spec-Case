p6-File-Spec-Case
=================

Check if your filesystem is case sensitive or case tolerant (insensitive)

## SYNOPSIS



## DESCRIPTION

Given a directory, this module attempts to determine whether that particular part of the filesystem is case sensitive or insensitive.  In order to be platform independendent, this module interacts with the filesystem to attempt to determine case, because nowadays it's entirely possible to support multiple case filesystems on Windows, Linux, and Mac OS X.

This module splits little-used functionality off from File::Spec, and adds it to it's own module if you need it.  As a big change from Perl 5, it now applies only to a specific directory -- with symlinks and multiple partitions, you can't assume anything beyond that.

### case_tolerant
Method `case_tolerant` now requires a path (default $*CWD), below which it tests for case sensitivity.  A :no-write parameter may be passed if you want to disable writing of test files (which is tried last).

	File::Spec.case_tolerant('foo/bar');
	File::Spec.case_tolerant('/etc', :no-write);

It will find case (in)sensitivity if any of the following are true, in increasing order of desperation:

* The $path passed contains \<alpha\> and no symbolic links.
* The $path contains \<alpha\> after the last symlink.
* Any folders in the path (under the last symlink, if applicable) contain a file matching \<alpha\>.
* Any folders in the path (under the last symlink, if applicable) are writable.

Otherwise, it returns the platform default.