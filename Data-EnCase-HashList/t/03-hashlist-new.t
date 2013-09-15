use strict;
use warnings;

use Test::More tests => 3;
use Data::EnCase::HashList::Hash;
use File::Slurp;
use Data::EnCase::HashList;

my $darwin_string = <<'EOS';
MD5 (6.4//bin/alsaunmute) = 915f47a4ce27382b57507a07994a724a
MD5 (6.4//bin/arch) = 38097c0738a8ce35efa0423fd8a1423b
MD5 (6.4//bin/basename) = 71c90634e816513ea6eefa67fc4acb1d
MD5 (6.4//bin/bash) = ef3f99af9d17d86679db65ac4932963d
MD5 (6.4//bin/brltty) = f2713f904d5fecaac491acc8c880cdb1
MD5 (6.4//bin/brltty-config) = f72835f57ab4f3cafb1f78d55cec0c54
MD5 (6.4//bin/brltty-install) = 0f4e497c1b3cc2247b81bd5922b176d6
MD5 (6.4//bin/cat) = dac6914326b40d0db79c0407e1f0140a
MD5 (6.4//bin/chgrp) = 7a277be89885e1dec463d7189d5d4d38
MD5 (6.4//bin/chmod) = b15212a50fb5560529bf9c859ae8782c
EOS

my $solaris_string = <<'EOS';
md5 (/usr/sbin/in.tnamed) = 00d9057578730a47f5ad9a46d4e2bb2e
md5 (/usr/sbin/in.telnetd) = e2a280c6ae1f88b39cdccc351327831f
md5 (/usr/sbin/datadm) = a1bab0c1e7afaac4422fb5488141568c
md5 (/usr/sbin/sag) = a66b38b4058c98a7b060a2176a09e0f9
md5 (/usr/sbin/sar) = ae0ccc6c3635d44c08794b37129a53e8
md5 (/usr/sbin/ping) = f885e2305ec4e393d8549d3971b7caac
md5 (/usr/sbin/rmt) = 002e561d3ab09939fa7f2d4c0f4b709b
md5 (/usr/sbin/rwall) = 959fd9180a96afe1cd990176531370c8
md5 (/usr/sbin/snoop) = 3337def6240a56e1f1adb650dbf7a0da
md5 (/usr/sbin/spray) = 59a3fad99c55bb953618d65fbfb36132
EOS

my $linux_string = <<'EOS';
648d8624e708151500c5e299a6005afe  /etc/init.d/stop-bootlogd-single
da2af4d20b81a9a422a1b67eed69582f  /etc/init.d/pppd-dns
7862a970fca2cff93163ac9999619ad6  /etc/init.d/rcS
efd73fb6e7099b1e09d0e1bdf8de9151  /etc/init.d/rc
f5078cf9df66751dec9ae8f7baf4a0c2  /etc/init.d/grub-common
3b575caa7457cbe6cf096881064b834b  /etc/init.d/sendsigs
6ae1b3b1b8198567a5e32116077f12a2  /etc/init.d/halt
5f3600170b867d5408ad5b4ae6f8aae4  /etc/init.d/umountnfs.sh
14875a3578ab580e9b887b6b158b8291  /etc/init.d/rsync
96d5bd37396a40ab5fe7071139f780fc  /etc/init.d/urandom
EOS

foreach my $var ($darwin_string, $linux_string, $solaris_string) {
	my $hl = Data::EnCase::HashList->new(
		[ Data::EnCase::HashList::Hash->new_from_md5( $var ) ],
		'test_output',
	);
	ok($hl)
}
