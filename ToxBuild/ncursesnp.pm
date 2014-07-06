# vim:ts=4
#
# Copyright (c) 2014 David Mackay
# Copyright (c) 2002-2011 Hypertriton, Inc. <http://hypertriton.com/>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
my $testCode = << 'EOF';
#include <ncurses.h>

int
main(int argc, char *argv[])
{
	return (0);
}
EOF

my @autoPrefixes = (
	'/usr/local',
	'/usr',
	'/opt/local',
	'/opt',
);

sub Test
{
	my ($ver, $pfx) = @_;

	MkDefine('NCURSES_CFLAGS', '');
	MkDefine('NCURSES_LIBS', '');

	MkIfNE($pfx, '');
			MkIfExists("$pfx/include/ncurses.h");
				MkDefine('NCURSES_CFLAGS', "-I$pfx/include");
			    MkDefine('NCURSES_LIBS', "-L$pfx/lib -lncurses");
			MkEndif;
			MkIfExists("$pfx/include/ncurses/ncurses.h");
				MkDefine('NCURSES_CFLAGS', "-I$pfx/include");
			    MkDefine('NCURSES_LIBS', "-L$pfx/lib -lncurses");
			MkEndif;
	MkElse;
		foreach my $dir (@autoPrefixes) {
			MkIfExists("$dir/include/ncurses.h");
				MkDefine('NCURSES_CFLAGS', "-I$dir/include");
			    MkDefine('NCURSES_LIBS', "-L$dir/lib -lncurses");
			MkEndif;
			MkIfExists("$dir/include/ncurses/ncurses.h");
				MkDefine('NCURSES_CFLAGS', "-I$dir/include");
			    MkDefine('NCURSES_LIBS', "-L$dir/lib -lncurses");
			MkEndif;
		}
	MkEndif;

	MkIfNE('${NCURSES_LIBS}', '');
		MkPrint('yes');
		MkPrintN('checking whether ncurses works...');
		MkCompileC('HAVE_NCURSES', '${NCURSES_CFLAGS}', '${NCURSES_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_NCURSES}', 'NCURSES_CFLAGS', 'NCURSES_LIBS');
		MkCompileC('HAVE_NCURSESNP', '${NCURSES_CFLAGS}', '${NCURSES_LIBS}', $testCode);
		MkSaveIfTrue('${HAVE_NCURSESNP}', 'NCURSES_CFLAGS', 'NCURSES_LIBS');
	MkElse;
		MkPrint('no');
		MkSaveUndef('HAVE_NCURSES', 'NCURSES_CFLAGS', 'NCURSES_LIBS');
	MkEndif;
}

BEGIN
{
	$TESTS{'ncursesnp'} = \&Test;
	$DEPS{'ncursesnp'} = 'cc';
	$DESCR{'ncursesnp'} = 'ncurses (http://www.gnu.org/software/ncurses)';
}
;1
