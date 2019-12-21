-- Main gamemode events
function GameTimer()
    gamemode.currentTimer = gamemode.currentTimer + 1

    displayText = ""

    if(gamemode.gameState == "WAITING") then
        displayText = "Waiting for players..."
        if(#GetAllPlayers() >= 1) then
            gamemode.gameState = "STARTING"
            gamemode.currentTimer = 0
        end
    elseif(gamemode.gameState == "INTERMISSION") then
        if(gamemode.killbox ~= nil) then
            DestroyPickup(gamemode.killbox)
            gamemode.killbox = nil
        end
        if(gamemode.currentTimer <= 10) then
            if(gamemode.currentTimer == 1) then
                PlayerData[gamemode.lastWinner].cash = PlayerData[gamemode.lastWinner].cash + gamemode.winReward
                PlayerData[gamemode.lastWinner].wins = PlayerData[gamemode.lastWinner].wins + 1
            end
            displayText = "WINNER: " .. GetPlayerName(gamemode.lastWinner) .. "! Reward: $" .. tostring(gamemode.winReward)
        else
            if(gamemode.ingame ~= nil) and (#gamemode.ingame > 0) then
                for _, v in pairs(gamemode.ingame) do
                    DestroyPlate(v)
                    SetPlayerLocation(v, 125773.000000, 80246.000000, 1645.000000, 90.0)
                end
            end
            displayText= "Intermission. Next game starts in " .. tostring(31 - gamemode.currentTimer) .. "..."
        end
        if(gamemode.currentTimer >= 30) then
            gamemode.gameState = "STARTING"
            gamemode.currentTimer = 0
        
            --[[
            for _, v in pairs(GetAllNPC()) do
                DestroyNPC(v)
            end
            ]]--
            for _, v in pairs(GetAllVehicles()) do
                DestroyVehicle(v)
            end
            for _, v in pairs(GetAllPickups()) do
                if GetPickupPropertyValue(v, "type") == "mine" then
                    DestroyPickup(v)
                end
            end
        end
    elseif(gamemode.gameState == "STARTING") then
        displayText = "Game starting in " .. tostring(6 - gamemode.currentTimer) .. "..."
        if(gamemode.currentTimer >= 5) then
            gamemode.ingame = GetAllPlayers()
            gamemode.gameStart = true
            SpawnPlates()
            --CreateWalls()
            gamemode.gameState = "IDLE"
            gamemode.currentTimer = 0
        end
    elseif(gamemode.gameState == "IDLE") then
        displayText = "Next command in " .. tostring(4 - gamemode.currentTimer) .. "..."
        if(gamemode.currentTimer >= 3) then
            if(math.random(100) <= 10) then
                gamemode.commandType = 2
            else
                gamemode.commandType = 1
            end
            gamemode.commands = events[gamemode.commandType]
            gamemode.command = math.random(1, #gamemode.commands)
            gamemode.gameState = "COMMANDING"
            gamemode.currentTimer = 0
        end
    elseif(gamemode.gameState == "COMMANDING") then
        if(gamemode.commandType == 1) then
            displayText = tostring(gamemode.effecting) .. tostring(gamemode.commands[gamemode.command]) .. tostring(6 - gamemode.currentTimer) .. "..."
        else
            displayText = tostring(gamemode.commands[gamemode.command]) .. tostring(6 - gamemode.currentTimer) .. "..."
        end
        gamemode.effected = {}
        if(gamemode.currentTimer >= 5) then
            if(#gamemode.ingame > 0) then
                for i = 1, gamemode.effecting do
                    repeat
                        gamemode.effected[i] = math.random(1,#gamemode.ingame)
                    until(gamemode.effected[i] ~= nil)
                end
            end
            gamemode.gameState = "EFFECT"
            gamemode.currentTimer = 0
        end
    elseif(gamemode.gameState == "EFFECT") then
        displayText = "Effected players: "
        for _, v in pairs(gamemode.ingame) do
            PlayerData[v].cash = PlayerData[v].cash + 1
        end
        if(gamemode.effected ~= nil) then
            for _, v in pairs(gamemode.effected) do
                displayText = displayText .. GetPlayerName(v) .. " "
            end
        end
        if(gamemode.currentTimer == 1) and gamemode.effected ~= nil then
            for _, v in pairs(gamemode.effected) do
                if(PlayerData[v].plate ~= nil) then
                    if(gamemode.commandType == 1) then EffectPlate(v,gamemode.command)
                    else EffectGame(gamemode.command) end
                    PlayerData[v].cash = PlayerData[v].cash + 1
                end
            end
        end
        if(gamemode.currentTimer >= 3) then
            gamemode.effected = nil
            gamemode.gameState = "IDLE"
            gamemode.currentTimer = 0
        end
    end

    for _, v in pairs(GetAllPlayers()) do
        CallRemoteEvent(v, "plates:updateText", "header", displayText)
        CallRemoteEvent(v, "plates:updateText", "tab1", '<i class="fas fa-trophy"></i> ' .. PlayerData[v].wins .. ' Wins ')
        CallRemoteEvent(v, "plates:updateText", "tab2", '<i class="fas fa-money-bill-alt"></i> $' .. PlayerData[v].cash)
        CallRemoteEvent(v, "plates:updateText", "tab3", '<i class="fas fa-skull"></i> ' .. PlayerData[v].deaths .. ' Deaths ')
        --print(PlayerData[v].wins .. " " .. PlayerData[v].deaths .. " $" .. PlayerData[v].cash)
        if(PlayerData[v].blind ~= nil) and (PlayerData[v].blind > 0) then
            PlayerData[v].blind = PlayerData[v].blind - 1
            if(PlayerData[v].blind == 0) then CallRemoteEvent(v, "plates:SetCamFade", 0.9, 0.0, 5.0)
            else CallRemoteEvent(v, "plates:SetCamFade", 0.9, 0.9, 2.0) end
        end
    end
    --AddPlayerChatAll(tostring(gamemode.currentTimer))

    --[[
    for _, v in pairs(GetAllNPC()) do
        local atkp = GetNPCPropertyValue(v, "attacking")
        local x, y, z = GetPlayerLocation(atkp)
        SetNPCTargetLocation(v, x, y, z , 50)
    end
    ]]--

    if(#gamemode.ingame > 0) then
        for _, v in pairs(gamemode.ingame) do
            if(PlayerData[v].shrinking ~= nil) then
                PlayerData[v].plateScale = PlayerData[v].plateScale - PlayerData[v].shrinking
            end
        end
    end

    gamemode.killboxZ = gamemode.killboxZ + 0.01
end

function CheckGameOver()
    local count = 0
    for _, v in pairs(gamemode.ingame) do
        if(v ~= nil) then
            count = count + 1
        end
    end
    if count <= 1 then
        gamemode.ingame = {}
        gamemode.gameStart = false
        gamemode.gameState = "INTERMISSION"
        gamemode.currentTimer = 0
    end
end