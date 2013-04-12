# Copyright (C) 2005 - Scirocco Michelle Six
#
# This file is part of Ape, The Arbitrary Perl embedder
#
# Ape, the Arbitrary Perl Embedder is distributed under the
# Artistic License.  Please see the file LICENSE for details.
#
#
# This is the base for the hash of perl key words
# words that we treat specially do not appear, those are
#
# q qq qx qw m s y tr
# 

@keys = qw(NULL	__LINE__ __FILE__ __DATA__ __END__ AUTOLOAD BEGIN CORE
DESTROY END EQ GE GT LE LT NE abs accept alarm and atan2 bind binmode
bless caller chdir chmod chomp chop chown chr chroot close closedir
cmp connect continue cos crypt dbmclose dbmopen defined delete die do
dump each else elsif endgrent endhostent endnetent endprotoent endpwent
endservent eof eq eval exec exists exit exp fcntl fileno flock for foreach
fork format formline ge getc getgrent getgrgid getgrnam gethostbyaddr
gethostbyname gethostent getlogin getnetbyaddr getnetbyname getnetent
getpeername getpgrp getppid getpriority getprotobyname getprotobynumber
getprotoent getpwent getpwnam getpwuid getservbyname getservbyport
getservent getsockname getsockopt glob gmtime goto grep gt hex if index
int ioctl join keys kill last lc lcfirst le length link listen local
localtime log lstat lt map mkdir msgctl msgget msgrcv msgsnd my ne next
no not oct open opendir or ord pack package pipe pop pos print printf
prototype push quotemeta rand read readdir readline readlink
readpipe recv redo ref rename reset return reverse rewinddir rindex
rmdir scalar seek seekdir select semctl semget semop send setgrent
sethostent setnetent setpgrp setpriority setprotoent setpwent setservent
setsockopt shift shmctl shmget shmread shmwrite shutdown sin sleep socket
socketpair sort splice split sprintf sqrt srand stat study sub substr
symlink syscall sysopen sysread system syswrite tell telldir tie tied
time times truncate uc ucfirst umask undef unless unlink unpack unshift
untie until utime values vec wait waitpid wantarray warn while write
x xor);
@key_words{@keys} = ("T") x @keys;
1
