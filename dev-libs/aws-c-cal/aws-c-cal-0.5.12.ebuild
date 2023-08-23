# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Crypto Abstraction Layer: Cross-Platform C99 wrapper for cryptography primitives"
HOMEPAGE="https://github.com/awslabs/aws-c-cal"
SRC_URI="https://github.com/awslabs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs test"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/aws-c-common-0.6.11:0=[static-libs=]
	>=dev-libs/openssl-1.1.1:0=[static-libs=]
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.5.9-cmake-prefix.patch
	"${FILESDIR}"/${PN}-0.5.9-add_libz_for_static.patch
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex !static-libs)
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
