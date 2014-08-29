local controls = require('inputcontroller').get()

return {
  climbing = "Jump by pressing " .. controls:getKey('JUMP') .. " and then press " 
      .. controls:getKey('UP') .. " to start climbing the rope.",
	crawling = "To crawl, hold the " .. controls:getKey('DOWN') .. " button and then " 
      .. controls:getKey('LEFT') .. " or " .. controls:getKey('RIGHT') .. " depending on your direction of travel.",
  digging = "To dig, press " .. controls:getKey('DOWN') .. " and " .. controls:getKey('ATTACK') .. ".",
	dropping = "To drop through platforms double tap the " .. controls:getKey('DOWN') .. " button."
}
