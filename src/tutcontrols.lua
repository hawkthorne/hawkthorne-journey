local controls = require('inputcontroller').get()

return {
  blocks = "Blocks are easy, take a look at these in tiled to learn more about options.",
  chests = "Some chests require a key, keep this in mind when placing them.",
  climbing = "Jump by pressing {{yellow}}" .. string.upper(controls:getKey('JUMP')) .. "{{white}} and then press {{yellow}}" 
    .. string.upper(controls:getKey('UP')) .. "{{white}} to start climbing the rope.",
  collisions = "Placing collision tiles is just like placing regular ones, just remember to place them in the collision layer and they CANNOT be rotated.",
  crawling = "To crawl, hold the {{yellow}}" .. string.upper(controls:getKey('DOWN')) .. "{{white}} button and then {{yellow}}" 
    .. string.upper(controls:getKey('LEFT')) .. "{{white}} or {{yellow}}" .. string.upper(controls:getKey('RIGHT')) .. "{{white}} depending on your direction of travel.",
  digging = "To dig, press {{yellow}}" .. string.upper(controls:getKey('DOWN')) .. "{{white}} and {{yellow}}" .. string.upper(controls:getKey('ATTACK')) .. "{{white}}.",
  dropping = "To drop through platforms double tap the {{yellow}}" .. string.upper(controls:getKey('DOWN')) .. "{{white}} button.",
  enemies = "Most enemies are easy, look in the tiled file for an example of the enemies that are not (and the ones that are).",
  liquid = "Liquid is easy, refer to liquid.lua for more options.",
  npc = "NPC's are one of the harder things to add to a level, it takes sprites and a dedicated .lua file, refer to other NPC's to see what can be done.",
  place_rope = "When placing a rope, remember to place the top of the rope just above the block, this ensures that player can get on and off the rope easily.",
  platforms = "Platforms require there to be a line, don't forget to set the line property of the platform to be the same as the name of the target line.",
  sprites = "Sparkles!  Sprites have a lot of options, refer to sprite.lua to view them all."
}
