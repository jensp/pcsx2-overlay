# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/cdvd/CDVDisoEFP"
inherit eutils games subversion

DESCRIPTION="PS2Emu ISO CDVD EFP plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND=">=x11-libs/gtk+-2.6.1"
RDEPEND="${DEPEND}"

S="${WORKDIR}/CDVDisoEFP"

src_unpack() {
	subversion_src_unpack
	S="${S}/src/Linux"
	cd "${S}"

	sed -i \
		-e '/^CC =/d' \
		-e '/\bstrip\b/d' \
		-e 's/-g\b//g' \
		-e 's/CFLAGS =/CFLAGS +=/' \
		-e 's/$(CC)/$(CC) $(CFLAGS) $(LDFLAGS)/g' \
		-e 's/-O[0-9]//g' \
		-e 's/-fomit-frame-pointer//g' \
		Makefile || die
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libCDVDisoEFP.so || die
	exeinto "$(games_get_libdir)/ps2emu/plugins/cfg"
	doexe cfgCDVDisoEFP || die
	use doc && dodoc ../../readme.txt ../../ChangeLog.txt || die
	prepgamesdirs
}