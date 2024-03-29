function OnAccountLoad(player)
    -- If account exists
    --AddPlayerChat(player, "authed")
    if(mariadb_get_row_count() == 0) then
        -- User doesn't exist
        -- Create a new account automatically
        local query = mariadb_prepare(db, "INSERT INTO accounts (steamid, join_ip, lastseen_ip) VALUES ('?', '?', '?')",
            tostring(GetPlayerSteamId(player)),
            GetPlayerIP(player),
            GetPlayerIP(player)
        )
        mariadb_async_query(db, query)

        PlayerData[player].privilege = 0
        PlayerData[player].playtime = 0
        PlayerData[player].cash = 0
        PlayerData[player].score = 0
        PlayerData[player].wins = 0
        PlayerData[player].deaths = 0
        PlayerData[player].joindate = os.time()
        PlayerData[player].join_ip = GetPlayerIP(player)
        PlayerData[player].hat = 0
        PlayerData[player].playermodel = 1

        if(tostring(GetPlayerSteamId(player)) == config.adminSteamId) then
            PlayerData[player].privilege = 5
        end
    else
        -- User has an account
        -- Load its data
        local result = mariadb_get_assoc(1)

        PlayerData[player].privilege = tonumber(result.privilege)
        PlayerData[player].playtime = tonumber(result.playtime)
        PlayerData[player].cash = tonumber(result.cash)
        PlayerData[player].score = tonumber(result.score)
        PlayerData[player].wins = tonumber(result.wins)
        PlayerData[player].deaths = tonumber(result.deaths)
        PlayerData[player].joindate = tonumber(result.joindate)
        PlayerData[player].join_ip = result.join_ip
        PlayerData[player].lastseen_ip = result.lastseen_ip
        PlayerData[player].hat = tonumber(result.hat)
        PlayerData[player].playermodel = tonumber(result.outfit)
    
        if(tostring(GetPlayerSteamId(player)) == config.adminSteamId) then
            PlayerData[player].privilege = 5
        end
    end

    -- default
    PlayerData[player].lastseen = os.time()
    PlayerData[player].cmd_cooldown = 0
    PlayerData[player].warnings = 0

    local query = mariadb_prepare(db, "UPDATE accounts SET lastseen_ip = '?' WHERE steamid = '?' LIMIT 1",
        GetPlayerIP(player),
        tostring(GetPlayerSteamId(player))
    )
    mariadb_async_query(db, query)

    -- Eligable to use commands
    PlayerData[player].isSteamAuth = true
    --[[
    SetPlayerLocation(player, 125773.0, 80246.0, 1645.0)
    SetPlayerFacingAngle(player, 90.0)
    ]]--
    SetPlayerRespawnTime(player, 0)
    SetPlayerHealth(player, 0)
end

function SaveAccount(player)
    local query = mariadb_prepare(db, "UPDATE accounts SET privilege = ?, playtime = ?, cash = ?, score = ?, wins = ?, deaths = ?, lastseen = ?, lastseen_ip = '?', hat = ?, outfit = ? WHERE steamid = '?' LIMIT 1",
        PlayerData[player].privilege,
        PlayerData[player].playtime,
        PlayerData[player].cash,
        PlayerData[player].score,
        PlayerData[player].wins,
        PlayerData[player].deaths,
        os.time(),
        "127.0.0.1", --GetPlayerIP(player),
        PlayerData[player].hat,
        PlayerData[player].playermodel,
        tostring(GetPlayerSteamId(player))
    )
    mariadb_async_query(db, query)
end