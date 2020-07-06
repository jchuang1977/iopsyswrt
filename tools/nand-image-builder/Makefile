#
# Copyright (C) 2020 iopsys
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nand-image-builder
PKG_VERSION:=1.0

PKG_SOURCE_URL:=https://dev.iopsys.eu/broadcom/nand-image-builder.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE_VERSION:=f21177edf84ac46dc6f409d0015de8da6aa25ba6
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

# Source settings (i.e. where to find the source codes)
# This is a custom variable, used below
#SOURCE_DIR:=/home/se-pc-prakash/nand-image-builder/brcm-nand-bch-master

HOST_BUILD_DIR=$(BUILD_DIR_HOST)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/host-build.mk

define Host/Compile
	$(MAKE) -C $(HOST_BUILD_DIR)
endef

define Host/Install
	$(CP) \
		$(HOST_BUILD_DIR)/nand-image-builder \
		$(STAGING_DIR_HOST)/bin/
endef

$(eval $(call HostBuild))
