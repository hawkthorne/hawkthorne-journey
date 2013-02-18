.PHONY: love osx clean contributors win32 win64 maps tweet

current_version = $(shell python scripts/version.py current)
sparkle_version = $(shell python scripts/version.py current --sparkle)
next_version = $(shell python scripts/version.py next)
previous_version = $(shell python scripts/version.py previous)
mixpanel_dev = ac1c2db50f1332444fd0cafffd7a5543

ifndef MIXPANEL_TOKEN
    mixpanel_prod = $(mixpanel_dev)
else
    mixpanel_prod = $(MIXPANEL_TOKEN)
endif

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

love: maps
	mkdir -p build
	@sed -i.bak 's/$(mixpanel_dev)/$(mixpanel_prod)/g' src/main.lua
	cd src && zip -q -r ../build/hawkthorne.love . -x ".*" \
		-x ".DS_Store" -x "*/full_soundtrack.ogg" -x "main.lua.bak"
	mv src/main.lua.bak src/main.lua

maps: $(patsubst %.tmx,%.lua,$(wildcard src/maps/*.tmx))
positions: $(patsubst %.png,%.lua,$(wildcard src/positions/*.png))

src/maps/%.lua: src/maps/%.tmx bin/tmx2lua
	bin/tmx2lua $<

src/positions/%.lua: psds/positions/%.png
	overlay2lua src/positions/config.json $<

bin/tmx2lua:
	mkdir -p bin
	wget --no-check-certificate https://github.com/downloads/kyleconroy/tmx2lua/tmx2lua.linux64.tar
	tar -xvf tmx2lua.linux64.tar
	rm -f tmx2lua.linux64.tar
	mv tmx2lua bin

bin/love.app:
	mkdir -p bin
	wget --no-check-certificate https://bitbucket.org/kyleconroy/love/downloads/love-sparkle.zip
	unzip -q love-sparkle.zip
	rm love-sparkle.zip
	mv love.app bin
	cp osx/dsa_pub.pem bin/love.app/Contents/Resources
	cp osx/Info.plist bin/love.app/Contents


win: win32/love.exe win32 win64

win32: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x86.zip
	cat win32/love.exe build/hawkthorne.love > win32/hawkthorne.exe
	cp -r win32 hawkthorne
	zip -q -r hawkthorne-win-x86 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x86.zip build

win32/love.exe:
	wget --no-check-certificate https://github.com/downloads/kyleconroy/hawkthorne-journey/windows-build-files.zip
	unzip -q windows-build-files.zip
	rm windows-build-files.zip

win64: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x64.zip
	cat win64/love.exe build/hawkthorne.love > win64/hawkthorne.exe
	cp -r win64 hawkthorne
	zip -q -r hawkthorne-win-x64 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x64.zip build

osx: maps bin/love.app
	cp -r bin/love.app Journey\ to\ the\ Center\ of\ Hawkthorne.app
	sed -i.bak 's/0.0.1/$(sparkle_version)/g' \
		Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Info.plist
	@sed -i.bak 's/$(mixpanel_dev)/$(mixpanel_prod)/g' src/main.lua
	cp -r src Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/hawkthorne.love
	rm Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/hawkthorne.love/.DS_Store
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
	python scripts/sparkle.py
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

social: venv notes post.md
	venv/bin/python scripts/create_release_post.py $(current_version) post.md

notes: notes.html post.md
	venv/bin/python scripts/upload.py releases/$(current_version) notes.html
	
notes.html: post.md
	venv/bin/python -m markdown post.md > notes.html

post.md:
	git log -1 --pretty='format:%s' HEAD > $@
	echo "\n" >> $@
	git log -1 --pretty='format:%b' HEAD >> $@

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
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

reset:
	rm -rf ~/Library/Application\ Support/LOVE/hawkthorne/gamesave-*.json
	rm -rf $(XDG_DATA_HOME)/love/ ~/.local/share/love/
	rm -rf src/maps/*.lua
