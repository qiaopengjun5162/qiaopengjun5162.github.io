#!/bin/bash
# Copyright (c) 2024 Paxon Qiao<qiaopengjun0@gmail.com>. All rights reserved.
# Use of this source is governed by General Public License that can be found
# in the LICENSE file.

set -xe

# Create a new article template.

ARTICLE=$1
if [ -z "${ARTICLE}" ]; then
  echo "$0 article-name"
  exit 1
fi

# 尝试获取RFC 3339格式的时间戳，如果不支持则使用备选方案
if command -v gdate &> /dev/null && gdate --version | grep -q 'GNU coreutils'; then
  # 使用GNU date（可能通过gdate安装）
  TIMESTAMPE=$(gdate --rfc-3339=seconds)
else
  # 备选方案：使用非GNU date的格式化选项（可能不完全符合RFC 3339，但通常足够）
  TIMESTAMPE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
fi

FILENAME="content/$(date +%Y-%m-%d)-${ARTICLE}.md"
URL_PATH="$(date +%Y)/$(date +%m)/${ARTICLE}"

echo "TIMESTAMP: ${TIMESTAMPE}"
echo "FILENAME: ${FILENAME}"
echo "URL_PATH: ${URL_PATH}"

if [ ! -f "${FILENAME}" ]; then
  cat > "${FILENAME}" << EOF
+++
title = "${ARTICLE}"
description = ""
date = ${TIMESTAMPE}
[taxonomies]
categories = []
tags = []
+++

<!-- more -->

EOF

fi

vim "${FILENAME}"

# path = "${URL_PATH}"
