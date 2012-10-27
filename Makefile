.PHONY: love osx clean contributors win32 win64 maps tweet

current_version = $(shell python scripts/version.py current)
next_version = $(shell python scripts/version.py next)
previous_version = $(shell python scripts/version.py previous)

love: maps
	mkdir -p build
	cd src && zip -r ../build/hawkthorne.love . -x ".*" \
		-x ".DS_Store" -x "*/full_soundtrack.ogg"

maps: $(patsubst %.tmx,%.lua,$(wildcard src/maps/*.tmx))
positions: $(patsubst %.png,%.lua,$(wildcard src/positions/*.png))

src/maps/%.lua: src/maps/%.tmx
	tmx2lua $<

src/positions/%.lua: psds/positions/%.png
	overlay2lua src/positions/config.json $<

osx: love osx/love.app
	cp -r osx/love.app Journey\ to\ the\ Center\ of\ Hawkthorne.app
	cp build/hawkthorne.love Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources
	cp osx/Hawkthorne.icns Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/Love.icns
	zip -r hawkthorne-osx Journey\ to\ the\ Center\ of\ Hawkthorne.app
	mv hawkthorne-osx.zip build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

osx/love.app:
	wget --no-check-certificate https://bitbucket.org/rude/love/downloads/love-0.8.0-macosx-ub.zip
	unzip love-0.8.0-macosx-ub.zip
	rm love-0.8.0-macosx-ub.zip
	mv love.app osx

win: win32/love.exe win32 win64

win32: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x86.zip
	cat win32/love.exe build/hawkthorne.love > win32/hawkthorne.exe
	cp -r win32 hawkthorne
	zip -r hawkthorne-win-x86 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x86.zip build

win32/love.exe:
	wget --no-check-certificate https://github.com/downloads/kyleconroy/hawkthorne-journey/windows-build-files.zip
	unzip windows-build-files.zip
	rm windows-build-files.zip

win64: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x64.zip
	cat win64/love.exe build/hawkthorne.love > win64/hawkthorne.exe
	cp -r win64 hawkthorne
	zip -r hawkthorne-win-x64 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x64.zip build

upload: osx win venv
	venv/bin/python scripts/upload.py build/hawkthorne.love
	venv/bin/python scripts/upload.py build/hawkthorne-osx.zip
	venv/bin/python scripts/upload.py build/hawkthorne-win-x86.zip
	venv/bin/python scripts/upload.py build/hawkthorne-win-x64.zip
	git add stats.json
	git commit -m "Add updated download stats"
	git push origin master

tag:
	git fetch origin
	sed -i '' 's/$(current_version)/$(next_version)/g' src/conf.lua
	git add src/conf.lua
	git commit -m "Bump release version to $(next_version)"
	git tag -a $(next_version) -m "Tagged new release at version $(next_version)"
	git push origin master
	git push --tags

deploy: clean tag upload post

post: venv
	venv/bin/python scripts/release_markdown.py $(previous_version) $(current_version) release.md

tweet: venv
	venv/bin/python scripts/create_release_post.py $(current_version) release.md

venv:
	virtualenv --python=python2.7 venv
	venv/bin/pip install -r requirements.txt

contributors: venv
	venv/bin/python scripts/clean.py > CONTRIBUTORS
	venv/bin/python scripts/credits.py > src/credits.lua

test:
	cp src/main_testing.lua src/main.lua

clean:
	rm -rf build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

reset:
	rm -rf ~/Library/Application\ Support/LOVE/hawkthorne/gamesave-*.json
	rm -rf $(XDG_DATA_HOME)/love/ ~/.local/share/love/
