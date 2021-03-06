# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-forensics/rifiuti/rifiuti-20040505_p1.ebuild,v 1.8 2012/11/25 09:51:10 radhermit Exp $

inherit toolchain-funcs

MY_P=${PN}_${PV/_p/_}
DESCRIPTION="Recycle Bin Analyzer"
HOMEPAGE="http://sourceforge.net/projects/odessa/"
SRC_URI="mirror://sourceforge/odessa/${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~ppc x86"
IUSE=""

S=${WORKDIR}/${MY_P}

src_compile() {
	cd src
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o rifiuti rifiuti.c -lm -lc || die "failed to compile"
}

src_install() {
	dobin src/rifiuti
}
