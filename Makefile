.PHONY: love osx clean

love:
	mkdir -p build
	zip -r build/hawkthorne.love . -x ".*" -x "psds/*" \
		-x audio/full_soundtrack.ogg -x "build/*" -x "osx/*"

osx: love
	cp -r /Applications/love.app Journey\ to\ the\ Center\ of\ Hawkthorne.app
	cp build/hawkthorne.love Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources
	cp osx/Hawkthorne.icns Journey\ to\ the\ Center\ of\ Hawkthorne.app/Contents/Resources/Love.icns
	zip -r hawkthorne-osx Journey\ to\ the\ Center\ of\ Hawkthorne.app
	mv hawkthorne-osx.zip build
	rm -rf Journey\ to\ the\ Center\ of\ Hawkthorne.app

clean:
	rm -rf build
