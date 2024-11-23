.PHONY: clean contributors validate run maps lint build/hawkthorne.love love love.js

UNAME := $(shell uname)
TILEMAPS := $(patsubst %.tmx,%.lua,$(wildcard src/maps/*.tmx))
LOVE_DOWNLOAD_URL = https://github.com/love2d/love/releases/download
LOVE_VERSION = 11.5
MACOS_APP=build/Journey\ to\ the\ Center\ of\ Hawkthorne.app

ifeq ($(UNAME), Darwin)
	TMXTAR = tmx2lua.osx.zip
	LOVE = bin/love.app/Contents/MacOS/love
	# macOS cannot create a Linux AppImage
	BINARIES = build/hawkthorne-macos.zip build/hawkthorne-win32.zip build/hawkthorne-win64.zip
else
	TMXTAR = tmx2lua.linux.tar.gz
	LOVE = bin/love.AppImage
	BINARIES = build/hawkthorne-macos.zip build/hawkthorne-win32.zip build/hawkthorne-win64.zip build/hawkthorne-linux.AppImage
endif

ifeq ($(shell which wget),)
	WGET = curl -s -O -L
else
	WGET = wget -q --no-check-certificate
endif

maps: $(TILEMAPS)

love: build/hawkthorne.love

love.js: build/hawkthorne.love
	mkdir -p build/web
	npm install
	npx love.js -t "Journey to the Center of Hawkthorne" -m 77594624 -c build/hawkthorne.love build/web
	######## Temporary LÖVE v11.5 until new version is published on NPM ########
	$(WGET) https://github.com/Davidobot/love.js/raw/refs/heads/master/src/compat/love.js
	$(WGET) https://github.com/Davidobot/love.js/raw/refs/heads/master/src/compat/love.wasm
	mv love.js build/web/
	mv love.wasm build/web/
	################################### END ####################################
	cp templates/web/* build/web/

build/hawkthorne.love: $(TILEMAPS) src/*
	mkdir -p build
	rm -f build/hawkthorne.love
	cd src && zip --symlinks -q -r ../build/hawkthorne.love . \
		-x ".*" \
		-x "*.DS_Store" \
		-x "psds/*" \
		-x "test/*" \
		-x "*.tmx" \
		-x "maps/test-level.lua" \
		-x "*/full_soundtrack.ogg" \
		-x "*.bak"

run: $(TILEMAPS) $(LOVE)
	$(LOVE) src

src/maps/%.lua: src/maps/%.tmx bin/tmx2lua
	bin/tmx2lua $<

# tmx2lua requires golang to be installed.
# If you need to install it on macOS:
# brew update && brew install golang
bin/tmx2lua:
	mkdir -p bin
	$(WGET) https://github.com/hawkthorne/tmx2lua/releases/download/v1.0.1/$(TMXTAR)
ifeq ($(UNAME), Darwin)
	unzip -q $(TMXTAR)
else
	tar -xzvf $(TMXTAR)
endif
	rm -f $(TMXTAR) ._tmx2lua
	mv tmx2lua bin

bin/win32/love.exe:
	$(WGET) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-win32.zip
	unzip -q love-$(LOVE_VERSION)-win32.zip
	mv love-$(LOVE_VERSION)-win32 bin/win32
	rm -f love-$(LOVE_VERSION)-win32.zip
	rm bin/win32/changes.txt bin/win32/game.ico bin/win32/love.ico bin/win32/readme.txt

bin/win64/love.exe:
	$(WGET) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-win64.zip
	unzip -q love-$(LOVE_VERSION)-win64.zip
	mv love-$(LOVE_VERSION)-win64 bin/win64
	rm -f love-$(LOVE_VERSION)-win64.zip
	rm bin/win64/changes.txt bin/win64/game.ico bin/win64/love.ico bin/win64/readme.txt

bin/love.app/Contents/MacOS/love:
	mkdir -p bin
	$(WGET) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-macos.zip
	unzip -q love-$(LOVE_VERSION)-macos.zip
	rm -f love-$(LOVE_VERSION)-macos.zip
	mv love.app bin

bin/love.AppImage:
	mkdir -p bin
	$(WGET) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-x86_64.AppImage
	mv love-$(LOVE_VERSION)-x86_64.AppImage bin/love.AppImage
	chmod a+x bin/love.AppImage

bin/appimagetool.AppImage:
	mkdir -p bin
	$(WGET) https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
	mv appimagetool-x86_64.AppImage bin/appimagetool.AppImage
	chmod a+x bin/appimagetool.AppImage

build/win32/hawkthorne.exe: build/hawkthorne.love bin/win32/love.exe
	mkdir -p build/win32
	cat bin/win32/love.exe build/hawkthorne.love > build/win32/hawkthorne.exe

build/win64/hawkthorne.exe: build/hawkthorne.love bin/win64/love.exe
	mkdir -p build/win64
	cat bin/win64/love.exe build/hawkthorne.love > build/win64/hawkthorne.exe

build/hawkthorne-win32.zip: build/win32/hawkthorne.exe
	cp -R bin/win32/* build/win32/
	zip --symlinks -q -r hawkthorne-win32 build/win32/ -x "*/love*.exe"
	mv hawkthorne-win32.zip build

build/hawkthorne-win64.zip: build/win64/hawkthorne.exe
	cp -R bin/win64/* build/win64/
	zip --symlinks -q -r hawkthorne-win64 build/win64/ -x "*/love*.exe"
	mv hawkthorne-win64.zip build

$(MACOS_APP): build/hawkthorne.love bin/love.app/Contents/MacOS/love
	cp -R bin/love.app $(MACOS_APP)
	cp build/hawkthorne.love $(MACOS_APP)/Contents/Resources/hawkthorne.love
	cp templates/macos/Info.plist $(MACOS_APP)/Contents/Info.plist
	cp templates/macos/Hawkthorne.icns $(MACOS_APP)/Contents/Resources/GameIcon.icns

build/hawkthorne-macos.zip: $(MACOS_APP)
	mkdir -p build
	zip --symlinks -q -r hawkthorne-macos $(MACOS_APP)
	mv hawkthorne-macos.zip build

build/hawkthorne-linux.AppImage: build/hawkthorne.love bin/love.AppImage bin/appimagetool.AppImage
	mkdir -p build/linux
	bin/love.AppImage --appimage-extract
	mv squashfs-root build/linux/
	cat build/linux/squashfs-root/bin/love build/hawkthorne.love > build/linux/squashfs-root/bin/hawkthorne
	chmod a+x build/linux/squashfs-root/bin/hawkthorne
	cp templates/linux/* build/linux/squashfs-root/
	rm build/linux/squashfs-root/bin/love build/linux/squashfs-root/love.svg
	./bin/appimagetool.AppImage build/linux/squashfs-root build/hawkthorne-linux.AppImage
	chmod a+x build/hawkthorne-linux.AppImage

binaries: $(BINARIES)

venv:
	python3 -m venv venv
	venv/bin/pip install -q -r requirements.txt

contributors: venv
	venv/bin/python scripts/credits.py > src/credits.lua

test: $(LOVE) maps
	$(LOVE) src --test

validate: venv lint
	venv/bin/python scripts/validate.py src

lint:
	touch src/maps/init.lua
	find src -name "*.lua" | grep -v "src/vendor" | grep -v "src/test" | \
		xargs -I {} ./scripts/lualint.lua -r "{}"

clean:
	rm -rf bin/
	rm -rf build/
	rm -rf venv/
	rm -rf node_modules/
	rm -rf scripts/*.pyc
	rm -rf src/maps/*.lua
