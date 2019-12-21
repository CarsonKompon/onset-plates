local gui = nil

local function OnPackageStart()
    local width, height = GetScreenSize()
    gui = CreateWebUI(0.0,0.0,width,height,5,10)
    LoadWebFile(gui, "http://asset/" .. GetPackageName() .. "/gui/plates/index.html")
    --SetWebAlignment(gui, 0.5, 1)
    --SetWebAnchors(gui, 0.5, 0.5, 0.5, 0.5)
    SetWebLocation(gui, width/3, 0)
    SetWebVisibility(gui, WEB_HITINVISIBLE)
end
AddEvent("OnPackageStart", OnPackageStart)

function ObjHitEvent(object, enabled)
    EnableObjectHitEvents(object , enabled)
end
AddRemoteEvent("plates:ObjHitEvent", ObjHitEvent)

local function ui_updateText(id, message)
    ExecuteWebJS(gui, "updateText('" .. id .. "', '" .. message .. "');")
    SetWebVisibility(gui, WEB_HITINVISIBLE)
end
AddRemoteEvent("plates:updateText", ui_updateText)

function changeCam(enabled)
    EnableFirstPersonCamera(enabled)
    if enabled then SetNearClipPlane(25) end
end
AddRemoteEvent("plates:ChangeCam", changeCam)

function SetCamFade(from, to, duration)
    StartCameraFade(from, to, duration, "#000")
end
AddRemoteEvent("plates:SetCamFade", SetCamFade)