# Journey to the Center of Hawkthorne

[![Build Status](https://travis-ci.org/hawkthorne/hawkthorne-journey.png?branch=master)](https://travis-ci.org/hawkthorne/hawkthorne-journey)

This 2d platformer is based on Community's [Digital Estate Planning][estate]
episode. It's built using the [LÖVE](https://love2d.org/) game engine. Please
[report any issues or bugs][githubissues] you have with the game!

[estate]: http://en.wikipedia.org/wiki/Digital_Estate_Planning
[githubissues]: https://github.com/hawkthorne/hawkthorne-journey/issues?state=open

## Download the game

- [OS X](http://files.projecthawkthorne.com/releases/latest/hawkthorne-osx.zip)
- [Windows](http://files.projecthawkthorne.com/releases/latest/hawkthorne-win-x86.zip)

## Contribute to the game

All discussion and development takes place on
[/r/hawkthorne](http://www.reddit.com/r/hawkthorne). If you have any
contributions you'd like to submit, either open a pull request or create a post
on the subreddit. The steps below are only needed if you want to write code for
the game.

### Getting started with development on OS X / Linux

Getting start is easy. Just clone the repository and run `make run`.

```bash
$ git clone git://github.com/hawkthorne/hawkthorne-journey.git
$ cd hawkthorne-journey
$ make run
```

### Getting started with development on Windows

First, download and install [Github for Windows](http://windows.github.com/)
which will setup git on your computer. You'll also need PowerShell, which comes
pre-installed on Windows 7 & 8.

Once you've installed and logged in with Github for Windows, go to
`https://github.com/hawkthorne/hawkthorne-journey` and click the `Fork` button

After you've successfully forked the repository go to
`https://github.com/<your username>/hawkthorne-journey` and click the "Clone in
Windows" button.

Once you have the repo, click on it in Github for Windows, select "tools > open a shell here".

In your new PowerShell window, run

```powershell
> .\make.ps1 run
```
 
### Next steps

Congratulations! You're running Journey to the Center of Hawkthorne! Your next steps can be:

- Fix [bugs](https://github.com/hawkthorne/hawkthorne-journey/issues?labels=bug&state=open) with the game
- Add new features and content to the game


## Community

- [/r/hawkthorne subreddit](http://www.reddit.com/r/hawkthorne)
- [#hawkthorne@irc.freenode.net](http://webchat.freenode.net/?channels=hawkthorne) on IRC


## Releasing a new version

We release a new version of Journey to the Center of Hawkthorne about every two
weeks. To create a release, open a pull request from the `master` branch to the
`release` branch. You should never commit directly to the `release` branch.

## License

Unless otherwise noted, this code is licensed under the MIT License.

Artwork and audio files are licensed under [CC BY-NC
3.0](http://creativecommons.org/licenses/by-nc/3.0/). Artwork includes all
.png, .psd, .ogg, and .wav files.

