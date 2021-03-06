# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/linux-misc-apps/linux-misc-apps-3.18.ebuild,v 1.1 2014/12/29 00:12:01 robbat2 Exp $

EAPI=5

inherit versionator eutils toolchain-funcs linux-info autotools flag-o-matic

DESCRIPTION="Misc tools bundled with kernel sources"
HOMEPAGE="http://kernel.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE="static-libs tcpd"

MY_PV="${PV/_/-}"
MY_PV="${MY_PV/-pre/-git}"

LINUX_V=$(get_version_component_range 1-2)

if [ ${PV/_rc} != ${PV} ]; then
	LINUX_VER=$(get_version_component_range 1-2).$(($(get_version_component_range 3)-1))
	PATCH_VERSION=$(get_version_component_range 1-3)
	LINUX_PATCH=patch-${PV//_/-}.xz
	SRC_URI="mirror://kernel/linux/kernel/v3.x/testing/${LINUX_PATCH}
		mirror://kernel/linux/kernel/v3.x/testing/v${PATCH_VERSION}/${LINUX_PATCH}"
elif [ $(get_version_component_count) == 4 ]; then
	# stable-release series
	LINUX_VER=$(get_version_component_range 1-3)
	LINUX_PATCH=patch-${PV}.xz
	SRC_URI="mirror://kernel/linux/kernel/v3.x/${LINUX_PATCH}"
else
	LINUX_VER=${PV}
fi

LINUX_SOURCES=linux-${LINUX_VER}.tar.xz
SRC_URI="${SRC_URI} mirror://kernel/linux/kernel/v3.x/${LINUX_SOURCES}"

# pmtools also provides turbostat
# usbip available in seperate package now
RDEPEND="sys-apps/hwids
		>=dev-libs/glib-2.6
		tcpd? ( sys-apps/tcp-wrappers )
		!sys-power/pmtools"
DEPEND="${RDEPEND}
		virtual/pkgconfig"

S="${WORKDIR}/linux-${LINUX_VER}"

# All of these are integrated with the kernel build system,
# No make install, and ideally build with with the root Makefile
TARGETS_SIMPLE=(
	Documentation/accounting/getdelays.c
	tools/cgroup/cgroup_event_listener.c
	Documentation/laptops/dslm.c
	Documentation/laptops/freefall.c
	Documentation/networking/timestamping/timestamping.c
	Documentation/watchdog/src/watchdog-simple.c
	tools/lguest/lguest.c
	tools/vm/slabinfo.c
	usr/gen_init_cpio.c
)
# tools/vm/page-types.c - broken, header path issue
# tools/hv/hv_kvp_daemon.c - broken in 3.7 by missing linux/hyperv.h userspace
# Documentation/networking/ifenslave.c - obsolete
# Documentation/ptp/testptp.c - pending linux-headers-3.0

# These have a broken make install, no DESTDIR
TARGET_MAKE_SIMPLE=(
	tools/firewire:nosy-dump
	tools/power/x86/turbostat:../../../../turbostat
	tools/power/x86/x86_energy_perf_policy:x86_energy_perf_policy
	Documentation/misc-devices/mei:mei-amt-version
)
# tools/perf - covered by dev-utils/perf
# tools/usb - testcases only
# tools/virtio - testcaes only

	#for _pattern in {Documentation,scripts,tools,usr,include,lib,"arch/*/include",Makefile,Kbuild,Kconfig}; do
src_unpack() {
	unpack ${LINUX_SOURCES}

	MY_A=
	for _AFILE in ${A}; do
		[[ ${_AFILE} == ${LINUX_SOURCES} ]] && continue
		[[ ${_AFILE} == ${LINUX_PATCH} ]] && continue
		MY_A="${MY_A} ${_AFILE}"
	done
	[[ -n ${MY_A} ]] && unpack ${MY_A}
}

src_prepare() {
	if [[ -n ${LINUX_PATCH} ]]; then
		epatch "${DISTDIR}"/${LINUX_PATCH}
	fi

	sed -i \
		-e '/^nosy-dump.*LDFLAGS/d' \
		-e '/^nosy-dump.*CFLAGS/d' \
		-e '/^nosy-dump.*CPPFLAGS/s,CPPFLAGS =,CPPFLAGS +=,g' \
		"${S}"/tools/firewire/Makefile
}

kernel_asm_arch() {
	a="${1:${ARCH}}"
	case ${a} in
		# Merged arches
		x86|amd64) echo x86 ;;
		ppc*) echo powerpc ;;
		# Non-merged
		alpha|arm|ia64|m68k|mips|sh|sparc*) echo ${1} ;;
		*) die "TODO: Update the code for your asm-ARCH symlink" ;;
	esac
}

src_configure() {
	:
}

src_compile() {
	local karch=$(kernel_asm_arch "${ARCH}")
	# This is the minimal amount needed to start building host binaries.
	#emake allmodconfig ARCH=${karch}
	#emake prepare modules_prepare ARCH=${karch}
	#touch Module.symvers

	# Now we can start building
	for s in ${TARGETS_SIMPLE[@]} ; do
		dir=$(dirname $s) src=$(basename $s) bin=${src%.c}
		einfo "Building $s => $bin"
		emake -f /dev/null M=${dir} ARCH=${karch} ${s%.c}
	done

	for t in ${TARGET_MAKE_SIMPLE[@]} ; do
		dir=${t/:*} target=${t/*:}
		einfo "Building $dir => $target"
		emake -C $dir ARCH=${karch} $target
	done
}

src_install() {
	into /usr
	for s in ${TARGETS_SIMPLE[@]} ; do
		dir=$(dirname $s) src=$(basename $s) bin=${src%.c}
		einfo "Installing $s => $bin"
		dosbin ${dir}/${bin}
	done

	for t in ${TARGET_MAKE_SIMPLE[@]} ; do
		dir=${t/:*} target=${t/*:}
		einfo "Installing $dir => $target"
		dosbin ${dir}/${target}
	done

	newconfd "${FILESDIR}"/freefall.confd freefall
	newinitd "${FILESDIR}"/freefall.initd freefall
	prune_libtool_files
}

pkg_postinst() {
	echo
	elog "The cpupower utility is maintained separately at sys-power/cpupower"
	elog "The usbip utility is maintained separately at net-misc/usbip"
}
