# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="AWS SDK Utilities Library"
HOMEPAGE="https://github.com/awslabs/aws-c-sdkutils"
SRC_URI="https://github.com/awslabs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="static-libs test"

RESTRICT="!test? ( test )"

DEPEND="
	dev-libs/aws-c-common:0=[static-libs=]
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.1.2-cmake-prefix.patch
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex !static-libs)
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
