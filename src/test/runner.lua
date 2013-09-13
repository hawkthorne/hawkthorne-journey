require "test/lunatest"

lunatest.suite("test/test_utils")
lunatest.suite("test/test_tween")
lunatest.suite("test/test_queue")
lunatest.suite("test/test_dialog")
lunatest.suite("test/test_transition")
lunatest.suite("test/test_fsm")
lunatest.suite("test/test_updater")
lunatest.suite("test/test_cheat")
lunatest.suite("test/test_inventory")

-- Don't change these lines
love.audio.setVolume(0)

local opts = {verbose=true}
opts.quit_on_failure = love._os == "Windows"
lunatest.run(nil, opts)
