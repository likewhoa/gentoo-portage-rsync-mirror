# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/fleet/fleet-0.10.1.ebuild,v 1.1 2015/05/02 15:52:50 alunduil Exp $

EAPI=5

inherit systemd vcs-snapshot

DESCRIPTION="A Distributed init System"
HOMEPAGE="https://github.com/coreos/fleet"
SRC_URI="https://github.com/coreos/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc examples"

DEPEND=">=dev-lang/go-1.3"
RDEPEND=""

src_compile() {
	./build || die 'Build failed'
}

RESTRICT="test"  # Tests fail due to Gentoo bug #500452
src_test() {
	./test || die 'Tests failed'
}

src_install() {
	dobin "${S}"/bin/fleetd
	dobin "${S}"/bin/fleetctl

	systemd_dounit "${FILESDIR}"/fleet.service
	systemd_dounit "${FILESDIR}"/fleet.socket

	dodoc README.md
	use doc && dodoc -r Documentation
	use examples && dodoc -r examples

	keepdir /etc/${PN}
	insinto /etc/${PN}
	newins "${PN}".conf.sample "${PN}".conf
}

pkg_postinst() {
	ewarn "Please read this if you are upgrading from a version <0.10.0-r1."
	ewarn ""
	ewarn "Starting with fleet 0.10 the fleetctl utility has"
	ewarn "'--endpoint=unix:///var/run/fleet.sock' as default argument, which is"
	ewarn "why we have introduced the fleet.socket unit and renamed the service"
	ewarn "from fleetd.service to fleet.service. If you run fleet on system"
	ewarn "startup, please re-enable it via 'systemctl enable fleet'."
}
