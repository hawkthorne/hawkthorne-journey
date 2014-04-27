.PHONY: clean contributors run productionize deploy love maps appcast lint

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
  TMXTAR = tmx2lua.osx.tar
  LOVE = bin/love.app/Contents/MacOS/love
else
  TMXTAR = tmx2lua.linux.tar
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

bin/tmx2lua:
	mkdir -p bin
	$(wget) http://hawkthorne.github.com/tmx2lua/downloads/$(TMXTAR)
	tar -xvf $(TMXTAR)
	rm -f $(TMXTAR)
	mv tmx2lua bin

bin/love.app/Contents/MacOS/love:
	mkdir -p bin
	$(wget) https://bitbucket.org/rude/love/downloads/love-0.9.0-macosx-x64.zip
	unzip -q love-0.9.0-macosx-x64.zip
	rm -f love-0.9.0-macosx-x64.zip
	mv love.app bin
	cp osx/Info.plist bin/love.app/Contents

/usr/bin/love:
	sudo add-apt-repository -y ppa:bartbes/love-stable
	sudo apt-get update -y
	sudo apt-get install -y love

######################################################
# THE REST OF THESE TARGETS ARE FOR RELEASE AUTOMATION
######################################################

CI_TARGET=test validate maps

ifeq ($(TRAVIS), true)
ifeq ($(TRAVIS_PULL_REQUEST), false)
ifeq ($(TRAVIS_BRANCH), release)
CI_TARGET=clean test validate maps productionize upload appcast social
endif
ifeq ($(TRAVIS_BRANCH), master)
CI_TARGET=clean test validate maps productionize upload
endif
endif
endif

positions: $(patsubst %.png,%.lua,$(wildcard src/positions/*.png))

src/positions/%.lua: psds/positions/%.png
	overlay2lua src/positions/config.json $<

win32/love.exe:
	$(wget) https://bitbucket.org/rude/love/downloads/love-0.9.1-win32.zip
	unzip love-0.9.1-win32.zip
	mv love-0.9.1-win32 win32
	rm -f love-0.9.1-win32.zip

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

upload: binaries venv
	venv/bin/python scripts/upload_binaries.py

appcast: venv build/hawkthorne-osx.zip win32/hawkthorne.exe
	venv/bin/python scripts/sparkle.py
	cat sparkle/appcast.json | python -m json.tool > /dev/null
	venv/bin/python scripts/upload.py / sparkle/appcast.json

social: venv post.md notes.html
	venv/bin/python scripts/upload_release_notes.py
	venv/bin/python scripts/socialize.py post.md

notes.html: post.md
	venv/bin/python -m markdown post.md > notes.html

post.md:
	venv/bin/python scripts/create_post.py post.md

venv:
	virtualenv -q --python=python2.7 venv
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
	rm -rf $(OSXAPP)

reset:
	rm -rf ~/Library/Application\ Support/LOVE/hawkthorne/*.json
	rm -rf $(XDG_DATA_HOME)/love/ ~/.local/share/love/
	rm -rf src/maps/*.lua
