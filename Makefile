.PHONY: love osx clean

love:
	mkdir -p build
	cd src && zip -r ../build/hawkthorne.love . -x ".*" \
		-x ".DS_Store" -x "*/full_soundtrack.ogg"

download:
	curl -L https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x86.exe > build/love-win-x86.exe
	curl -L https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x64.exe > build/love-win-x64.exe


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

clean:
	rm -rf build
