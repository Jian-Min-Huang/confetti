.PHONY: build clean install

APP_NAME = Confetti
BUILD_DIR = .build/release
APP_BUNDLE = $(APP_NAME).app

build:
	swift build -c release
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/

clean:
	swift package clean
	rm -rf $(APP_BUNDLE)

install: build
	cp -r $(APP_BUNDLE) /Applications/
