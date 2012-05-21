.PHONY: love osx clean

love:
	mkdir -p build
	zip -r build/hawkthorne.love src -x ".*" -x "psds/*" \
		-x "*/full_soundtrack.ogg" -x "build/*" -x "osx/*"

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

win: love
	cat build/love-win-x86.exe build/hawkthorne.love > build/hawkthorne-x86.exe
	cat build/love-win-x64.exe build/hawkthorne.love > build/hawkthorne-x64.exe

upload: osx win
	python scripts/upload.py build/hawkthorne.love
	python scripts/upload.py build/hawkthorne-osx.zip

clean:
	rm -rf build
