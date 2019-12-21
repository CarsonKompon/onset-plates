events = {
    { --Plate/Player Events
        " Plate(s) will slightly grow in ",
        " Plate(s) will slightly shrink in ",
        " Plate(s) will grow in ",
        " Plate(s) will shrink in ",
        " Plate(s) will start spinning in ",
        " Plate(s) will receive a new ladder in ",
        " Plate(s) will be fenced off in ",
        " Plate(s) will become toxic in ",
        " Player(s) will become big brain in ",
        " Player(s) will receive a pistol with 1 bullet in ",
        " Player(s) will gain 50 Armour in ",
        " Plate(s) will raise in ",
        " Plate(s) will lower in ",
        " Player(s) will be put in First Person in ",
        " Plate(s) will receive a landmine in ",
        " Plate(s) will get crushed by a car in ",
        " Plate(s) will shrink in half in ",
        " Plate(s) will start to shrink indefinitely in ",
        " Plate(s) will start to grow indefinitely in ",
        " Plate(s) will return to normal in ",
        " Player(s) vision will go dark for 1 minute in ",
        " Plate(s) will recieve a spinning death bar in "
    },
    { --Game Events
        "The Killbox will rise in ",
        "A safe place will appear in "
    }
}

function EffectPlate(player, command)
    print("Effecting " .. GetPlayerName(player) .. " with effect #" .. tostring(command))
    local plate = PlayerData[player].plate
    local x, y, z = GetObjectLocation(plate)
    local sx, sy, sz = GetObjectScale(plate)

    if command == 1 then
        PlayerData[player].plateScale = PlayerData[player].plateScale + 0.1
    elseif command == 2 then
        PlayerData[player].plateScale = PlayerData[player].plateScale - 0.15
    elseif command == 3 then
        PlayerData[player].plateScale = PlayerData[player].plateScale + 0.2
    elseif command == 4 then
        PlayerData[player].plateScale = PlayerData[player].plateScale - 0.25
    elseif command == 5 then
        if(PlayerData[player].spinning == nil) then
            PlayerData[player].spinning = 1
        else
            PlayerData[player].spinning = PlayerData[player].spinning + 1
        end
    elseif command == 6 then
        if(PlayerData[player].plateLadder ~= nil) then DestroyObject(PlayerData[player].plateLadder) end
        PlayerData[player].plateLadder = CreateObject(524, x+math.random(-250,250), y+math.random(-250,250), z-500, 0, math.random(360), 0)
        --SetObjectAttached(PlayerData[player].plateLadder, ATTACH_OBJECT, PlayerData[player].plate, 0, 0, 0)
        --SetObjectMoveTo(PlayerData[player].plateLadder, x, y, -400, 1000)
    elseif command == 7 then
        if(PlayerData[player].fence1 ~= nil) then
            DestroyObject(PlayerData[player].fence1)
            DestroyObject(PlayerData[player].fence2)
            DestroyObject(PlayerData[player].fence3)
            DestroyObject(PlayerData[player].fence4)
        end
        PlayerData[player].fence1 = CreateObject(876, x+250, y-250, z-500, 0, 90, 0)
        PlayerData[player].fence2 = CreateObject(876, x-250, y-250, z-500, 0, 90, 0)
        PlayerData[player].fence3 = CreateObject(876, x-250, y+250, z-500, 0, 0, 0)
        PlayerData[player].fence4 = CreateObject(876, x-250, y-250, z-500, 0, 0, 0)
    elseif command == 8 then
        PlayerData[player].poison = true
    elseif command == 9 then
        SetPlayerHeadSize(player, 2.0)
    elseif command == 10 then
        SetPlayerWeapon(player, 5, 1, true, 1, false)
    elseif command == 11 then
        local a = GetPlayerArmor(player) + 50
        if a > 100 then a = 100 end
        SetPlayerArmor(player, a)
    elseif command == 12 then
        if(PlayerData[player].firebar ~= nil) then
            DestroyPickup(PlayerData[player].firebar)
            PlayerData[player].firebar = "stillHas"
        end
        PlayerData[player].plateZ = PlayerData[player].plateZ + 75
    elseif command == 13 then
        if(PlayerData[player].firebar ~= nil) then
            DestroyPickup(PlayerData[player].firebar)
            PlayerData[player].firebar = "stillHas"
        end
        PlayerData[player].plateZ = PlayerData[player].plateZ - 100
    elseif command == 14 then
        CallRemoteEvent(player, "plates:ChangeCam", true)
    elseif command == 15 then
        PlayerData[player].plateMine = CreatePickup(1030, x+math.random(-250,250), y+math.random(-250,250), z)
        SetPickupPropertyValue(PlayerData[player].plateMine, "type", "mine", true)        
        SetPickupPropertyValue(PlayerData[player].plateMine, "player", player, true)
    elseif command == 16 then
        CreateVehicle(math.random(1,9),x+math.random(-200,200),y+math.random(-200,200),z+6000)
    elseif command == 17 then
        PlayerData[player].plateScale = PlayerData[player].plateScale / 2
        --[[ ZOMBIE STUFF
        local z = CreateNPC(x+math.random(-200,200), y+math.random(-200,200), z+200, math.random(360))
        for _, v in pairs(GetAllPlayers()) do
            CallRemoteEvent(v, "plates:NPCClothes", z, math.random(21,22))
        end
        --SetNPCFollowPlayer(z, player, 100)
        SetNPCPropertyValue(z, "attacking", player, true)
        ]]--
    elseif command == 18 then
        if PlayerData[player].shrinking == nil then
            PlayerData[player].shrinking = 0.00416
        else
            PlayerData[player].shrinking = PlayerData[player].shrinking + 0.00416
        end
    elseif command == 19 then
        if PlayerData[player].shrinking == nil then
            PlayerData[player].shrinking = -0.00208
        else
            PlayerData[player].shrinking = PlayerData[player].shrinking - 0.00208
        end
    elseif command == 20 then
        ResetPlate(player)
    elseif command == 21 then
        PlayerData[player].blind = 60
        CallRemoteEvent(player, "plates:SetCamFade", 0.0, 0.9, 1.0)
    elseif command == 22 then
        if(PlayerData[player].firebar ~= nil) then DestroyPickup(PlayerData[player].firebar) end
        PlayerData[player].firebar = CreatePickup(1, x, y, z)
        SetPickupScale(PlayerData[player].firebar, 1, 10, 1)
        SetPickupPropertyValue(PlayerData[player].firebar, "type", "firebar", true)
        SetPickupPropertyValue(PlayerData[player].firebar, "player", player, true)
    end

end

function EffectGame(command)
    print("Effecting The Game with Game Effect #" .. tostring(command))

    if command == 1 then
        gamemode.killboxZ = gamemode.killboxZ + 6
    elseif command == 2 then
        table.insert( gamemode.safePlates, CreateObject(3, 125773.0 + math.random(1250 * 8), 80246.0 + math.random(1250 * 8), 5850.0) )
    end
end