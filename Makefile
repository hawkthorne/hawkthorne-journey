.PHONY: clean contributors run productionize deploy love maps appcast lint

UNAME := $(shell uname)

LOVE2D_DOWNLOAD_URL = https://github.com/love2d/love/releases/download
LOVE2D_VERSION = 0.10.1

ifeq ($(UNAME), Darwin)
  TMXDIR = osx
  LOVE = bin/love.app/Contents/MacOS/love
else
  TMXDIR = linux
  LOVE = /usr/bin/love
endif

ifeq ($(shell which wget),)
  wget = curl -s -O -L
else
  wget = wget -q --no-check-certificate
endif

tilemaps := $(patsubst %.tmx,%.lua,$(wildcard src/maps/*.tmx))

maps: $(tilemaps)

love: build/hawkthorne.love

build/hawkthorne.love: $(tilemaps) src/*
	mkdir -p build
	cd src && zip --symlinks -q -r ../build/hawkthorne.love . -x ".*" \
		-x ".DS_Store" -x "*/full_soundtrack.ogg" -x "*.bak"

run: $(tilemaps) $(LOVE)
	$(LOVE) src

src/maps/%.lua: src/maps/%.tmx bin/tmx2lua
	bin/tmx2lua $<

# tmx2lua requires golang to be installed.
# If you need to install it on OSX:
# brew update && brew install golang
bin/tmx2lua:
	mkdir -p bin
	git clone https://github.com/hawkthorne/tmx2lua bin/tmx2lua-git
	cd bin/tmx2lua-git; go mod init .git/config
	cd bin/tmx2lua-git; go get github.com/kyleconroy/go-tmx/tmx
	cd bin/tmx2lua-git; make
	mv bin/tmx2lua-git/$(TMXDIR)/tmx2lua bin
	rm -rf bin/tmx2lua-git

bin/love.app/Contents/MacOS/love:
	mkdir -p bin
	$(wget) $(LOVE2D_DOWNLOAD_URL)/$(LOVE2D_VERSION)/love-$(LOVE2D_VERSION)-macosx-x64.zip
	unzip -q love-$(LOVE2D_VERSION)-macosx-x64.zip
	rm -f love-$(LOVE2D_VERSION)-macosx-x64.zip
	mv love.app bin
	cp osx/Info.plist bin/love.app/Contents

/usr/bin/love:
	sudo add-apt-repository -y ppa:bartbes/love-stable
	sudo apt-get update -y -f
	sudo apt-get install -y love

######################################################
# THE REST OF THESE TARGETS ARE FOR RELEASE AUTOMATION
######################################################

CI_TARGET=test validate maps productionize binaries

ifeq ($(TRAVIS), true)
ifeq ($(TRAVIS_PULL_REQUEST), false)
ifeq ($(TRAVIS_BRANCH), release)
CI_TARGET=clean test validate maps productionize social
endif
endif
endif

positions: $(patsubst %.png,%.lua,$(wildcard src/positions/*.png))

src/positions/%.lua: psds/positions/%.png
	overlay2lua src/positions/config.json $<

win32/love.exe:
	$(wget) $(LOVE2D_DOWNLOAD_URL)/$(LOVE2D_VERSION)/love-$(LOVE2D_VERSION)-win32.zip
	unzip -q love-$(LOVE2D_VERSION)-win32.zip
	mv love-$(LOVE2D_VERSION)-win32 win32
	rm -f love-$(LOVE2D_VERSION)-win32.zip
	rm win32/changes.txt win32/game.ico win32/license.txt win32/love.ico win32/readme.txt

win32/hawkthorne.exe: build/hawkthorne.love win32/love.exe
	cat win32/love.exe build/hawkthorne.love > win32/hawkthorne.exe

build/hawkthorne-win-x86.zip: win32/hawkthorne.exe
	mkdir -p build
	rm -rf hawkthorne
	rm -f hawkthorne-win-x86.zip
	cp -r win32 hawkthorne
	zip --symlinks -q -r hawkthorne-win-x86 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x86.zip build

OSXAPP=Journey\ to\ the\ Center\ of\ Hawkthorne.app

$(OSXAPP): build/hawkthorne.love bin/love.app/Contents/MacOS/love
	cp -R bin/love.app $(OSXAPP)
	cp build/hawkthorne.love $(OSXAPP)/Contents/Resources/hawkthorne.love
	cp osx/Info.plist $(OSXAPP)/Contents/Info.plist
	cp osx/Hawkthorne.icns $(OSXAPP)/Contents/Resources/Love.icns

build/hawkthorne-osx.zip: $(OSXAPP)
	mkdir -p build
	zip --symlinks -q -r hawkthorne-osx $(OSXAPP)
	mv hawkthorne-osx.zip build

productionize: venv
	venv/bin/python scripts/productionize.py

binaries: build/hawkthorne-osx.zip build/hawkthorne-win-x86.zip

upload: binaries post.md venv
	venv/bin/python scripts/release.py

appcast: venv build/hawkthorne-osx.zip win32/hawkthorne.exe
	venv/bin/python scripts/sparkle.py
	cat sparkle/appcast.json | python -m json.tool > /dev/null
	venv/bin/python scripts/upload.py / sparkle/appcast.json

social: venv notes.html post.md
	venv/bin/python scripts/socialize.py post.md

notes.html: post.md
	venv/bin/python -m markdown post.md > notes.html

post.md:
	venv/bin/python scripts/create_post.py post.md

venv:
	virtualenv -q --python=python3.6 venv
	venv/bin/pip install -q -r requirements.txt

deploy: $(CI_TARGET)

contributors: venv
	venv/bin/python scripts/clean.py > CONTRIBUTORS
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
	rm -rf build
	rm -f release.md
	rm -f post.md
	rm -f notes.html
	rm -rf src/maps/*.lua
	rm -rf bin/tmx2lua-git
	rm -rf $(OSXAPP)

reset:
	rm -rf ~/Library/Application\ Support/LOVE/hawkthorne/*.json
	rm -rf $(XDG_DATA_HOME)/love/ ~/.local/share/love/
	rm -rf src/maps/*.lua
