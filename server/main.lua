-- Plates by Carson K.
-- Code based on the blank Onset gamemode written by Kaperstone


-- Initilizing global arrays

config = {
    -- The SteamId64 of your Steam account
    adminSteamId = "76561198031113835",
    -- MariaDB credentials
    mariadb = { host = "localhost:3306", user = "root", password = "password", database = "default" },
    -- Logging options
    log = { kicks = true, bans = true, unbans = true, warns = true },
    max_warnings = 3,
    -- The minimum and maximum length a reason can be for { kick, ban, unban, warn }
    min_reason = 3,
    max_reason = 128,
    admin_level = { kick = 1, ban = 2, unban = 3, warn = 1}
}

--Game States:
--WAITING - Waiting for players to join
--STARTING - Once a player joins, countdown to game start

--IDLE - Waiting for next command
--COMMANDING - Showing the command and warning players
--EFFECT - Unleashing the effect on the players

db = false
PlayerData = { }

gamemode = {
    -- Gamemode vars
    gameStart = false,
    gameState = "WAITING",
    currentTimer = 0,
    lastWinner = 0,
    commandType = 1,
    command = 0,
    commands = events[commandType],
    effecting = 1,
    effected = {},
    ingame = {},
    winReward = 250,
    killbox = nil,
    killboxZ = 10.0,
    wall1 = nil,
    wall2 = nil,
    wall3 = nil,
    wall4 = nil,
    safePlates = {}
}

function FindObject(propname, propvalue)
    --for _, v in pairs(GetAllO)
end

function OnPackageStart()
    math.randomseed(os.time())

    mariadb_log("debug")

    print((":: Onset server `%s` running version %s\n"):format(GetServerName(), GetGameVersionString()))
    print("> Attempting to connect to MariaDB server")

    db = mariadb_connect("localhost:3306", "root", "password", "plates")

    if(db ~= false) then
        print("> Successfully connected to MariaDB")
        mariadb_set_charset(db, "utf8mb4")
        --mariadb_await_query_file(db, "accounts.sql")
    else
        print("> Failed to connect to MariaDB, stopping the server ...")
        ServerExit()
    end

    CreateWalls()

    CreateTimer(function()
        GameTimer()
    end, 1000)

end
AddEvent("OnPackageStart", OnPackageStart)

function OnPackageStop()
    for _, v in pairs(GetAllPlayers()) do
        SaveAccount(v)
    end
    print(":: Stopping the server")
    mariadb_close(db)
end
AddEvent("OnPackageStop", OnPackageStop)

--[[
function OnPlayerChatCommand(player, cmd, exists)
    if(not PlayerData[player].isSteamAuth) then
        return AddPlayerChat("Your Steam account hasn't been authenticated yet.")
    end

    if (GetTimeSeconds() - PlayerData[player].cmd_cooldown < 0.5) then
        CancelChatCommand()
        return AddPlayerChat(player, "Slow down with your commands")
    end

    PlayerData[player].cmd_cooldown = GetTimeSeconds()

    if (exists == 0) then
        AddPlayerChat(player, "Command `/"..cmd.."` not found!")
    end
end
AddEvent("OnPlayerChatCommand", OnPlayerChatCommand)
]]--

-- Vehicle events

function OnPlayerEnterVehicle(player, vehicle, seat)

end
AddEvent("OnPlayerEnterVehicle", OnPlayerEnterVehicle)

function OnPlayerLeaveVehicle(player, vehicle, seat)

end
AddEvent("OnPlayerLeaveVehicle", OnPlayerLeaveVehicle)

function OnPlayerStateChange(player, newstate, oldstate)

end
AddEvent("OnPlayerStateChange", OnPlayerStateChange)

function OnVehicleRespawn(vehicle)

end
AddEvent("OnVehicleRespawn", OnVehicleRespawn)

function OnVehicleStreamIn(vehicle, player)

end
AddEvent("OnVehicleStreamIn", OnVehicleStreamIn)

function OnVehicleStreamOut(vehicle, player)

end
AddEvent("OnVehicleStreamOut", OnVehicleStreamOut)


-- Server events

