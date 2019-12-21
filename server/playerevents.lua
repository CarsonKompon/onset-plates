-- Player events

function OnPlayerPickupHit(player, pickup)
    local pickupType = GetPickupPropertyValue(pickup, "type")
    if(pickupType == "mine") then
        local x, y, z = GetPlayerLocation(player)
        CreateExplosion(1, x, y, z)
        DestroyPickup(pickup)
        return
    elseif(pickupType == "firebar") then
        SetPlayerHealth(player, GetPlayerHealth(player) - 10)
    end
    if(pickup == gamemode.killbox) then
        SetPlayerHealth(player, 0)
    end
end
AddEvent("OnPlayerPickupHit", OnPlayerPickupHit)

function OnPlayerCollision(player, collision, hittype, hitid)
    AddPlayerChatAll("bump")
    if(hitid == PlayerData[player].plate) and (PlayerData[player].poison == true) then
        AddPlayerChatAll("HURTING")
        PlayerData[player].hurting = true
    end
    for _, v in pairs(GetAllPlayers()) do
        if(hitid == PlayerData[v].firebar) then
            PlayerData[player].hurting = true
        end
    end
end
AddRemoteEvent("plates:OnPlayerCollision", OnPlayerCollision)

function OnPlayerCollisionEnd(player, collision, hittype, hitid)
    if(hitid == PlayerData[player].plate) and (PlayerData[player].poison == true) then
        AddPlayerChatAll("NOT HURTING")
        PlayerData[player].hurting = false
    end
    for _, v in pairs(GetAllPlayers()) do
        if(hitid == PlayerData[v].firebar) then
            PlayerData[player].hurting = false
        end
    end
end
AddRemoteEvent("plates:OnPlayerCollisionEnd", OnPlayerCollisionEnd)

function OnPlayerJoin(player)
    -- Set where the player is going to spawn.
    SetPlayerSpawnLocation(player, 125773.000000, 80246.000000, 1645.000000, -90.0)

    AddPlayerChatAll(GetPlayerName(player).." ("..player..") joined the server")
    AddPlayerChatAll("There are "..GetPlayerCount().." players on the server")
    AddPlayerChat(player, "Welcome to `"..GetServerName().."`")
    AddPlayerChat(player, "Game version: "..GetPlayerGameVersion(player)..", Locale: "..GetPlayerLocale(player))

    PlayerData[player] = {}
    PlayerData[player].isSteamAuth = false

end
AddEvent("OnPlayerJoin", OnPlayerJoin)

function OnPlayerQuit(player)
    AddPlayerChatAll(GetPlayerName(player).." left the server.")
    gamemode.effected = nil
    SaveAccount(player)
    torem = nil
    for i, v in pairs(gamemode.ingame) do
        if(GetPlayerSteamId(v) == GetPlayerSteamId(player)) then
            --AddPlayerChatAll("Removal")
            torem = i
        end
    end
    if(torem ~= nil) then table.remove(gamemode.ingame, torem) end
    DestroyPlate(player)
    --PlayerData[player] = nil

    CheckGameOver()
end
AddEvent("OnPlayerQuit", OnPlayerQuit)

function OnPlayerSpawn(player)
    --AddPlayerChat(player, "You have spawned")
    if(gamemode.gameState ~= "INTERMISSION") then
        CallRemoteEvent(player, "PlayMusicFile", "freeroam" .. tostring(math.random(0,3)) .. ".mp3", 0)
    end
    PlayerData[player].blind = 0
    if (PlayerData[player].hat ~= nil) and (PlayerData[player].hat > 0) then SetPlayerHat(player) end
    
    SetPlayerRespawnTime(player, 1500)

    CallRemoteEvent(player, "plates:ChangeCam", false)
    --[[
    CallRemoteEvent(player, "player:SetPlayerModel", PlayerData[player].playermodel)
    CallRemoteEvent(player, "player:SetClothingShirt", PlayerData[player].clothingShirt)
    CallRemoteEvent(player, "player:SetClothingPants", PlayerData[player].clothingPants)
    ]]--

    CallRemoteEvent(player, "player:SetPlayerOutfit", player, PlayerData[player].playermodel)
end
AddEvent("OnPlayerSpawn", OnPlayerSpawn)

function OnPlayerDeath(player, killer)
    AddPlayerChatAll(("%s(%d) has been eliminated!"):format(
        GetPlayerName(killer),
        killer
    ))

    torem = nil
    for i, v in pairs(gamemode.ingame) do
        if(GetPlayerSteamId(v) == GetPlayerSteamId(player)) then
            --AddPlayerChatAll("Removal")
            torem = i
        end
    end
    if(torem ~= nil) then table.remove(gamemode.ingame, torem) end
    
    DestroyPlate(player)

    PlayerData[player].deaths = PlayerData[player].deaths + 1

    if(PlayerData[player].hatobj ~= nil) then
        DestroyObject(PlayerData[player].hatobj)
        PlayerData[player].hatobj = nil
    end

    CheckGameOver()
end
AddEvent("OnPlayerDeath", OnPlayerDeath)

function OnPlayerWeaponShot(player, weapon, hittype, hitid, hitX, hitY, hitZ, startX, startY, normalX, normalY, normalZ)

end
AddEvent("OnPlayerWeaponShot", OnPlayerWeaponShot)

function OnPlayerDamage(player, damagetype, amount)

end
AddEvent("OnPlayerDamage", OnPlayerDamage)


function OnPlayerChat(player, text)
    AddPlayerChatAll(("%s: %s"):format(
        GetPlayerName(player),
        text
    ))
end
AddEvent("OnPlayerChat", OnPlayerChat)

function SetPlayerHat(player)
    local hat = PlayerData[player].hat
    if PlayerData[player].hatobj ~= nil then
        DestroyObject(PlayerData[player].hatobj)
    end
    if hat > 0 then
        local xx, yy, zz = GetPlayerLocation(player)
        PlayerData[player].hatobj = CreateObject(hat,xx,yy,zz)
        SetObjectAttached(PlayerData[player].hatobj, ATTACH_PLAYER, player, 10.5, 3.0, 0.0, 0.0, 90.0, -90.0, "head")
    end
end