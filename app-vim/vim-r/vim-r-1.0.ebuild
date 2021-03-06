# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-vim/vim-r/vim-r-1.0.ebuild,v 1.1 2014/10/14 05:27:53 radhermit Exp $

EAPI=5

inherit vim-plugin

DESCRIPTION="vim plugin: integrate vim with R"
HOMEPAGE="http://www.vim.org/scripts/script.php?script_id=2628"
LICENSE="public-domain"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-lang/R"

VIM_PLUGIN_HELPFILES="r-plugin.txt"

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "This plugin requires the vimcom R package to be installed,"
		elog "see https://github.com/jalvesaq/VimCom for instructions."
	fi
}
