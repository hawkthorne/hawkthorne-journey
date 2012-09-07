# Journey to the Center of Hawkthorne

This 2d platformer is based on Community's [Digital Estate Planning][estate]
episode. It's built using the [LÖVE](https://love2d.org/) game engine. Please
[report any issues or bugs][githubissues] you have with the game!

[estate]: http://en.wikipedia.org/wiki/Digital_Estate_Planning
[githubissues]: https://github.com/kyleconroy/hawkthorne-journey/issues?state=open

## Downloads ( play the game )
 
- [OS X][osx]
- [Windows 32-bit][win32]
- [Windows 64-bit][win64]

If you already have love installed, you can download the
[hawkthorne.love][love] file and run the game from there.

Linux users: Install [LÖVE](https://love2d.org/). You'll need at least version
0.8.0.  (Standard Ubuntu packages are too old.) After installing LÖVE, download
the [.love file][love] and run it. Everyone gets to play!

[love]: https://github.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne.love
[osx]:  https://github.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne-osx.zip
[win32]:  https://github.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne-win-x86.zip
[win64]:  https://github.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne-win-x64.zip

## Development ( contribute to the game )

All discussion and development takes place on
[/r/hawkthorne](http://www.reddit.com/r/hawkthorne). If you have any
contributions you'd like to submit, either open a pull request or create a post
on the subreddit.

### Getting your build up and running

1. Create a free GitHub account - https://github.com/plans
2. Set up Git on your machine - https://help.github.com/articles/set-up-git
3. Fork this repository ( click the 'fork' button at the top of this page )
4. Follow the machine specific instructions below

#### OSX

1. Be sure to complete the steps above to get started
2. Install the most recent version of LÖVE - http://love2d.org
2. Open Terminal
3. Make a command line alias to love

		$ alias love='/Applications/love.app/Contents/MacOS/love'

4. Add the alias to ~/.bash_profile so it works the next time you reboot

		$ echo alias love='/Applications/love.app/Contents/MacOS/love' >> ~/.bash_profile

5. Download and install the latest version of tmx2lua

		$ curl -OL https://github.com/downloads/kyleconroy/tmx2lua/tmx2lua.osx.tar.gz
		$ tar -xzf tmx2lua.osx.tar.gz
		$ sudo cp tmx2lua/tmx2lua /usr/local/bin/tmx2lua

7. Clone your newly forked repository and change directory

		$ git clone https://github.com/username/hawkthorne-journey.git
		$ cd hawkthorne-journey

8. Build your maps ( this must be done each time you change a map )

		$ make maps

9. Run the game

		$ love src

	If you are testing a specific level, you can optionally pass that level name using the --level option

		$ love src --level=valley

	You can also test a specific level as a specific character

		$ love src --level=valley --character=troy

#### Linux

1. Be sure to complete the steps above to get started
2. Install the most recent version of LÖVE - http://love2d.org

	NOTE: Many package managers have a very old version of love. Make sure that you have at least v0.8.0 or the game will not launch

3. Open Terminal
4. Download the latest version of tmx2lua

	Linux 64-bit:
	
		$ wget https://github.com/downloads/kyleconroy/tmx2lua/tmx2lua.linux64.tar.gz
	
	Linux 32-bit:
	
		$ wget https://github.com/downloads/kyleconroy/tmx2lua/tmx2lua.linux.tar.gz

5. Install tmx2lua

		$ tar -xzf tmx2lua.osx.tar.gz
		$ sudo cp tmx2lua/tmx2lua /usr/local/bin/tmx2lua

6. Clone your newly forked repository and change directory

		$ git clone https://github.com/username/hawkthorne-journey.git
		$ cd hawkthorne-journey

7. Build your maps ( this must be done each time you change a map )

		$ make maps

8. Run the game

		$ love src

	If you are testing a specific level, you can optionally pass that level name using the --level option

		$ love src --level=valley

	You can also test a specific level as a specific character

		$ love src --level=valley --character=troy


#### Windows

COMING SOON

## License

Unless otherwise noted, this code is licensed under the MIT License.

Artwork and audio files are licensed under [CC BY-NC
3.0](http://creativecommons.org/licenses/by-nc/3.0/). Artwork includes all
.png, .psd, .ogg, and .wav files.

