# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-frameworks/threadweaver/threadweaver-5.10.0.ebuild,v 1.1 2015/05/09 10:36:04 mrueg Exp $

EAPI=5

inherit kde5

DESCRIPTION="Framework for managing threads using job and queue-based interfaces"
LICENSE="LGPL-2+"
KEYWORDS=" ~amd64 ~x86"
IUSE=""

src_prepare() {
	comment_add_subdirectory benchmarks
	kde5_src_prepare
}
