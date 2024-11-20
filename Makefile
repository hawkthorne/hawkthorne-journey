.PHONY: clean contributors run productionize deploy love maps lint

UNAME := $(shell uname)

LOVE_DOWNLOAD_URL = https://github.com/love2d/love/releases/download
LOVE_VERSION = 11.5

ifeq ($(UNAME), Darwin)
  TMXTAR = tmx2lua.osx.zip
  LOVE = bin/love.app/Contents/MacOS/love
else
  TMXTAR = tmx2lua.linux.tar.gz
  LOVE = bin/love.AppImage
endif

ifeq ($(shell which wget),)
  wget = curl -s -O -L
else
  wget = wget -q --no-check-certificate
endif

tilemaps := $(patsubst %.tmx,%.lua,$(wildcard src/maps/*.tmx))

maps: $(tilemaps)

love: build/hawkthorne.love

love.js: build/hawkthorne.love
	mkdir -p build/web
	npm install
	npx love.js -t "Journey to the Center of Hawkthorne" -m 77594624 -c build/hawkthorne.love build/web
	cp templates/web/* build/web/

build/hawkthorne.love: $(tilemaps) src/*
	mkdir -p build
	cd src && zip --symlinks -q -r ../build/hawkthorne.love . \
		-x ".*" \
		-x "*.DS_Store" \
		-x "psds/*" \
		-x "test/*" \
		-x "*.tmx" \
		-x "maps/test-level.lua" \
		-x "*/full_soundtrack.ogg" \
		-x "*.bak"

run: $(tilemaps) $(LOVE)
	$(LOVE) src

src/maps/%.lua: src/maps/%.tmx bin/tmx2lua
	bin/tmx2lua $<

# tmx2lua requires golang to be installed.
# If you need to install it on macOS:
# brew update && brew install golang
bin/tmx2lua:
	mkdir -p bin
	$(wget) https://github.com/hawkthorne/tmx2lua/releases/download/v1.0.1/$(TMXTAR)
ifeq ($(UNAME), Darwin)
	unzip -q $(TMXTAR)
else
	tar -xzvf $(TMXTAR)
endif
	rm -f $(TMXTAR)
	mv tmx2lua bin

bin/win32/love.exe:
	$(wget) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-win32.zip
	unzip -q love-$(LOVE_VERSION)-win32.zip
	mv love-$(LOVE_VERSION)-win32 bin/win32
	rm -f love-$(LOVE_VERSION)-win32.zip
	rm bin/win32/changes.txt bin/win32/game.ico bin/win32/love.ico bin/win32/readme.txt

bin/win64/love.exe:
	$(wget) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-win64.zip
	unzip -q love-$(LOVE_VERSION)-win64.zip
	mv love-$(LOVE_VERSION)-win64 bin/win64
	rm -f love-$(LOVE_VERSION)-win64.zip
	rm bin/win64/changes.txt bin/win64/game.ico bin/win64/love.ico bin/win64/readme.txt

bin/love.app/Contents/MacOS/love:
	mkdir -p bin
	$(wget) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-macos.zip
	unzip -q love-$(LOVE_VERSION)-macos.zip
	rm -f love-$(LOVE_VERSION)-macos.zip
	mv love.app bin
	cp templates/macos/Info.plist bin/love.app/Contents

bin/love.AppImage:
	mkdir -p bin
	$(wget) $(LOVE_DOWNLOAD_URL)/$(LOVE_VERSION)/love-$(LOVE_VERSION)-x86_64.AppImage
	mv love-$(LOVE_VERSION)-x86_64.AppImage bin/love.AppImage
	chmod +x bin/love.AppImage

######################################################
# THE REST OF THESE TARGETS ARE FOR RELEASE AUTOMATION
######################################################

CI_TARGET=test validate maps productionize binaries

# ifeq ($(TRAVIS), true)
# ifeq ($(TRAVIS_PULL_REQUEST), false)
# ifeq ($(TRAVIS_BRANCH), release)
# CI_TARGET=clean test validate maps productionize
# endif
# endif
# endif

deploy: $(CI_TARGET)

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

MACOS_APP=build/Journey\ to\ the\ Center\ of\ Hawkthorne.app

$(MACOS_APP): build/hawkthorne.love bin/love.app/Contents/MacOS/love
	cp -R bin/love.app $(MACOS_APP)
	cp build/hawkthorne.love $(MACOS_APP)/Contents/Resources/hawkthorne.love
	cp templates/macos/Info.plist $(MACOS_APP)/Contents/Info.plist
	cp templates/macos/Hawkthorne.icns $(MACOS_APP)/Contents/Resources/Love.icns

build/hawkthorne-macos.zip: $(MACOS_APP)
	mkdir -p build
	zip --symlinks -q -r hawkthorne-macos $(MACOS_APP)
	mv hawkthorne-macos.zip build

productionize: venv
	venv/bin/python scripts/productionize.py

binaries: build/hawkthorne-macos.zip build/hawkthorne-win32.zip build/hawkthorne-win64.zip

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
	rm -rf bin
	rm -rf build
	rm -rf src/maps/*.lua
