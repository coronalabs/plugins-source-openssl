# Copyright (C) 2012 Corona Labs Inc.
#

# TARGET_PLATFORM := android-8

LOCAL_PATH := $(call my-dir)

CORONA_ENTERPRISE := /Applications/CoronaEnterprise
CORONA_ROOT := $(CORONA_ENTERPRISE)/Corona
LUA_API_DIR := $(CORONA_ROOT)/shared/include/lua

PLUGIN_DIR := ../..

SDK_LUA_OPENSSL := $(PLUGIN_DIR)/sdk-lua-openssl/src
SDK_LUASOCKET := $(PLUGIN_DIR)/sdk-luasocket/src
SDK_OPENSSL := $(PLUGIN_DIR)/sdk-openssl/android

# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := libcrypto
LOCAL_SRC_FILES := $(SDK_OPENSSL)/lib/libcrypto.a
LOCAL_EXPORT_C_INCLUDES := $(SDK_OPENSSL)/include
include $(PREBUILT_STATIC_LIBRARY)

# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := libssl
LOCAL_SRC_FILES := $(SDK_OPENSSL)/lib/libssl.a
LOCAL_EXPORT_C_INCLUDES := $(SDK_OPENSSL)/include
include $(PREBUILT_STATIC_LIBRARY)

# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := liblua
LOCAL_SRC_FILES := ../liblua.so
#LOCAL_EXPORT_C_INCLUDES := $(LUA_API_DIR)
include $(PREBUILT_SHARED_LIBRARY)

# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := libplugin.openssl

LOCAL_C_INCLUDES := \
	.. \
	$(LUA_API_DIR) \
	$(SDK_LUA_OPENSSL) \
	$(SDK_LUASOCKET) \
	$(SDK_OPENSSL)/include

LOCAL_SRC_FILES := \
	$(SDK_LUASOCKET)/auxiliar.c \
	$(SDK_LUASOCKET)/buffer.c \
	$(SDK_LUASOCKET)/except.c \
	$(SDK_LUASOCKET)/inet.c \
	$(SDK_LUASOCKET)/io.c \
	$(SDK_LUASOCKET)/luasocket.c \
	$(SDK_LUASOCKET)/makefile \
	$(SDK_LUASOCKET)/mime.c \
	$(SDK_LUASOCKET)/options.c \
	$(SDK_LUASOCKET)/select.c \
	$(SDK_LUASOCKET)/tcp.c \
	$(SDK_LUASOCKET)/timeout.c \
	$(SDK_LUASOCKET)/udp.c \
	$(SDK_LUASOCKET)/unix.c \
	$(SDK_LUASOCKET)/usocket.c \
	\
	$(SDK_LUA_OPENSSL)/bio.c \
	$(SDK_LUA_OPENSSL)/cipher.c \
	$(SDK_LUA_OPENSSL)/conf.c \
	$(SDK_LUA_OPENSSL)/corona_auxiliar.c \
	$(SDK_LUA_OPENSSL)/crl.c \
	$(SDK_LUA_OPENSSL)/csr.c \
	$(SDK_LUA_OPENSSL)/digest.c \
	$(SDK_LUA_OPENSSL)/engine.c \
	$(SDK_LUA_OPENSSL)/lbn.c \
	$(SDK_LUA_OPENSSL)/misc.c \
	$(SDK_LUA_OPENSSL)/ocsp.c \
	$(SDK_LUA_OPENSSL)/openssl.c \
	$(SDK_LUA_OPENSSL)/ots.c \
	$(SDK_LUA_OPENSSL)/pkcs12.c \
	$(SDK_LUA_OPENSSL)/pkcs7.c \
	$(SDK_LUA_OPENSSL)/pkey.c \
	$(SDK_LUA_OPENSSL)/ssl.c \
	$(SDK_LUA_OPENSSL)/x509.c \
	$(SDK_LUA_OPENSSL)/xattrs.c \
	$(SDK_LUA_OPENSSL)/xexts.c \
	$(SDK_LUA_OPENSSL)/xname.c

LOCAL_CFLAGS := \
	-DANDROID_NDK \
	-DNDEBUG \
	-D_REENTRANT \
	-DRtt_ANDROID_ENV

LOCAL_LDLIBS := -llog -lz

LOCAL_SHARED_LIBRARIES := \
	liblua

# IMPORTANT: Do NOT change the order of the libraries in LOCAL_STATIC_LIBRARIES.
# Otherwise some symbols won't be found at link-time.
LOCAL_STATIC_LIBRARIES := \
	libssl \
	libcrypto

ifeq ($(TARGET_ARCH),arm)
LOCAL_CFLAGS+= -D_ARM_ASSEM_
endif

# Arm vs Thumb.
LOCAL_ARM_MODE := arm
include $(BUILD_SHARED_LIBRARY)
