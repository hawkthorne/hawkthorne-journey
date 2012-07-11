.PHONY: love osx clean contributors

current_version = $(shell python scripts/version.py current)
next_version = $(shell python scripts/version.py next)
previous_version = $(shell python scripts/version.py previous)

love:
	mkdir -p build
	cd src && zip -r ../build/hawkthorne.love . -x ".*" \
		-x ".DS_Store" -x "*/full_soundtrack.ogg"

osx: love
	cp -r /Applications/love.app Journey\ to\ the\ Center\ of\ Hawkthorne.app
	cp build/hawkthorne.love Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources
	cp osx/Hawkthorne.icns Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/Love.icns
	zip -r hawkthorne-osx Journey\ to\ the\ Center\ of\ Hawkthorne.app
	mv hawkthorne-osx.zip build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

win: win32 win64


win32: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x86.zip
	cat win32/love.exe build/hawkthorne.love > win32/hawkthorne.exe
	cp -r win32 hawkthorne
	zip -r hawkthorne-win-x86 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x86.zip build

win64: love
	rm -rf hawkthorne
	rm -f hawkthorne-win-x64.zip
	cat win64/love.exe build/hawkthorne.love > win64/hawkthorne.exe
	cp -r win64 hawkthorne
	zip -r hawkthorne-win-x64 hawkthorne -x "*/love.exe"
	mv hawkthorne-win-x64.zip build

upload: osx win
	python scripts/upload.py build/hawkthorne.love
	python scripts/upload.py build/hawkthorne-osx.zip
	python scripts/upload.py build/hawkthorne-win-x86.zip
	python scripts/upload.py build/hawkthorne-win-x64.zip

tag:
	sed -i '' 's/$(current_version)/$(next_version)/g' src/conf.lua
	git add src/conf.lua
	git commit -m "Bump release version to $(next_version)"
	git tag -a $(next_version) -m "Tagged new release at version $(next_version)"
	git push origin master
	git push --tags

deploy: tag upload post

post:
	python scripts/post.py $(previous_version) $(current_version)

contributors:
	python scripts/clean.py > CONTRIBUTORS
	python scripts/credits.py > src/credits.lua

clean:
	rm -rf build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app
