local controls = require('inputcontroller').get()

return {
  climbing = "Jump by pressing {{yellow}}" .. string.upper(controls:getKey('JUMP')) .. "{{white}} and then press {{yellow}}" 
      .. string.upper(controls:getKey('UP')) .. "{{white}} to start climbing the rope.",
  crawling = "To crawl, hold the {{yellow}}" .. string.upper(controls:getKey('DOWN')) .. "{{white}} button and then {{yellow}}" 
      .. string.upper(controls:getKey('LEFT')) .. "{{white}} or {{yellow}}" .. string.upper(controls:getKey('RIGHT')) .. "{{white}} depending on your direction of travel.",
  digging = "To dig, press {{yellow}}" .. string.upper(controls:getKey('DOWN')) .. "{{white}} and {{yellow}}" .. string.upper(controls:getKey('ATTACK')) .. "{{white}}.",
  dropping = "To drop through platforms double tap the {{yellow}}" .. string.upper(controls:getKey('DOWN')) .. "{{white}} button."
}
