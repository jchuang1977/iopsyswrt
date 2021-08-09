BUILD_DATE := $(shell date '+%y%m%d_%H%M')
IOPSYS_VERSION_SUFFIX := $(subst ",,-X-$(CONFIG_TARGET_CUSTOMER)-$(CONFIG_TARGET_VERSION)-$(BUILD_DATE))

# $$(1) contains the filesystem name
# $$(2) contains the image name suffix as configured by the variable IMAGE/xxx
# IMAGE_NAME specifies the target image file name
define Device/iopsys-common
	IMAGE_NAME = $$(DEVICE_MODEL)$(IOPSYS_VERSION_SUFFIX)-$$(1)$$(2)
	IOPSYS_BUILD_VERSION = $$(DEVICE_MODEL)$(IOPSYS_VERSION_SUFFIX)
endef
# new introduced variables to Device/XXX should be added to DEVICE_VARS
DEVICE_VARS += IOPSYS_BUILD_VERSION

# $(1) target rootfs
define iopsys-install-release-info
	mkdir -p $(1)/etc/board-db/version
	echo $(IOPSYS_BUILD_VERSION)   > $(1)/etc/board-db/version/iop_version
	echo $(CONFIG_TARGET_CUSTOMER) > $(1)/etc/board-db/version/iop_customer
endef

# $(1) output file - the fit image
# $(N) fit component name
# $(N+1) fit component file
define iopsys-fit-upgrade-image
	CREATION_DATE="$(subst _, ,$(BUILD_DATE))" \
    MODEL="$(DEVICE_MODEL)" \
    IOPSYS_VERSION="$(IOPSYS_BUILD_VERSION)" \
    $(TOPDIR)/scripts/mkits-iopsys-upgrade-image.sh \
    $(1).its $(2) $(3) $(4) $(5) $(6) $(7) $(8) $(9)

	PATH=$(LINUX_DIR)/scripts/dtc:$(PATH) mkimage -f $(1).its $(1).new
	@mv $(1).new $(1)
	# FIXME: this is prone to race-conditions when multiple
	# images/filesystems are generated.
	ln -sf $$(basename $@) $(BIN_DIR)/last.itb
endef
