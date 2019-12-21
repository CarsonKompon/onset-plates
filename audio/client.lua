local LastSongPlayed = 0
local LastSoundPlayed = 0

function PlaySoundFile(file)
	DestroySound(LastSoundPlayed)

	LastSoundPlayed = CreateSound("audio/sounds/"..file)
	SetSoundVolume(LastSoundPlayed, 1.1)
end
AddRemoteEvent("PlaySoundFile", PlaySoundFile)

function PlayMusicFile(file)
	DestroySound(LastSongPlayed)

	LastSongPlayed = CreateSound("audio/music/"..file)
	SetSoundVolume(LastSongPlayed, 1.1)
end
AddRemoteEvent("PlayMusicFile", PlayMusicFile)