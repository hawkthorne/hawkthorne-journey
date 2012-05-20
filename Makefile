.PHONY: love osx clean

love:
	mkdir -p build
	zip -r build/hawkthorne.love src -x ".*" -x "psds/*" \
		-x "*/full_soundtrack.ogg" -x "build/*" -x "osx/*"

osx: love
	cp -r /Applications/love.app Journey\ to\ the\ Center\ of\ Hawkthorne.app
	cp build/hawkthorne.love Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources
	cp osx/Hawkthorne.icns Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/Love.icns
	zip -r hawkthorne-osx Journey\ to\ the\ Center\ of\ Hawkthorne.app
	mv hawkthorne-osx.zip build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

upload: osx
	python scripts/upload.py build/hawkthorne.love
	python scripts/upload.py build/hawkthorne-osx.zip

clean:
	rm -rf build
