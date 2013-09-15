require "test/lunatest"

-- Unit tests
lunatest.suite("test/test_utils")
lunatest.suite("test/test_tween")
lunatest.suite("test/test_queue")
lunatest.suite("test/test_dialog")
lunatest.suite("test/test_transition")
lunatest.suite("test/test_fsm")
lunatest.suite("test/test_updater")
lunatest.suite("test/test_cheat")
lunatest.suite("test/test_inventory")

-- Functional tests
lunatest.suite("test/test_controls")
lunatest.suite("test/test_credits")
lunatest.suite("test/test_scanning")
lunatest.suite("test/test_title")

-- Don't change these lines
love.audio.setVolume(0)

local opts = {verbose=true}
opts.quit_on_failure = love._os == "Windows"
lunatest.run(nil, opts)
