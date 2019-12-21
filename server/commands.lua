function cmd_kmp(player)
    -- Usage: /kill

    SetPlayerHealth(player, 0.0)
end
AddCommand("kill", cmd_kmp)

function cmd_effectPlate(player, effect)
    if(effect ~= nil) then
        AddPlayerChat(player, "Effect #" .. tostring(effect))
        EffectPlate(player, tonumber(effect))
    end
end
AddCommand("effect", cmd_effectPlate)

function cmd_Stats(player, target)
    -- Usage: /stats [playerid]
    -- playerid is optional

    local id
    if(target == nil) then
        id = player
    else
        id = target
    end


    AddPlayerChat(player, ("%s's statistics:"):format(GetPlayerName(player)))
    AddPlayerChat(player, ("Join date %s"):format(PlayerData[id].joindate))
    AddPlayerChat(player, ("Last seen %s"):format(PlayerData[id].lastseen))
    AddPlayerChat(player, ("Score: %d | Cash: %d"):format(PlayerData[id].score, PlayerData[id].cash))
    AddPlayerChat(player, ("Deaths: %d | Wins: %d"):format(PlayerData[id].deaths, PlayerData[id].wins))

    -- Admin stuff

    if(PlayerData[player].privilege >= 1) then
        AddPlayerChat(player, ("Current IP %d"):format(GetPlayerIP(id)))
        AddPlayerChat(player, ("Previous IP %d"):format(PlayerData[id].lastseen_ip))
        AddPlayerChat(player, ("Join IP %d"):format(PlayerData[id].join_ip))
    end
end
AddCommand("stats", cmd_Stats)
AddCommand("info", cmd_Stats)

function cmd_Kick(player, target, ...)
    -- Usage: /kick <playerid> <reason>

    if(not (PlayerData[player].privilege >= config.admin_level.kick)) then
        return AddPlayerChat(player, "Insufficient permissions")
    end

    if(target == nil or #{...} == 0) then
        return AddPlayerChat(player, "Usage: /kick <playerid> <reason>")
    end

    target = tonumber(target)

    if(not (config.min_reason < #{...} and #{...} <= config.max_reason)) then
        return AddPlayerChat(player, "The reason should be between 3 characters to 128")
    end

    if(PlayerData[target].privilege > PlayerData[player].privilege) then
        return AddPlayerChat(player, "Cannot kick an admin higher in level than you")
    end

    -- Log
    if(config.log.kicks == true) then
        local query = mariadb_prepare(db, "INSERT INTO kicks (targetid, adminid, reason) VALUES (?, ?, ?)",
            tostring(GetPlayerSteamId(target)),
            tostring(GetPlayerSteamId(player)),
            {...}
        )
        mariadb_async_query(db, query)
    end

    -- Action
    KickPlayer(target, "You have been kicked from the server for: "..{...})
    AddPlayerChatAll(("Player %s(%d) has been kicked for: %s"):format(GetPlayerName(target), target, {...}))
end
AddCommand("kick", cmd_Kick)

function cmd_Ban(player, target, ...)
    -- Usage: /ban <playerid> <reason>

    if(not (PlayerData[player].privilege >= config.admin_level.ban)) then
        return AddPlayerChat(player, "Insufficient permissions")
    end

    if(target == nil or #{...} == 0) then
        return AddPlayerChat(player, "Usage: /ban <playerid> <reason>")
    end

    target = tonumber(target)

    if(not (config.min_reason < #{...} and #{...} <= config.max_reason)) then
        return AddPlayerChat(player, "The reason should be between 3 characters to 128")
    end

    if(PlayerData[target].privilege > PlayerData[player].privilege) then
        return AddPlayerChat(player, "Cannot ban an admin higher in level than you")
    end

    -- Action
    mariadb_async_query(db, mariadb_prepare(db, "INSERT INTO bans (targetid, adminid, reason) VALUES (?, ?, ?)",
        tostring(GetPlayerSteamId(target)),
        tostring(GetPlayerSteamId(player)),
        {...}
    ))
    KickPlayer(target, "You have been banned from the server for: "..{...})
    AddPlayerChatAll(("Player %s(%d) has been banned for: %s"):format(GetPlayerName(target), target, {...}))
end
AddCommand("ban", cmd_Ban)

function cmd_Unban(player, target, ...)
    -- Usage: /unban <steamid> <reason>

    if(not (PlayerData[player].privilege >= config.admin_level.unban)) then
        return AddPlayerChat(player, "Insufficient permissions")
    end

    if(target == nil or #{...} == 0) then
        return AddPlayerChat(player, "Usage: /unban <steamid> <reason>")
    end

    target = tonumber(target)

    if(not (config.min_reason < #{...} and #{...} <= config.max_reason)) then
        return AddPlayerChat(player, "The reason should be between 3 characters to 128")
    end

    -- Log
    if(config.log.unbans == true) then
        mariadb_async_query(db, mariadb_prepare(db, "INSERT INTO unbans (targetid, adminid, reason) VALUES (?, ?, ?)",
            tostring(GetPlayerSteamId(target)),
            tostring(GetPlayerSteamId(player)),
            {...}
        ))
    end

    -- Action
    local query = mariadb_prepare(db, "UPDATE bans SET lifted = true WHERE targetid = ?", target)
    mariadb_async_query(db, query, OnUnbanAccount, player, target)
end
AddCommand("unban", cmd_Unban)

function OnUnbanAccount(player, target)
    AddPlayerChat(player, "SteamID "..target.." has been unbanned")
end

function cmd_Warn(player, target, ...)
    -- Usage: /warn <playerid> <reason>

    if(not (PlayerData[player].privilege >= config.admin_level.warn)) then
        return AddPlayerChat(player, "Insufficient permissions")
    end

    if(target == nil or #{...} == 0) then
        return AddPlayerChat(player, "Usage: /warn <playerid> <reason>")
    end

    target = tonumber(target)

    if(not (config.min_reason < #{...} and #{...} <= config.max_reason)) then
        return AddPlayerChat(player, "The reason should be between 3 characters to 128")
    end

    if(PlayerData[target].privilege > PlayerData[player].privilege) then
        return AddPlayerChat(player, "Cannot kick an admin higher in level than you")
    end

    -- Log
    if(config.log.warns == true) then
        mariadb_async_query(db, mariadb_prepare(db, "INSERT INTO warns (targetid, adminid, reason) VALUES (?, ?, ?)",
            tostring(GetPlayerSteamId(target)),
            tostring(GetPlayerSteamId(player)),
            {...}
        ))
    end

    -- Action
    PlayerData[target].warnings = PlayerData[target].warnings + 1
    if(PlayerData[target].warnings > config.max_warnings) then
        KickPlayer(target, "You have been kicked from the server for having too many warnings")
        AddPlayerChatAll(("Player %s(%d) has been kicked for too many warnings"):format(
            GetPlayerName(target),
            target,
            {...}
        ))
    end
end
AddCommand("warn", cmd_Warn)