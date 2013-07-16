# 
# Copyright 2013 Yummy Melon Software LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Author: Charles Y. Choi <charles.choi@yummymelon.com>
#

# Edit PUBLISH_BASE to be the base directory to install YmsCoreBluetooth.
PUBLISH_BASE=
PUBLISH_TARGET=${PUBLISH_BASE}/YmsCoreBluetooth

doc: cleanBackup
	appledoc \
	--project-name "YmsCoreBluetooth Framework + Deanna" \
	--project-company 'Yummy Melon Software LLC' \
	--company-id 'com.yummymelon' \
	--logformat xcode \
        --exit-threshold 2 \
	--output docs \
	--index-desc ./docs/index.md \
	--include ./docs/tutorial \
	Deanna \
	YmsCoreBluetooth


html: cleanBackup
	appledoc \
	-h \
	--project-name "YmsCoreBluetooth Framework + Deanna" \
	--project-company 'Yummy Melon Software LLC' \
	--company-id 'com.yummymelon' \
        --exit-threshold 2 \
	--output docs \
	--index-desc ./docs/index.md \
	--include ./docs/tutorial \
	--no-create-docset \
	Deanna \
	YmsCoreBluetooth

publish:
	rsync -avz --delete YmsCoreBluetooth/ ${PUBLISH_TARGET}

cleanBackup:
	find . -name '*~' -delete


clean: cleanBackup

