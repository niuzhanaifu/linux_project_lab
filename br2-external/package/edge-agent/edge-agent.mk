EDGE_AGENT_VERSION = 0.1.0
EDGE_AGENT_SITE = $(BR2_EXTERNAL_EDGE_LAB_PATH)/../apps/edge-agent
EDGE_AGENT_SITE_METHOD = local

define EDGE_AGENT_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="$(TARGET_LDFLAGS)" -C $(@D)
endef

define EDGE_AGENT_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/edge-agent $(TARGET_DIR)/usr/bin/edge-agent
	$(INSTALL) -D -m 0755 $(@D)/S99edge-agent $(TARGET_DIR)/etc/init.d/S99edge-agent
endef

$(eval $(generic-package))

