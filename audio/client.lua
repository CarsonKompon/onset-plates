local LastSongPlayed = 0
local LastSoundPlayed = 0

local musicState = 0

function PlaySoundFile(file)
	DestroySound(LastSoundPlayed)

	LastSoundPlayed = CreateSound("audio/sounds/"..file)
    SetSoundVolume(LastSoundPlayed, 1.0)
end
AddRemoteEvent("PlaySoundFile", PlaySoundFile)

function PlaySoundFile3D(file, x, y, z, r)
	CreateSound3D("audio/sounds/"..file, x, y, z, r)
end
AddRemoteEvent("PlaySoundFile3D", PlaySoundFile3D)

function PlayMusicFile(file, state)
	DestroySound(LastSongPlayed)

	LastSongPlayed = CreateSound("audio/music/"..file)
    SetSoundVolume(LastSongPlayed, 0.2)
    
    musicState = state
end
AddRemoteEvent("PlayMusicFile", PlayMusicFile)

function OnSoundFinished(sound)
    if sound == LastSongPlayed then
        if musicState == 0 then
            PlayMusicFile("freeroam" .. tostring(math.random(0,3)) .. ".mp3", 0)
        else
            PlayMusicFile("game" .. tostring(math.random(0,9)) .. ".mp3", 0)
        end
    end
end
AddEvent("OnSoundFinished", OnSoundFinished)