# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
ESVN_REPO_URI="http://pcsx2.googlecode.com/svn/tags/0.9.6/plugins/SPU2null"
inherit eutils games subversion flag-o-matic multilib

DESCRIPTION="PS2Emu null sound plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"
RESTRICT="mirror"

DEPEND="
	x86? (
		>=x11-libs/gtk+-2
	)
	amd64? (
		app-emulation/emul-linux-x86-gtklibs
	)"

RDEPEND="${DEPEND}
	|| ( games-emulation/pcsx2 games-emulation/pcsx2-playground )"

S="${WORKDIR}/SPU2null/Src"

pkg_setup() {
	games_pkg_setup

	if use amd64 && ! has_m32; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	ABI="x86"
	ABI_ALLOW="x86"
	append-flags -m32
}

src_unpack() {
	local S="${WORKDIR}/SPU2null"
	subversion_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-custom-cflags.patch
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libSPU2null.so || die
	if use doc; then
		dodoc ../ReadMe.txt Changelog.txt || die
	fi
	prepgamesdirs
}