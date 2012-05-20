.PHONY: love osx clean

love:
	mkdir -p build
	zip -r build/hawkthorne.love . -x ".*" -x "psds/*" \
		-x audio/full_soundtrack.ogg -x "build/*"

osx: love
	cp -r /Applications/love.app hawkthorne.app
	cp build/hawkthorne.love hawkthorne.app/Contents/Resources
	zip -r hawkthorne-osx hawkthorne.app
	mv hawkthorne-osx.zip build
	rm -rf hawkthorne.app

clean:
	rm -rf build
