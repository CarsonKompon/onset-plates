local startPosX = 135773.0
local startPosY = 80246.0

function SpawnPlates()
    local i = 1
    local j = 1
    local possibleSpot = {}
    for k=1, 49 do
        table.insert( possibleSpot, k)
    end
    for _, v in pairs(GetAllPlayers()) do
        i = possibleSpot[math.random(1,#possibleSpot)]
        j = 1
        local p = i
        for k, v in pairs(possibleSpot) do
            if v == i then 
                p = v
            end
        end
        table.remove( possibleSpot, p)
        while(i > 7) do
            i = i - 7
            j = j + 1
        end
        SetPlayerLocation(v, startPosX + (1250 * i), startPosY + (1250 * j), 6200.0, 90.0)

        GivePlate(v, startPosX + (1250 * i), startPosY + (1250 * j), 6000.0)
    end
    if(gamemode.killbox ~= nil) then DestroyPickup(gamemode.killbox) end
    gamemode.killboxZ = 10.0
    gamemode.killbox = CreatePickup(335, startPosX + (1250 * 5), startPosY + (1250 * 5), 4000.0)
    SetPickupScale(gamemode.killbox, 100000, 100000, 10)
end

function CreateWalls()
    gamemode.wall1 = CreateObject(1, startPosX + (1250 * 4.5)+ (1250 * 4.5), startPosY + (1250 * 4.5), 6000.0)
    SetObjectScale(gamemode.wall1, 1000, 1, 350)
    SetObjectRotation(gamemode.wall1,0,-90,0)
    SetObjectPropertyValue(gamemode.wall1, "type", "walls", true)
    SetObjectStreamDistance(gamemode.wall1, 1000000)
    gamemode.wall2 = CreateObject(1, startPosX + (1250 * 4.5)- (1250 * 4.5), startPosY + (1250 * 4.5), 6000.0)
    SetObjectScale(gamemode.wall2, 1000, 1, 350)
    SetObjectRotation(gamemode.wall2,0,-90,0)
    SetObjectPropertyValue(gamemode.wall2, "type", "walls", true)
    SetObjectStreamDistance(gamemode.wall2, 1000000)
    gamemode.wall3 = CreateObject(1, startPosX + (1250 * 4.5), startPosY + (1250 * 4.5)+ (1250 * 4.5), 6000.0)
    SetObjectScale(gamemode.wall3, 1000, 1, 350)
    SetObjectPropertyValue(gamemode.wall3, "type", "walls", true)
    SetObjectStreamDistance(gamemode.wall3, 1000000)
    gamemode.wall4 = CreateObject(1, startPosX + (1250 * 4.5), startPosY + (1250 * 4.5)- (1250 * 4.5), 6000.0)
    SetObjectScale(gamemode.wall4, 1000, 1, 350)
    SetObjectPropertyValue(gamemode.wall4, "type", "walls", true)
    SetObjectStreamDistance(gamemode.wall4, 1000000)
end

function GivePlate(player, x, y, z)
    PlayerData[player].plate = CreateObject(3, x, y, z)
    PlayerData[player].plateText = CreateText3D(GetPlayerName(player) .. "'s Plate", 17, x, y, z+260, 0, 0, 0)
    --SetText3DAttached(PlayerData[player].plateText, 3, PlayerData[player].plate, x, y, z+130)
    CallRemoteEvent(player, "plates:ObjHitEvent", PlayerData[player].plate, true)
    SetObjectPropertyValue(PlayerData[player].plate, "type", "plate", true)
    PlayerData[player].plateScale = 1
    PlayerData[player].plateZ = z
    PlayerData[player].blind = 0
end

function ResetPlate(player)
    PlayerData[player].plateScale = 1
    PlayerData[player].plateZ = 6000.0
    if(PlayerData[player].plateLadder ~= nil) and (GetObjectPropertyValue(PlayerData[player].plateLadder, "type") == "ladder") then
        DestroyObject(PlayerData[player].plateLadder)
        PlayerData[player].plateLadder = nil
    end
    if(PlayerData[player].fence1 ~= nil) and
    (GetObjectPropertyValue(PlayerData[player].fence1, "type") == "ladder") and
    (GetObjectPropertyValue(PlayerData[player].fence2, "type") == "ladder") and
    (GetObjectPropertyValue(PlayerData[player].fence3, "type") == "ladder") and
    (GetObjectPropertyValue(PlayerData[player].fence4, "type") == "ladder") then
        DestroyObject(PlayerData[player].fence1)
        DestroyObject(PlayerData[player].fence2)
        DestroyObject(PlayerData[player].fence3)
        DestroyObject(PlayerData[player].fence4)
        PlayerData[player].fence1 = nil
        PlayerData[player].fence2 = nil
        PlayerData[player].fence3 = nil
        PlayerData[player].fence4 = nil
    end
    if(PlayerData[player].firebar ~= nil) then
        DestroyPickup(PlayerData[player].firebar)
        PlayerData[player].firebar = nil
    end
    for _, v in pairs(GetAllPickups()) do
        if(GetPickupPropertyValue(v, "player") == player) then
            DestroyPickup(v)
        end
    end
    PlayerData[player].spinning = nil
    PlayerData[player].poison = false
    PlayerData[player].shrinking = nil
end

function DestroyPlate(player)
    DestroyObject(PlayerData[player].plate)
    DestroyText3D(PlayerData[player].plateText)
    ResetPlate(player)
end