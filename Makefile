.PHONY: build clean install icon

APP_NAME = Confetti
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app

icon:
	@echo "Generating app icon..."
	@swift generate_icon.swift

build: icon
	swift build -c release
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/
	cp AppIcon.icns $(APP_BUNDLE)/Contents/Resources/

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)
	rm -f AppIcon.icns
	rm -rf AppIcon.iconset

install: build
	cp -r $(APP_BUNDLE) /Applications/
