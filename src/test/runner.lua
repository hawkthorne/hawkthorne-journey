require "test/lunatest"

lunatest.suite("test/test_utils")
lunatest.suite("test/test_tween")
lunatest.suite("test/test_queue")
lunatest.suite("test/test_dialog")
lunatest.suite("test/test_transition")
lunatest.suite("test/test_fsm")
lunatest.suite("test/test_updater")

-- Don't change these lines
local opts = {verbose=true}
opts.quit_on_failure = love._os == "Windows"
lunatest.run(nil, opts)
