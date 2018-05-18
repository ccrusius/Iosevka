VERSION = 1.14.3
export VERSION

# Reasoned settings
# v-zero-dotted: Because the empty set symbol looks like zero dashed
# v-asterisk-low: Best for algebraic expressions
CUSTOM_DESIGN=term expanded v-zero-dotted v-asterisk-low
# Personal preference settings
CUSTOM_DESIGN+=v-underscore-low v-brace-straight
NODE_DIR=../node-v8.6.0-linux-x64/bin
OTFCC_DIR=../otfcc/bin/release-x64
SET_NAME=custom-expanded
all:
	rm -f ~/.local/share/fonts/iosevka-${SET_NAME}*
	fc-cache
	PATH=${NODE_DIR}:${OTFCC_DIR}:${PATH} make custom-config set=custom-expanded design="${CUSTOM_DESIGN}"
	PATH=${NODE_DIR}:${OTFCC_DIR}:${PATH} make custom set=${SET_NAME}
	cp dist/iosevka-${SET_NAME}/ttf/iosevka-${SET_NAME}*ttf ~/.local/share/fonts
	fc-cache

start : __start

include utility/dirs.mk

# Standard
$(BUILD)/targets.mk : maker.js | $(BUILD)/
	node maker.js > $@

__start : $(BUILD)/targets.mk
	@$(MAKE) -f utility/standard.mk __default

web : $(BUILD)/targets.mk
	@$(MAKE) -f utility/standard.mk web

sans : $(BUILD)/targets.mk
	@$(MAKE) -f utility/standard.mk fonts-sans

release : $(BUILD)/targets.mk
	@$(MAKE) -f utility/standard.mk release

test : $(BUILD)/targets.mk
	@$(MAKE) -f utility/standard.mk test

fw : $(BUILD)/targets.mk
	@$(MAKE) -f utility/standard.mk archive-ttc

scripts :
	@$(MAKE) -f utility/scripts.mk scripts

sample-images :
	@$(MAKE) -f utility/standard.mk sample-images

# Custom
ifndef set
set = custom
endif
ifndef design
design = sans
endif
ifndef upright
upright = normal
endif
ifndef italic
italic = normal
endif
ifndef oblique
oblique = normal
endif
ifndef prestyle
prestyle = nothing
endif

CREATECONFIG = node maker.js --custom $(set) --design '$(design)' --upright '$(upright)' --italic '$(italic)' --oblique '$(oblique)' --prestyle '$(prestyle)' --family '$(family)' --weights '$(weights)' > $(BUILD)/targets-$(set).mk

custom-config : maker.js | $(BUILD)/
	$(CREATECONFIG)

export set
custom : $(BUILD)/targets-$(set).mk $(BUILD)/targets.mk
	@$(MAKE) -f utility/custom.mk fonts-customized-$(set) __IOSEVKA_CUSTOM_BUILD__=true
custom-web : $(BUILD)/targets-$(set).mk $(BUILD)/targets.mk
	@$(MAKE) -f utility/custom.mk web-customized-$(set) __IOSEVKA_CUSTOM_BUILD__=true

# Cleaning
clean :
	@$(MAKE) -f utility/scripts.mk cleanscripts
	@-rm -rf $(BUILD)
	@-rm -rf $(DIST)
	@-rm -rf $(ARCHIVEDIR)
