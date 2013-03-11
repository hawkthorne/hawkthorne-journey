# HAWK 2d Platformer Framework

HAWK is a set of modules on top of LOVE that are needed to make modern 2d
platformers.

## i18n

```lua
local i18n = require 'hawk/i18n'

locale = i18n.getCurrentLocale()
-- 'en-US'

i18n.setLocale('en', 'US')

i18n('hello')
```

Strings must be stored as JSON in a `locales` directory. For example, this is a
sample `en-US.json` strings file.

```js
{
  "hello": "Hello World"
}
```

## json

HAWK provides JSON support using JSON4Lua version 0.9.40

```lua
local json = require 'hawk/json'
local contents = {"foo", "bar"}
json.encode(contents)
```

## store

A simple key-value store is provided, built on top of flat JSON files.

```lua
local store = require 'hawk/store'
local db = store.load('gamestate')

db:get('foo', true) -- second argument is default
db:set('foo', false)
db:flush() -- persist
```

## assets

HAWK provides simple assert management. Never create multiple images again
