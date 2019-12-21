local Dialog = ImportPackage("dialogui")
local _ = function(k,...) return ImportPackage("i18n").t(GetPackageName(),k,...) end

local hatshop
local isHatShop
local StreamedHatShopIds = {}
local HatShopIds = {}
local hatPurchased

AddEvent("OnTranslationReady", function()
    hatshop = Dialog.create(_("hat_shop"), nil, _("buy"), _("cancel"))
    Dialog.addSelect(hatshop, 1, _("hat_list"), 10)
end)

function OnKeyPress(key)
    if key == "E" then
        local NearestHatShop = GetNearestHatShop()
        if NearestHatShop ~= 0 then
            CallRemoteEvent("hatshop:Interact", NearestHatShop)
        end
    end
end
AddEvent("OnKeyPress", OnKeyPress)

AddEvent("OnDialogSubmit", function(dialog, button, ...)
    if dialog == hatshop then
        local NearestHatShop = GetNearestHatShop()
        local args = { ... }
        if button == 1 then
            if args[1] == "" then
                AddPlayerChat("Please Select a Hat...")
            else
                CallRemoteEvent("hatshop:Purchase", args[1], NearestHatShop)
            end
        end
    end
end)

AddRemoteEvent("hatshop:Setup", function(HatShopObject)
    HatShopIds = HatShopObject
end)

function GetNearestHatShop()
    local x, y, z = GetPlayerLocation()

    for k, v in pairs(GetStreamedNPC()) do
        local x2, y2, z2 = GetNPCLocation(v)
        local dist = GetDistance3D(x, y, z, x2, y2, z2)
        if dist < 200.0 then
            for k, i in pairs(HatShopIds) do
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

AddRemoteEvent("hatshop:Open", function(lhats)
    local hats = {}
    for k, v in pairs(lhats) do
        hats[k] = _(k).." [$" .. v .. "]"
    end
    Dialog.setSelectLabeledOptions(hatshop, 1, 1, hats)
    Dialog.show(hatshop)
end)