return{
  name= 'helicopter',
  type= 'vehicle',
  hasAttack = true,
  --add in option for moving sprite when standing still
  move = {'loop', {'1-2,1','1-2,2'}, .1},
  attack = {'loop', {'1-2,1','1-2,2'}, .1},
  height = 224,
  width = 246,
  xOffset= 140,
  yOffset= 40,
}
