local Gamestate = require 'vendor/gamestate'
local window = require 'window'
local camera = require 'camera'
local state = Gamestate.new()

function state:init()
end

function state:enter(previous)
    love.graphics.setBackgroundColor(0, 0, 0)
    self.music = love.audio.play("audio/credits.ogg", "stream", true)
    self.ty = 0
    camera:setPosition(0, self.ty)
    self.previous = previous
end

function state:leave()
    love.audio.stop(self.music)
end

function state:update(dt)
    self.ty = self.ty + 50 * dt
    camera:setPosition(0, self.ty)
end

function state:keypressed(key)
    if key == 'escape' or key == 'return' then
        Gamestate.switch(self.previous)
    end
end

state.credits = {
	'CREDITS',
	'6sutters',
	'a8252359',
	'aaronpetykowski',
	'acedia',
	'afiveseven',
	'afuturepresident',
	'ajay182',
	'akobrandon',
	'alpenghandi',
	'andyantsypants',
	'anton9109',
	'asdf',
	'atbvids',
	'automatic_taglines',
	'barry.se',
	'beebes',
	'beforemonsters',
	'benfranklinchang',
	'benlew',
	'boobatron',
	'boobatron4000',
	'calledieu',
	'charmee',
	'childish_gambino3',
	'clairelabear',
	'claywin',
	'clogan1',
	'cmdoptesc',
	'covertpz',
	'cptbooyah',
	'creekee',
	'cyberpie118',
	'de3ertf0x',
	'deadpoolismyhomeboy',
	'deckhipstername',
	'delicioussoma',
	'derferman',
	'dontgochinatownme',
	'dr. awesome',
	'easilyremember',
	'edisonout',
	'elfaisa',
	'eviltimmy',
	'fanjeta123',
	'fardy',
	'fieldafar',
	'gameoftardises',
	'gizmo9002',
	'glasenator',
	'hbjudo17',
	'heikon',
	'hisfavouriteflavour',
	'holyhandgnade13',
	'idontusereddit',
	'jackim',
	'james92498',
	'janaya',
	'jewporn',
	'jjangu',
	'joshcorr',
	'jpole1',
	'jscuur',
	'kastian',
	'kaworus_lover',
	'kazook',
	'kcig',
	'kilakev',
	'klosec12',
	'konyismydad',
	'lasternom',
	'lavenenosa',
	'lifedreamcreate',
	'lily_is_i',
	'liwaldo',
	'lvl5lazorlotus',
	'm_a_d',
	'majestic_moose',
	'mario3d',
	'mckriet',
	'midnightbarber',
	'mister_spider',
	'nachojarred',
	'nbieter',
	'necral',
	'necromanteion',
	'nerdsavvy',
	'nonisredael',
	'notfreshprince',
	'nyan_swanson',
	'octocycle2',
	'ohhoee',
	'ohsin',
	'outlandishflamingo',
	'paintyfilms',
	'paragon19',
	'period blood',
	'philoctitties',
	'piratejesus',
	'profbauer',
	'rahmeeroh',
	'rainfly_x',
	'renako',
	'roundy210',
	'safetytorch',
	'sallybranch',
	'seanbroney',
	'sherlockholme',
	'shnook21',
	'snokone',
	'spritefan',
	'sprneon',
	'szprega',
	'tgnsd',
	'the govnor',
	'thejordyd',
	'thekurtin',
	'thomasmb',
	'trevorstarick',
	'tristian',
	'tristianshaut',
	'unameriquinn',
	'vintagefuture',
	'vontd',
	'wilburwright',
	'wubbledaddy',
	'wyken',
	'xiaorobear',
	'zaxerone',
	'zhai',
} 

function state:draw()
    local shift = math.floor(self.ty/25)
    for i = shift - 11, shift + 1 do
        local name = self.credits[i]
        if name then
            love.graphics.printf(name, 0, 250 + 25 * i, window.width, 'center')
        end
    end
end

return state
