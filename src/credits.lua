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

function state:keypressed(button)
    Gamestate.switch(self.previous)
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
    'arrianj',
    'asdf',
    'atbvids',
    'automatic_taglines',
    'barry.se',
    'beebes',
    'beforemonsters',
    'benfranklinchang',
    'benlew',
    'boobatron4000',
    'buckybrewer',
    'calledieu',
    'cant remember',
    'chanchan88',
    'charmee',
    'childish_gambino3',
    'clairelabear',
    'clairelebear',
    'claywin',
    'clogan1',
    'cmdoptesc',
    'condoreo',
    'coray8',
    'coreyander',
    'covertpz',
    'cptbooyah',
    'creedogv',
    'creekee',
    'cyberpie118',
    'dancingshadow',
    'dano1163',
    'de3ertf0x',
    'deadpoolismyhomeboy',
    'deckhipstername',
    'delicioussoma',
    'derferman',
    'dont do',
    'dontgochinatownme',
    'dr. awesome',
    'durrel',
    'dyan654',
    'easilyremember',
    'edisonout',
    'edsterman',
    'elduderino103',
    'elfaisa',
    'everydaymuffin',
    'eviltimmy',
    'evsboy123',
    'fanjeta123',
    'fannyfeeny',
    'fapficionado',
    'fardy',
    'fieldafar',
    'filmsauce',
    'gameboy09',
    'gameoftardises',
    'gingrbeard',
    'gizmo9002',
    'glasenator',
    'graf_rotz',
    'guyinhat',
    'gvx',
    'hbjudo17',
    'heikon',
    'hisfavouriteflavour',
    'holyhandgnade13',
    'idontusereddit',
    'igotaxmastime4me',
    'ihumanable',
    'jackim',
    'james92498',
    'janaya',
    'jcoleondabeat',
    'jewporn',
    'jiggpig',
    'jjangu',
    'jjfresh814',
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
    'liwaldo',
    'lvl5lazorlotus',
    'm_a_d',
    'majestic_moose',
    'mario3d',
    'matthewdelacruz15',
    'mcclellan',
    'mckriet',
    'mexicanace',
    'midnightbarber',
    'mister_spider',
    'myers78',
    'mystro256',
    'nachojarred',
    'nbieter',
    'necral',
    'necromanteion',
    'nerdsavvy',
    'niksn',
    'niles_smiles',
    'nimnams',
    'nonisredael',
    'notfreshprince',
    'nyan_swanson',
    'octocycle2',
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
    'simmonsisfinished',
    'sirdregan',
    'snokone',
    'spritefan',
    'sprneon',
    'spuddeh',
    'systemsoverload',
    'tgnsd',
    'the govnor',
    'thejordyd',
    'thekurtin',
    'thomasmb',
    'tonyator',
    'trevorstarick',
    'tristian',
    'tristianshaut',
    'ultraelite',
    'unameriquinn',
    'username1979',
    'vilhelmsmurphy',
    'vintagefuture',
    'vontd',
    'wilburwright',
    'wubbledaddy',
    'wuubledaddy',
    'wyken',
    'xequalsalex',
    'xiaorobear',
    'yigabar',
    'zaxerone',
    'zchmhssn89',
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


