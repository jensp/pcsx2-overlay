# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

ESVN_REPO_URI="https://pcsx2.svn.sourceforge.net/svnroot/pcsx2/plugins/gs/zerogs/opengl"
inherit eutils games subversion autotools flag-o-matic

DESCRIPTION="PS2Emu ZeroGS OpenGL plugin"
HOMEPAGE="http://www.pcsx2.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug sse2 +shaders"

DEPEND="media-gfx/nvidia-cg-toolkit
	x11-libs/libX11
	media-libs/glew
	virtual/opengl
	media-libs/jpeg
	sys-libs/zlib
	x11-libs/libXxf86vm
	x11-proto/xproto
	x11-proto/xf86vidmodeproto
	>=x11-libs/gtk+-2"

S="${WORKDIR}/opengl"

pkg_setup() {
	if ! use debug && use shaders; then
		# The failure this causes is in the nvidia cg toolkit, not zerogs.
		append-ldflags -Wl,--no-as-needed
	fi
}

src_unpack() {
	subversion_src_unpack
	cd "${S}"

	epatch "${FILESDIR}/${PN}-gcc43.patch"
	epatch "${FILESDIR}/${PN}-devbuild-paths.patch"
	epatch "${FILESDIR}/${PN}-consistent-naming.patch"
	epatch "${FILESDIR}/${PN}-custom-cflags.patch"
	epatch "${FILESDIR}/${PN}-compile-shaders.patch"

	eautoreconf -v --install || die
	chmod +x configure
}

src_compile() {
	egamesconf  \
		$(use_enable debug devbuild) \
		$(use_enable debug) \
		$(use_enable sse2) \
		|| die

	emake || die

	if ! use debug && use shaders; then
		einfo "Compiling shaders..."
		emake -C ZeroGSShaders
		./ZeroGSShaders/zgsbuild ps2hw.fx ps2hw.dat || \
			die "Unable to compile shaders"
	fi
}

src_install() {
	exeinto "$(games_get_libdir)/ps2emu/plugins"
	insinto "$(games_get_libdir)/ps2emu/plugins"
	doexe libZeroGSogl.so.* || die
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