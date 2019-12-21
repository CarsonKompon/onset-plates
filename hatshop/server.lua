local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

allhats = {
    hat_404 = 300,
    hat_405 = 200,
    hat_406 = 400,
    hat_407 = 300,
    hat_414 = 350,
    hat_415 = 400,
    hat_416 = 700,
    hat_417 = 600,
    hat_418 = 500,
    hat_419 = 450,
    hat_420 = 500,
    hat_421 = 300,
    hat_423 = 250,
    hat_424 = 1000,
    hat_425 = 800,
    hat_426 = 500,
    hat_427 = 650,
    hat_428 = 2000,
    hat_433 = 1500,
    hat_434 = 1000,
    hat_435 = 4000,
    hat_436 = 3000,
    hat_437 = 500,
    hat_438 = 350,
}

HatShopDealersCached = {}
HatShopDealers = {
    {
        hats = allhats,
        location = {124000, 78708, 1566, 0}
    },
    {
        hats = allhats,
        location = {128661, 77620, 1576, 90}
    }
}

AddEvent("OnPackageStart", function()
    for k, v in pairs(HatShopDealers) do
        v.npc = CreateNPC(v.location[1], v.location[2], v.location[3], v.location[4])
        CreateText3D(_("hat_shop").."\n".."(Press E)", 18, v.location[1], v.location[2], v.location[3]+120, 0, 0, 0)
        local hm = CreateObject(math.random(398,477), v.location[1], v.location[2], v.location[3])
        SetObjectAttached(hm, 4, v.npc, 14.0, 0.0, 0.0, 0.0, 90.0, -90.0, "head")
        
        table.insert(HatShopDealersCached, v.npc)
    end
end)

AddEvent("OnPlayerJoin", function(player)
    CallRemoteEvent(player, "hatshop:Setup", HatShopDealersCached)
end)

AddRemoteEvent("hatshop:Interact", function(player, hatshopobject)
    local hatshop = GetHatShopByObject(hatshopobject)
    if hatshop then
        local x, y, z = GetNPCLocation(hatshop.npc)
        local x2, y2, z2 = GetPlayerLocation(player)
        local dist = GetDistance3D(x,y,z,x2,y2,z2)
        if dist < 200 then
            for k, v in pairs(HatShopDealers) do
                if hatshopobject == v.npc then
                    CallRemoteEvent(player, "hatshop:Open", v.hats)
                end
            end
        end
    end
end)

function GetHatShopByObject(hatshopobject)
    for k, v in pairs(HatShopDealers) do
        if v.npc == hatshopobject then
            return v
        end
    end
    return nil
end

function GetHatPrice(modelid, hatshopobject)
    for k, v in pairs(HatShopDealers) do
        if v.npc == hatshopobject then
            return(v.hats[modelid])
        end
    end
end

function GetHatId(modelid)
    return modelid:gsub("hat_", "")
end

AddRemoteEvent("hatshop:Purchase", function(player, modelid, hatshopobject)
    local name = _(modelid)
    local price = GetHatPrice(modelid, hatshopobject)
    local modelid = GetHatId(modelid)
    --print(modelid)

    if tonumber(price) > PlayerData[player].cash then
        AddPlayerChat(player, _("no_money"))
    else
        local x, y, z = GetPlayerLocation(player)

        for k, v in pairs(HatShopDealers) do
            local x2, y2, z2 = GetNPCLocation(v.npc) 
            local dist = GetDistance3D(x, y, z, x2, y2, z2)
            if dist < 200.0 then
                if(PlayerData[player].hatobj ~= nil) then
                    DestroyObject(PlayerData[player].hatobj)
                    PlayerData[player].hatobj = nil
                end
                PlayerData[player].hat = tonumber(modelid)
                SetPlayerHat(player)
                PlayerData[player].cash = PlayerData[player].cash - tonumber(price)
            end
        end
    end
end)