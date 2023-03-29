# $(BOARD) is not defined in all cases, so use this monstrosity instead
board_subdir:=$(if $(BOARD),$(BOARD),$(notdir $(patsubst %/,%,$(dir $(CURDIR)))))

include $(TOPDIR)/target/linux/feed-devices/feed-devices-list.mk
$(foreach feed_devices_dir,$(FEED_DEVICES_DIRS), \
$(eval -include $(feed_devices_dir)/$(board_subdir)/image/$(SUBTARGET).mk) \
)
