# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit cmake python-single-r1

DESCRIPTION="AWS SDK for C++"
HOMEPAGE="https://aws.amazon.com/sdk-for-cpp/"
SRC_URI="https://github.com/aws/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# BUILD_ONLY lists
AWS_GROUP_storage="s3;s3-crt;s3control;glacier;ebs;efs;backup;storagegateway;snowball;datasync"
AWS_GROUP_compute="ec2;lambda;autoscaling;elbv2;ecr;ecs;batch;lightsail;outposts;compute-optimizer"
AWS_GROUP_networking="vpc-lattice;route53;cloudfront;globalaccelerator;directconnect;appmesh;networkmanager"
AWS_GROUP_database="rds;rdsdata;dynamodb;dynamodbstreams;redshift;redshift-data;timestream-query;timestream-write;qldb;qldb-session;neptune;keyspaces;memorydb"
AWS_GROUP_analytics="athena;glue;emr;kinesis;firehose;quicksight;dataexchange;lakeformation"
AWS_GROUP_messaging="sns;sqs;ses;sesv2;pinpoint;pinpointsmsvoice;chime;eventbridge"
AWS_GROUP_monitor="cloudwatch;logs;xray;events;config;cloudtrail;synthetics;devops-guru"
AWS_GROUP_security="kms;iam;organizations;accessanalyzer;guardduty;securityhub;detective;inspector;macie;waf;shield"
AWS_GROUP_ml="sagemaker;sagemaker-a2i-runtime;comprehend;rekognition;translate;textract;polly;kendra;forecast;frauddetector;bedrock"
AWS_GROUP_iot="iot;iot-data-plane;iot-jobs-data;iotevents;iotsecuretunneling;iotsitewise;greengrass;freertos"
AWS_GROUP_media="mediaconvert;medialive;mediastore;mediapackage;ivs;kinesisvideo"
AWS_GROUP_devops="codecommit;codedeploy;codebuild;codepipeline;codestar;codeartifact;codeguru-reviewer;codeguruprofiler;devicefarm"
AWS_GROUP_mgmt="cloudformation;systems-manager;servicecatalog;appconfig;application-autoscaling;resource-groups"
AWS_GROUP_other="backupstorage;launch-wizard;panorama;bedrock-agent"
AWS_GROUP_LIST=(storage compute networking database analytics messaging monitor security ml iot media devops mgmt other)

IUSE="+http pulseaudio +rtti +ssl test unity-build full ${AWS_GROUP_LIST[*]}"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	full? ( $(printf ' !%s' "${AWS_GROUP_LIST[@]}") )
"
RESTRICT="!test? ( test )"

DEPEND="
	http? ( net-misc/curl:= )
	pulseaudio? ( media-sound/pulseaudio )
	ssl? (
		dev-libs/openssl:0=
	)
	dev-libs/aws-crt-cpp:0=
	sys-libs/zlib
"
RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
"
BDEPEND="virtual/pkgconfig"

_aws_expand_group() {
	local _var="AWS_GROUP_${1}"
	printf "%s" "${!_var}"
}
src_configure() {
	local mybuildtargets="core;identity-management;sts"

	local g
	for g in "${AWS_GROUP_LIST[@]}" ; do
		if use "${g}" || use full ; then
			mybuildtargets+=";$( _aws_expand_group "${g}" )"
		fi
	done

	local mycmakeargs=(
		-DAUTORUN_UNIT_TESTS=$(usex test)
		-DAWS_SDK_WARNINGS_ARE_ERRORS=OFF
		-DBUILD_DEPS=NO
		-DBUILD_ONLY="${mybuildtargets}"
		-DBUILD_SHARED_LIBS=ON
		-DCPP_STANDARD=17
		-DENABLE_RTTI=$(usex rtti)
		-DENABLE_TESTING=$(usex test)
		-DENABLE_UNITY_BUILD=$(usex unity-build)
		-DNO_ENCRYPTION=$(usex !ssl)
		-DNO_HTTP_CLIENT=$(usex !http)
	)

	if use test; then
		# (#759802) Due to network sandboxing of portage, internet connectivity
		# tests will always fail. If you need a USE flag, because you want/need
		# to perform these tests manually, please open a bug report for it.
		mycmakeargs+=(
			-DENABLE_HTTP_CLIENT_TESTING=OFF
		)
	fi

	cmake_src_configure
}
