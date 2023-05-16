# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="AWS C S3 Library"
HOMEPAGE="https://github.com/awslabs/aws-c-s3"
SRC_URI="https://github.com/awslabs/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs test"

RESTRICT="!test? ( test )"

DEPEND="
	>=dev-libs/aws-c-common-0.6.20:0=[static-libs=]
	>=dev-libs/aws-c-cal-0.5.17:0=[static-libs=]
	>=dev-libs/aws-c-io-0.11.0:0=[static-libs=]
	>=dev-libs/aws-c-compression-0.2.14:0=[static-libs=]
	>=dev-libs/aws-c-http-0.6.13:0=[static-libs=]
	>=dev-libs/aws-c-sdkutils-0.1.2:0=[static-libs=]
	>=dev-libs/aws-c-auth-0.6.11:0=[static-libs=]
	>=dev-libs/s2n-1.3.10:0=[static-libs=]
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.1.38-cmake-prefix.patch
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex !static-libs)
		-DBUILD_TESTING=$(usex test)
	)
	cmake_src_configure
}
