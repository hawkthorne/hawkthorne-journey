# Contributing to Journey to the Center of Hawkthorne
## What the heck to work on

You're looking to help? Great, we're looking for help! You can help out in
variety of ways.

- Code new game features
- Record music and sound effects
- Draw sprites and tile sets
- Create new costumes and characters
- Play test the game and find bugs

## Music and sound effects

We always need help with new sounds. Take a look at the [list of needed music
and sound effects][audio] and pick an item to work on. Make sure to comment on
the issue once you've decided to work on it. Once you're finished, post a link
to your completed audio file in the issue and we'll get it into the game.

Please submit your audio files as uncompressed wavs. While hosting isn't
important, we like to use [Sound Cloud](http://soundcloud.com).

[audio]: https://github.com/hawkthorne/hawkthorne-journey/issues?labels=audio&state=open

## Sprites

There are always new sprites that we need made. Take a gander at the [list of
needed sprites][sprites] and pick an item to work on. Make sure to comment on
the issue once you've decided to work on it. Once you're finished, post a link
to your completed sprite file in the issue and we'll get it into the game.

Would you rather work on organizing sprites? We need people to take existing
sprites and organize them into a tileset so that we can make a level. Pick from
[a tileset we need made][tilesets] and get to work.

Note: [the deprecated sprite/sound/character spreadsheet](https://docs.google.com/spreadsheet/ccc?key=0AhXdsqGjvkjPdE1aN1lrNTU3QW5Wb3Q4NFZhUF9ZV2c#gid=0)

[sprites]: https://github.com/hawkthorne/hawkthorne-journey/issues?labels=sprites&state=open
[tilesets]: https://github.com/hawkthorne/hawkthorne-journey/issues?labels=tileset&state=open

## Code

### We love pull requests. Here's a quick guide:

1. Choose a [gameplay feature][gameplay] or [bug][bugs] to work on. 
   Comment on the issue so that we know you are working on it.
2. Fork the repo. Please also create a separate branch

    $ git checkout -b my-cool-feature

   We don't accept pull requests from master branches.
3. Make sure the game runs with your change. See the README for details.
4. Push to your fork and submit a pull request.

At this point you're waiting on us. We like to at least comment on, if not
accept, pull requests within a few days. We may suggest some changes or
improvements or alternatives.

### Write unit tests

We value testing above all else. To run the unit tests, run

    $ make test

in the repository.

### Some things that will increase the chance that your pull request is accepted

* Use Lua idioms and helpers
* Update the documentation, the surrounding one, examples elsewhere, guides,
  whatever is affected by your contribution

### Syntax:

* Two spaces, no tabs.
* No trailing whitespace. Blank lines should not have any space.
* Follow the conventions you see used in the source already.

### Handy Code Templates:
[Node Template][node]: used for making objects in the game

[Gamestate Template][gamestate]: used for making a new gamescreen(e.g the pause menu)

[node]: https://github.com/hawkthorne/hawkthorne-journey/blob/master/docs/codetemplates/node.lua
[gamestate]: https://github.com/hawkthorne/hawkthorne-journey/blob/master/docs/codetemplates/state.lua

[gameplay]: https://github.com/hawkthorne/hawkthorne-journey/issues?labels=gameplay&state=open
[bugs]: https://github.com/hawkthorne/hawkthorne-journey/issues?labels=bug&state=open

## Characters and Costumes

First, read the [costume creation guide][costumes] or [character creation
guide][characters]. These guides give you all the information you'll need to
get started.

When you're finished, either [open an issue on Github][newissue] or [create a
post on the /r/hawkthorne subreddit][newpost].

[costumes]: https://github.com/hawkthorne/hawkthorne-journey/wiki/Costume-creation-guide
[characters]: https://github.com/hawkthorne/hawkthorne-journey/wiki/Character-creation-guide
[characters]: https://github.com/hawkthorne/hawkthorne-journey/wiki/Character-creation-guide

## Playtest

Playtesters are always needed. [Download the game][downloads] and follow the
[walthrough][testing]. Make sure to [report any bugs you find][newissue].
Please include your operating system and computer specs when reporting an
issue.

[testing]: https://github.com/hawkthorne/hawkthorne-journey/wiki/Walkthrough
[downloads]: https://github.com/hawkthorne/hawkthorne-journey/blob/master/README.md#download-the-game
[newissue]: https://github.com/hawkthorne/hawkthorne-journey/issues/new
[newpost]: http://www.reddit.com/r/hawkthorne/submit
