#
# Copyright (C) 2018 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Including this makefile will force AAPT2 on if FORCE_AAPT2==true,
# rewriting some properties to convert standard AAPT usage to AAPT2.

ifeq ($(FORCE_AAPT2),true)
  ifeq ($(LOCAL_USE_AAPT2),)
    # Force AAPT2 on
    LOCAL_USE_AAPT2 := true
    # Move LOCAL_STATIC_JAVA_AAR_LIBRARIES to LOCAL_STATIC_ANDROID_LIBRARIES
    LOCAL_STATIC_ANDROID_LIBRARIES := $(strip $(LOCAL_STATIC_ANDROID_LIBRARIES) $(LOCAL_STATIC_JAVA_AAR_LIBRARIES))
    LOCAL_STATIC_JAVA_AAR_LIBRARIES :=
    # Filter out support library resources
    LOCAL_RESOURCE_DIR := $(filter-out \
      prebuilts/sdk/current/% \
      frameworks/support/%,\
        $(LOCAL_RESOURCE_DIR))
    # Filter out unnecessary aapt flags
    LOCAL_AAPT_FLAGS := $(subst --extra-packages=,--extra-packages$(space), \
      $(filter-out \
        --extra-packages=android.support.% \
        --extra-packages=androidx.% \
        --auto-add-overlay,\
          $(subst --extra-packages$(space),--extra-packages=,$(LOCAL_AAPT_FLAGS))))

    # AAPT2 is pickier about missing resources.  Support library may have references to resources
    # added in current, so always treat LOCAL_SDK_VERSION as LOCAL_SDK_RES_VERSION := current.
    ifdef LOCAL_SDK_VERSION
      LOCAL_SDK_RES_VERSION := current
    endif

    ifeq (,$(strip $(LOCAL_MANIFEST_FILE)$(LOCAL_FULL_MANIFEST_FILE)))
      ifeq (,$(wildcard $(LOCAL_PATH)/AndroidManifest.xml))
        # work around missing manifests by creating a default one
        $(call pretty-warning, Missing manifest file)
        LOCAL_FULL_MANIFEST_FILE := $(call local-intermediates-dir,COMMON)/DefaultManifest.xml
        $(call create-default-manifest-file,$(LOCAL_FULL_MANIFEST_FILE))
      endif
    endif
  endif
endif

ifneq ($(LOCAL_USE_AAPT2),true)
  ifneq ($(LOCAL_USE_AAPT2),false)
    ifneq ($(LOCAL_USE_AAPT2),)
      $(call pretty-error,Invalid value for LOCAL_USE_AAPT2: "$(LOCAL_USE_AAPT2)")
    endif
  endif
endif
