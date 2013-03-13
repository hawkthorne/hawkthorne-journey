.PHONY: love osx clean contributors win32 win64 maps tweet post run

UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
  TMXTAR = tmx2lua.osx.tar
  LOVE = bin/love.app/Contents/MacOS/love
else
  TMXTAR = tmx2lua.linux.tar
  LOVE = /usr/bin/love
endif

ifeq ($(shell which wget),)
  wget = curl -O -L
else
  wget = wget --no-check-certificate
endif

mixpanel_dev = ac1c2db50f1332444fd0cafffd7a5543

ifndef MIXPANEL_TOKEN
    mixpanel_prod = $(mixpanel_dev)
else
    mixpanel_prod = $(MIXPANEL_TOKEN)
endif



love: maps build
	@sed -i.bak 's/$(mixpanel_dev)/$(mixpanel_prod)/g' src/main.lua
	cd src && zip -q -r ../build/hawkthorne.love . -x ".*" \
		-x ".DS_Store" -x "*/full_soundtrack.ogg" -x "main.lua.bak"
	mv src/main.lua.bak src/main.lua

build:
	mkdir -p build

run: maps $(LOVE)
	$(LOVE) src

maps: $(patsubst %.tmx,%.lua,$(wildcard src/maps/*.tmx))

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
	$(wget) https://bitbucket.org/kyleconroy/love/downloads/love-sparkle.zip
	unzip -q love-sparkle.zip
	rm -f love-sparkle.zip
	mv love.app bin
	cp osx/dsa_pub.pem bin/love.app/Contents/Resources
	cp osx/Info.plist bin/love.app/Contents

/usr/bin/love:
	sudo add-apt-repository ppa:bartbes/love-stable
	sudo apt-get update
	sudo apt-get install love

######################################################
# THE REST OF THESE TARGETS ARE FOR RELEASE AUTOMATION
######################################################

current_version = $(shell python scripts/version.py current)
sparkle_version = $(shell python scripts/version.py current --sparkle)
next_version = $(shell python scripts/version.py next)
previous_version = $(shell python scripts/version.py previous)

CI_TARGET=test

ifeq ($(TRAVIS), true)
ifeq ($(TRAVIS_BRANCH), master)
ifeq ($(TRAVIS_PULL_REQUEST), false)
ifeq ($(shell python scripts/bump.py), true)
CI_TARGET=clean test upload social
endif
endif
endif
endif

positions: $(patsubst %.png,%.lua,$(wildcard src/positions/*.png))

src/positions/%.lua: psds/positions/%.png
	overlay2lua src/positions/config.json $<

win: win32/love.exe win32 win64

win32: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x86.zip
	cat win32/love.exe build/hawkthorne.love > win32/hawkthorne.exe
	cp -r win32 hawkthorne
	zip -q -r hawkthorne-win-x86 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x86.zip build

win32/love.exe:
	$(wget) https://bitbucket.org/kyleconroy/love/downloads/windows-build-files.zip
	unzip -q windows-build-files.zip
	rm -f windows-build-files.zip

win64: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x64.zip
	cat win64/love.exe build/hawkthorne.love > win64/hawkthorne.exe
	cp -r win64 hawkthorne
	zip -q -r hawkthorne-win-x64 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x64.zip build

osx: maps bin/love.app/Contents/MacOS/love build
	cp -r bin/love.app Journey\ to\ the\ Center\ of\ Hawkthorne.app
	sed -i.bak 's/0.0.1/$(sparkle_version)/g' \
		Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Info.plist
	@sed -i.bak 's/$(mixpanel_dev)/$(mixpanel_prod)/g' src/main.lua
	cp -r src Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/hawkthorne.love
	rm -f Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/hawkthorne.love/.DS_Store
	find Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents -name "*.bak" -delete
	mv src/main.lua.bak src/main.lua
	cp osx/Hawkthorne.icns \
		Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/Love.icns
	zip -q -r hawkthorne-osx Journey\ to\ the\ Center\ of\ Hawkthorne.app
	mv hawkthorne-osx.zip build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

upload: osx win venv
	venv/bin/python scripts/upload.py releases/$(current_version) build/hawkthorne.love
	venv/bin/python scripts/upload.py releases/$(current_version) build/hawkthorne-osx.zip
	venv/bin/python scripts/upload.py releases/$(current_version) build/hawkthorne-win-x86.zip
	venv/bin/python scripts/upload.py releases/$(current_version) build/hawkthorne-win-x64.zip
	venv/bin/python scripts/symlink.py $(current_version)

deltas:
	venv/bin/python scripts/sparkle.py
	cat sparkle/appcast.xml | xmllint -format - # Make sure the appcast is valid xml
	venv/bin/python scripts/upload.py / sparkle/appcast.xml

release: release.md
	git fetch origin
	git fetch --tags
	sed -i '' 's/$(current_version)/$(next_version)/g' src/conf.lua
	git add src/conf.lua
	git commit -eF release.md
	git push origin master
	git tag -a $(next_version) -m "Tagged new release at version $(next_version)"
	git push --tags

release.md: venv
	venv/bin/python scripts/release_markdown.py $(current_version) master $@

social: venv notes post
	venv/bin/python scripts/create_release_post.py $(current_version) post.md

notes: notes.html post
	venv/bin/python scripts/upload.py releases/$(current_version) notes.html
	
notes.html: post
	venv/bin/python -m markdown post.md > notes.html

post:
	git show -s --format=%s $(current_version)^{commit} > $@.md
	echo "\n" >> $@.md
	git show -s --format=%b $(current_version)^{commit} >> $@.md

venv:
	virtualenv --python=python2.7 venv
	venv/bin/pip install -r requirements.txt

deploy: $(CI_TARGET)

contributors: venv
	venv/bin/python scripts/clean.py > CONTRIBUTORS
	venv/bin/python scripts/credits.py > src/credits.lua

test:
	busted spec

clean:
	rm -rf build
	rm -f release.md
	rm -f post.md
	rm -f notes.html
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

reset:
	rm -rf ~/Library/Application\ Support/LOVE/hawkthorne/gamesave-*.json
	rm -rf $(XDG_DATA_HOME)/love/ ~/.local/share/love/
	rm -rf src/maps/*.lua
