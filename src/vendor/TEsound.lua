-- TEsound v1.3, a simplified sound system for Love 2D
-- Created by Ensayia (Ensayia@gmail.com) and expanded by Taehl (SelfMadeSpirit@gmail.com)
TEsound = {}				-- Namespace
TEsound.channels = {}		-- This holds the currently playing sound channels
TEsound.volumeLevels = {}	-- Volume levels that multiply the volumes of sounds with those tags
TEsound.pitchLevels = {}	-- Pitch levels that multiply the pitches of sounds with those tags

-- Functions for playing sounds

-- Play a (potentially random) sound (with optional tag(s), volume, pitch, and on-finished function)
function TEsound.play(sound, tags, volume, pitch, func)
	if type(sound) == "table" then
		assert(#sound > 0, "The list of sounds must have at least one sound.")
		sound = sound[math.random(#sound)]
	end
	if not (type(sound) == "string" or (type(sound) == "userdata" and sound:type() == "SoundData")) then
		error("You must specify a sound - a filepath as a string, a SoundData, or a table of them. Not a Source!")
	end
	
	table.insert(TEsound.channels, { love.audio.newSource(sound), func, {volume or 1, pitch or 1}, tags=(type(tags) == "table" and tags or {tags}) })
	local s = TEsound.channels[#TEsound.channels]
	s[1]:play()
	s[1]:setVolume( (volume or 1) * TEsound.findVolume(tags) * (TEsound.volumeLevels.all or 1) )
	s[1]:setPitch( (pitch or 1) * TEsound.findPitch(tags) * (TEsound.pitchLevels.all or 1) )
	return #TEsound.channels
end

-- Plays a (potentially random) sound which will repeat be repeated n times (if n isn't given, you must stop it manually with TEsound.stop)
function TEsound.playLooping(sound, tags, n, volume, pitch)
	return TEsound.play( sound, tags, volume, pitch,
		(not n or n > 1) and function(d) TEsound.playLooping(sound, tags, (n and n-1), d[1], d[2]) end
	)
end

-- Functions for modifying sounds that are playing (passing these a tag instead of a string is generally preferable)

-- Sets the volume of channel/tag and its loops (if any), or resets it if volume is omitted (try going TEsound.volume("music", .5))
function TEsound.volume(channel, volume)
	if type(channel) == "number" then
		local c = TEsound.channels[channel] volume = volume or c[3][1] c[3][1] = volume
		c[1]:setVolume( volume * TEsound.findVolume(c.tags) * (TEsound.volumeLevels.all or 1) )
	elseif type(channel) == "string" then TEsound.volumeLevels[channel]=volume for k,v in pairs(TEsound.findTag(channel)) do TEsound.volume(v, volume) end
	end
end

-- Sets the pitch of channel/tag and its loops (if any), or resets it if pitch is omitted
function TEsound.pitch(channel, pitch)
	if type(channel) == "number" then
		local c = TEsound.channels[channel] pitch = pitch or c[3][2] c[3][2] = pitch
		c[1]:setPitch( pitch * TEsound.findPitch(c.tags) * (TEsound.pitchLevels.all or 1) )
	elseif type(channel) == "string" then TEsound.pitchLevels[channel]=pitch for k,v in pairs(TEsound.findTag(channel)) do TEsound.pitch(v, pitch) end
	end
end

-- Pauses a channel/tag
function TEsound.pause(channel)
	if type(channel) == "number" then TEsound.channels[channel][1]:pause()
	elseif type(channel) == "string" then for k,v in pairs(TEsound.findTag(channel)) do TEsound.pause(v) end
	end
end

-- Resumes a channel/tag
function TEsound.resume(channel)
	if type(channel) == "number" then TEsound.channels[channel][1]:resume()
	elseif type(channel) == "string" then for k,v in pairs(TEsound.findTag(channel)) do TEsound.resume(v) end
	end
end

-- Stops a sound channel/tag either immediately or when finished, and prevents it from looping
function TEsound.stop(channel, finish)
	if type(channel) == "number" then local c = TEsound.channels[channel] c[2] = nil if not finish then c[1]:stop() end
	elseif type(channel) == "string" then for k,v in pairs(TEsound.findTag(channel)) do TEsound.stop(v, finish) end
	end
end


-- Utility functions

-- Cleans up finished sounds, freeing memory. Call frequently!
function TEsound.cleanup()
	for k,v in ipairs(TEsound.channels) do
		if v[1]:isStopped() then
			if v[2] then v[2](v[3]) end		-- allow sounds to use custom functions (primarily for looping, but be creative!)
			table.remove(TEsound.channels, k)
		end
	end
end

-- Add or change a default volume level for a specified tag (for example, to change music volume, use TEsound.tagVolume("music", .5))
function TEsound.tagVolume(tag, volume)
	TEsound.volumeLevels[tag] = volume
	TEsound.volume(tag)
end

-- Add or change a default pitch level for a specified tag
function TEsound.tagPitch(tag, pitch)
	TEsound.pitchLevels[tag] = pitch
	TEsound.pitch(tag)
end


-- Internal functions

-- Returns a list of all sound channels with a given tag
function TEsound.findTag(tag)
	local t = {}
	for channel,sound in ipairs(TEsound.channels) do
		if sound.tags then for k,v in ipairs(sound.tags) do
			if tag == "all" or v == tag then table.insert(t, channel) end
		end end
	end
	return t
end

-- Returns a volume level for a given tag or tags
function TEsound.findVolume(tag)
	if type(tag) == "string" then return TEsound.volumeLevels[tag] or 1
	elseif type(tag) == "table" then for k,v in ipairs(tag) do if TEsound.volumeLevels[v] then return TEsound.volumeLevels[v] end end
	end
	return 1	-- if nothing is found, default to 1
end

-- Returns a pitch level for a given tag or tags
function TEsound.findPitch(tag)
	if type(tag) == "string" then return TEsound.pitchLevels[tag] or 1
	elseif type(tag) == "table" then for k,v in ipairs(tag) do if TEsound.pitchLevels[v] then return TEsound.pitchLevels[v] end end
	end
	return 1	-- if nothing is found, default to 1
end


-- ---------------CUSTOMIZATIONS

TEsound.musicPlaying = nil

-- Registers the new music, if it's not already
-- Stops any currently playing music
function TEsound.playMusic( song )
	if string.find( song, 'audio/' ) ~= 1 then -- not a path
		song = 'audio/music/' .. song .. '.ogg'
	end
	if TEsound.musicPlaying ~= song then
		TEsound.stop( 'music' )
		TEsound.playLooping( song, 'music' )
		TEsound.musicPlaying = song
	end
end

function TEsound.stopMusic()
	TEsound.stop( 'music' )
	TEsound.musicPlaying = nil
end

function TEsound.playSfx( sound )
	if string.find( sound , 'audio/' ) ~= 1 then -- not a path
		sound = 'audio/sfx/' .. sound .. '.ogg'
	end
	TEsound.getSource( sound ):stop()
	TEsound.play( sound, 'sfx' )
end

function TEsound.getSource( sound )
	return love.audio.newSource(sound)
end

-- audio source cache
TEsound.source_cache = {}
local newsource = love.audio.newSource
function love.audio.newSource(what,how)
	if not TEsound.source_cache[what] then
		how = how and how or 'static' -- default to static
		TEsound.source_cache[what] = newsource( what, how )
	end
	return TEsound.source_cache[what]
end

return TEsound