function OnGameTick(DeltaSeconds)
    if(#gamemode.ingame == 1) then gamemode.lastWinner = gamemode.ingame[1] end
    if(gamemode.gameStart == true) and (#gamemode.ingame > 0) then
        for _, v in pairs(gamemode.ingame) do
            if(v ~= nil) and (PlayerData[v].plate ~= nil) and (GetObjectPropertyValue(PlayerData[v].plate, "type") == "plate") then
                roundEnd = false
                local x, y, z = GetObjectLocation(PlayerData[v].plate)
                local sx, sy, sz = GetObjectScale(PlayerData[v].plate)
                if(PlayerData[v].plateScale ~= nil) and (sx ~= PlayerData[v].plateScale) then
                    if PlayerData[v].plateScale < 0 then PlayerData[v].plateScale = 0 end
                    sx = Lerp(sx, PlayerData[v].plateScale, 0.0125)
                    SetObjectScale(PlayerData[v].plate, sx, sx, sz)
                elseif(math.floor(sx) == 0) then
                    DestroyPlate(v)
                end
                if(PlayerData[v].plateZ ~= nil) and (z ~= PlayerData[v].plateZ) then
                    z = Lerp(z, PlayerData[v].plateZ, 0.0125)
                    local frx, fry, frz = GetObjectLocation(PlayerData[v].plate)
                    SetObjectLocation(PlayerData[v].plate, frx, fry, z)
                else
                    if(PlayerData[v].firebar == "stillHas") then
                        EffectPlate(player, 22)
                    end
                end
                if(PlayerData[v].hurting) then
                    SetPlayerHealth(v, GetPlayerHealth(v)-1)
                end
                if(PlayerData[v].spinning ~= nil) then
                    if(PlayerData[v].spinning) and (PlayerData[v].plate ~= nil) then
                        local rx, ry, rz = GetObjectRotation(PlayerData[v].plate)
                        SetObjectRotation(PlayerData[v].plate, rx, ry+(0.05*PlayerData[v].spinning), rz)
                    end
                end
                if(PlayerData[v].plateLadder ~= nil) then
                    local lx, ly, lz = GetObjectLocation(PlayerData[v].plateLadder)
                    --lx = Lerp(lx, x, 0.0125)
                    --ly = Lerp(ly, y, 0.0125)
                    lz = Lerp(lz, z, 0.0125)
                    SetObjectLocation(PlayerData[v].plateLadder, lx, ly, lz)
                end
                if(PlayerData[v].fence1 ~= nil) then
                    local fx1, fy1, fz1 = GetObjectLocation(PlayerData[v].fence1)
                    local fx2, fy2, fz2 = GetObjectLocation(PlayerData[v].fence2)
                    local fx3, fy3, fz3 = GetObjectLocation(PlayerData[v].fence3)
                    local fx4, fy4, fz4 = GetObjectLocation(PlayerData[v].fence4)
                    fz1 = Lerp(fz1, z, 0.0125)
                    SetObjectLocation(PlayerData[v].fence1, fx1, fy1, fz1)
                    SetObjectLocation(PlayerData[v].fence2, fx2, fy2, fz1)
                    SetObjectLocation(PlayerData[v].fence3, fx3, fy3, fz1)
                    SetObjectLocation(PlayerData[v].fence4, fx4, fy4, fz1)
                end
            end
        end

    end
    if(gamemode.killbox ~= nil) then
        local sx, sy, sz = GetPickupScale(gamemode.killbox)
        sz = Lerp(sz, gamemode.killboxZ, 0.0125)
        SetPickupScale(gamemode.killbox, sx, sy, sz)
    end

    --[[
    local tx, ty, tz = GetPlayerLocation(1)
    local tr = GetPlayerHeading(1)
    AddPlayerChatAll(tx .. ", " .. ty .. ", " .. tz .. ", " .. tr)
    ]]--

    
end
AddEvent("OnGameTick", OnGameTick)

function OnClientConnectionRequest(ip, port)

end
AddEvent("OnClientConnectionRequest", OnClientConnectionRequest)

function OnPlayerServerAuth(player)

end
AddEvent("OnPlayerServerAuth", OnPlayerServerAuth)

function OnPlayerSteamAuth(player)
    --AddPlayerChat(player, "Your SteamId: "..GetPlayerSteamId(player))

    local query = mariadb_prepare(db, "SELECT * FROM accounts WHERE steamid = '?' LIMIT 1", tostring(GetPlayerSteamId(player)))
    mariadb_async_query(db, query, OnAccountLoad, player)
end
AddEvent("OnPlayerSteamAuth", OnPlayerSteamAuth)

function OnPlayerDownloadFile()

end
AddEvent("OnPlayerDownloadFile", OnPlayerDownloadFile)

-- Pickup events

function OnVehiclePickupHit()

end
AddEvent("OnVehiclePickupHit", OnVehiclePickupHit)

-- Stream events

function OnPlayerStreamIn(player, otherplayer)

end
AddEvent("OnPlayerStreamIn", OnPlayerStreamIn)

function OnPlayerStreamOut(player, otherplayer)

end
AddEvent("OnPlayerStreamOut", OnPlayerStreamOut)


-- NPC events

function OnNPCReachTarget()

end
AddEvent("OnNPCReachTarget", OnNPCReachTarget)

function OnNPCDamage()

end
AddEvent("OnNPCDamage", OnNPCDamage)

function OnNPCSpawn()

end
AddEvent("OnNPCSpawn", OnNPCSpawn)

function OnNPCDeath()

end
AddEvent("OnNPCDeath", OnNPCDeath)

function GivePlayerScore(player, score)
    PlayerData[player].score = PlayerData[player].score + score
end

function Lerp(a, b, f)
    return a + (f * (b - a));
end
