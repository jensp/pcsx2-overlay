# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

ESVN_REPO_URI="http://sanechka.spb.ru/svnroot/ruslan/zerogs/"
inherit eutils games flag-o-matic multilib autotools subversion

DESCRIPTION="PS2Emu ZZogl OpenGL plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
RESTRICT="primaryuri"
IUSE="debug sse2 shaders"

COMMON_DEPEND="
	x86? (
		x11-libs/libX11
		virtual/opengl
		media-libs/jpeg
		sys-libs/zlib
		x11-libs/libXxf86vm
		x11-proto/xproto
		x11-proto/xf86vidmodeproto
		>=x11-libs/gtk+-2
		media-libs/glew
	)
	amd64? (
		>=app-emulation/emul-linux-x86-xlibs-20091226[opengl]
		>=app-emulation/emul-linux-x86-baselibs-20081109
		app-emulation/emul-linux-x86-gtklibs
		>=media-gfx/nvidia-cg-toolkit-2.1.0017[multilib]
	)
	!amd64? (
		>=media-gfx/nvidia-cg-toolkit-2.1.0016
	)
	!games-emulation/ps2emu-zerogs"
DEPEND="${COMMON_DEPEND}
	amd64? ( media-libs/glew )"
RDEPEND="${COMMON_DEPEND}
	games-emulation/pcsx2"

S="${WORKDIR}/opengl"

pkg_setup() {
	games_pkg_setup

	# Fix for compile error.
	append-flags "-I${S}/common"
	append-ldflags -Wl,--no-as-needed

	if use amd64 && ! has_multilib_profile; then
		eerror "You must be on a multilib profile to use pcsx2!"
		die "No multilib profile."
	fi
	use amd64 && multilib_toolchain_setup x86
}

src_unpack() {
	local S="${WORKDIR}"
	subversion_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.1.166_gcc43.patch"
	epatch "${FILESDIR}/${PN}-0.1.166_consistent-naming.patch"
	epatch "${FILESDIR}/${PN}-0.1.205_gentoo.patch"
	epatch "${FILESDIR}/${PN}-0.1.166_ambiguous-abs.patch"
	epatch "${FILESDIR}/${PN}-0.1.166_include-paths.patch"
	epatch "${FILESDIR}/${PN}-0.1.166_required-libraries.patch"

	eautoreconf -v --install || die
	chmod +x configure
}

src_configure() {
	egamesconf  \
		$(use_enable debug devbuild) \
		$(use_enable debug) \
		$(use_enable sse2) \
		|| die
}

src_compile() {
	if ! emake; then
		if use shaders; then
			eerror "Tips for debugging your build failure:"
			eerror "  Try building with USE=\"-shaders\""
		fi
		die "emake failed"
	fi

	if ! use debug && use shaders; then
		einfo "Compiling shaders..."
		emake -C ZeroGSShaders || die "Unable to compile shader compiler."
		./ZeroGSShaders/zgsbuild ps2hw.fx ps2hw.dat || \
			die "Unable to compile shaders"
	fi
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	insinto "$(games_get_libdir)/ps2emu/plugins"
	newexe libZeroGSogl.so.* libZZogl.so || die
	if use debug; then
		doins ps2hw.fx || die
		doins ctx1/ps2hw_ctx.fx || die
	else
		if use shaders; then
			doins ps2hw.dat || die
		else
			doins Win32/ps2hw.dat || die
		fi
	fi
	prepgamesdirs
}
