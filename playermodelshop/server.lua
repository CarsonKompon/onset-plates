local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

allmodels = {
    model_1 = 500,
    model_2 = 500,
    model_3 = 500,
    model_5 = 500,
    model_6 = 500,
    model_7 = 500,
    model_8 = 500,
    model_9 = 500,
    model_13 = 1000,
    model_14 = 700,
    model_15 = 700,
    model_16 = 700,
    model_17 = 1000,
    model_18 = 500,
    model_19 = 200,
    model_20 = 200,
    model_21 = 2500,
    model_22 = 3000,
    model_23 = 5000,
    model_24 = 6000,
    model_25 = 1000
}

PlayerModelDealersCached = {}
PlayerModelDealers = {
    {
        playermodels = allmodels,
        location = {123977, 78958, 1567, 0}
    },
    {
        playermodels = allmodels,
        location = {128661, 77620, 1576, 90}
    }
}

AddEvent("OnPackageStart", function()
    for k, v in pairs(PlayerModelDealers) do
        v.npc = CreateNPC(v.location[1], v.location[2], v.location[3], v.location[4])
        CreateText3D(_("playermodel_shop").."\n".."(Press E)", 18, v.location[1], v.location[2], v.location[3]+120, 0, 0, 0)
        
        table.insert(PlayerModelDealersCached, v.npc)
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "playermodelshop:Setup", PlayerModelDealersCached)
end)

AddRemoteEvent("playermodelshop:Interact", function(player, playermodelobject)
    print("interact")
    local modelshop = GetPlayerModelByObject(playermodelobject)
    if modelshop then
        local x, y, z = GetNPCLocation(modelshop.npc)
        local x2, y2, z2 = GetPlayerLocation(player)
        local dist = GetDistance3D(x,y,z,x2,y2,z2)
        if dist < 200 then
            for k, v in pairs(PlayerModelDealers) do
                if playermodelobject == v.npc then
                    print("open shop")
                    CallRemoteEvent(player, "playermodelshop:Open", v.playermodels)
                end
            end
        end
    end
end)

function GetPlayerModelByObject(playermodelobject)
    for k, v in pairs(PlayerModelDealers) do
        if v.npc == playermodelobject then
            return v
        end
    end
    return nil
end

function GetModelPrice(modelid, playermodelobject)
    for k, v in pairs(PlayerModelDealers) do
        if v.npc == playermodelobject then
            return(v.playermodels[modelid])
        end
    end
end

function GetModelPath(modelid)
    return modelid:gsub("model_", "")
end

AddRemoteEvent("playermodelshop:Purchase", function(player, modelid, playermodelobject)
    local name = _(modelid)
    local price = GetModelPrice(modelid, playermodelobject)
    local modelid = GetModelPath(modelid)
    print(modelid)

    if tonumber(price) > PlayerData[player].cash then
        AddPlayerChat(player, _("no_money"))
    elseif player ~= nil then
        local x, y, z = GetPlayerLocation(player)

        for k, v in pairs(PlayerModelDealers) do
            local x2, y2, z2 = GetNPCLocation(v.npc) 
            local dist = GetDistance3D(x, y, z, x2, y2, z2)
            if dist < 200.0 then
                PlayerData[player].cash = PlayerData[player].cash - tonumber(price)
                PlayerData[player].playermodel = tonumber(modelid)
                CallRemoteEvent(player, "player:SetPlayerOutfit", player, PlayerData[player].playermodel)
            end
        end
    end
end)