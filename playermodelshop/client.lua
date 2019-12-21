local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local modelshop
local isModelShop
local StreamedModelShopIds = {}
local ModelShopIds = {}
local modelPurchased

AddEvent("OnTranslationReady", function()
    modelshop = Dialog.create(_("playermodel_shop"), nil, _("buy"), _("cancel"))
    Dialog.addSelect(modelshop, 1, _("playermodel_list"), 10)
end)

function OnKeyPress(key)
    if key == "E" then
        local NearestModelShop = GetNearestModelShop()
        if NearestModelShop ~= 0 then
            AddPlayerChat("interacted")
            CallRemoteEvent("playermodelshop:Interact", NearestModelShop)
        end
    end
end
AddEvent("OnKeyPress", OnKeyPress)

AddEvent("OnDialogSubmit", function(dialog, button, ...)
    if dialog == modelshop then
        local NearestModelShop = GetNearestModelShop()
        local args = { ... }
        if button == 1 then
            if args[1] == "" then
                AddPlayerChat("Please Select a Player Model...")
            else
                CallRemoteEvent("playermodelshop:Purchase", args[1], NearestModelShop)
            end
        end
    end
end)

AddRemoteEvent("playermodelshop:Setup", function(ModelShopObject)
    ModelShopIds = ModelShopObject
    for k, v in pairs(ModelShopIds) do
        SetNPCClothingPreset(v, 23)
    end
end)

function GetNearestModelShop()
    local x, y, z = GetPlayerLocation()

    for k, v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
        local dist = GetDistance3D(x, y, z, x2, y2, z2)
        if dist < 200.0 then
            for k, i in pairs(ModelShopIds) do
                if v == i then
                    return v
                end
            end
        end
    end
    return 0
end


function tablefind(tab, el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end

AddRemoteEvent("playermodelshop:Open", function(lmodels)
    local models = {}
    for k, v in pairs(lmodels) do
        models[k] = _(k).." [$" .. v .. "]"
    end
    Dialog.setSelectLabeledOptions(modelshop, 1, 1, models)
    Dialog.show(modelshop)
end)

AddRemoteEvent("player:SetPlayerModel", function(modelid)
    --AddPlayerChat("set that bitch")
    local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(GetPlayerId(), "Body")
    SkeletalMeshComponent:SetSkeletalMesh(USkeletalMesh.LoadFromAsset("/Game/CharacterModels/" .. modelid))
    SkeletalMeshComponent:SetMaterial(3, UMaterialInterface.LoadFromAsset("/Game/CharacterModels/Materials/HZN_Materials/M_HZN_Body_NoShoesLegsTorso"))
end)

AddRemoteEvent("player:SetPlayerOutfit", function(player, outfit)
    if outfit ~= nil then SetPlayerClothingPreset(player, outfit) end
end)

AddRemoteEvent("player:SetSkinColor", function(r, g, b)
    local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(GetPlayerId(), "Body")
    SkeletalMeshComponent:SetColorParameterOnMaterials("Skin Color", FLinearColor(r, g, b, 0.0))
end)

AddRemoteEvent("player:SetHairModel", function(modelid)
    local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(GetPlayerId(), "Clothing0")
    SkeletalMeshComponent:SetSkeletalMesh(USkeletalMesh.LoadFromAsset("/Game/CharacterModels/" .. modelid))
end)

AddRemoteEvent("player:SetHairColor", function(r, g, b)
    local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(GetPlayerId(), "Clothing0")
    SkeletalMeshComponent:SetColorParameterOnMaterials("Hair Color", FLinearColor(r,g,b,0.0))    
end)

AddRemoteEvent("player:SetClothingShirt", function(modelid)
    local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(GetPlayerId(), "Clothing1")
    SkeletalMeshComponent:SetSkeletalMesh(USkeletalMesh.LoadFromAsset("/Game/CharacterModels/" .. modelid))
end)

AddRemoteEvent("player:SetClothingPants", function(modelid)
    local SkeletalMeshComponent = GetPlayerSkeletalMeshComponent(GetPlayerId(), "Clothing4")
    SkeletalMeshComponent:SetSkeletalMesh(USkeletalMesh.LoadFromAsset("/Game/CharacterModels/" .. modelid))
end)