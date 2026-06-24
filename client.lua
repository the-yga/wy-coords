local UI = {
    open = false,
    mode = "player",
    mouse = true,
    laser = false,
    lastUpdate = 0
}


local function EntityValid(ent)
    return ent and ent ~= 0 and DoesEntityExist(ent)
end

local function GetModelSafe(ent)
    if not EntityValid(ent) then return 0 end

    local ok, model = pcall(GetEntityModel, ent)
    return ok and model or 0
end


local function SetUI(state)
    UI.open = state

    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(state)

    SendNUIMessage({
        action = state and "open" or "close"
    })

    if not state then
        UI.laser = false
    end
end

RegisterCommand("wcoords", function()
    SetUI(not UI.open)
end)


CreateThread(function()
    while true do
        Wait(UI.open and 0 or 500)

        if UI.open and IsControlJustPressed(0,322) then
            SetUI(false)
        end
    end
end)


CreateThread(function()
    while true do
        Wait(UI.open and 0 or 500)

        if UI.open and IsControlJustPressed(0,19) then

            UI.mouse = not UI.mouse

            SetNuiFocus(UI.mouse, UI.mouse)
            SetNuiFocusKeepInput(true)

            lib.notify({
                title="WCoords",
                description = UI.mouse and "Mouse Enabled" or "Movement Enabled",
                type = UI.mouse and "success" or "inform"
            })

            Wait(300)
        end
    end
end)


CreateThread(function()

    while true do
        Wait(200)

        if not (UI.open and UI.mode == "player") then
            goto continue
        end

        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        SendNUIMessage({
            action = "player",
            vector2 = {x=coords.x,y=coords.y},
            vector3 = {x=coords.x,y=coords.y,z=coords.z},
            vector4 = {x=coords.x,y=coords.y,z=coords.z,h=heading},
            heading = heading
        })

        ::continue::
    end

end)


local function CameraDirection(rot)

    local z = math.rad(rot.z)
    local x = math.rad(rot.x)

    local cosX = math.abs(math.cos(x))

    return vector3(
        -math.sin(z) * cosX,
        math.cos(z) * cosX,
        math.sin(x)
    )
end


local function DrawEntityBox(entity)

    if not EntityValid(entity) then return end

    local model = GetModelSafe(entity)
    if model == 0 then return end

    local min,max = GetModelDimensions(model)

    local corners = {
        vector3(min.x,min.y,min.z),
        vector3(max.x,min.y,min.z),
        vector3(max.x,max.y,min.z),
        vector3(min.x,max.y,min.z),
        vector3(min.x,min.y,max.z),
        vector3(max.x,min.y,max.z),
        vector3(max.x,max.y,max.z),
        vector3(min.x,max.y,max.z)
    }

    local points = {}

    for i,v in ipairs(corners) do
        points[i] = GetOffsetFromEntityInWorldCoords(entity,v.x,v.y,v.z)
    end

    local lines = {
        {1,2},{2,3},{3,4},{4,1},
        {5,6},{6,7},{7,8},{8,5},
        {1,5},{2,6},{3,7},{4,8}
    }

    for _,l in ipairs(lines) do
        local a,b = points[l[1]],points[l[2]]

        DrawLine(a.x,a.y,a.z,b.x,b.y,b.z,0,150,255,255)
    end
end


CreateThread(function()

    while true do
        Wait(UI.laser and UI.open and 0 or 500)

        if not (UI.open and UI.laser) then
            goto continue
        end

        local cam = GetGameplayCamCoord()
        local dir = CameraDirection(GetGameplayCamRot(2))

        local dest = cam + dir * 800.0

        local ray = StartShapeTestRay(
            cam.x,cam.y,cam.z,
            dest.x,dest.y,dest.z,
            -1,PlayerPedId(),0
        )

        local _,hit,endCoords,_,entity = GetShapeTestResult(ray)

        DrawLine(cam.x,cam.y,cam.z,endCoords.x,endCoords.y,endCoords.z,255,0,0,255)

        DrawMarker(
            28,
            endCoords.x,endCoords.y,endCoords.z,
            0,0,0,0,0,0,
            0.08,0.08,0.08,
            255,0,0,180,
            false,false,2
        )

        if EntityValid(entity) then

            DrawEntityBox(entity)

            if GetGameTimer() - UI.lastUpdate > 250 then

                local coords = GetEntityCoords(entity)

                local type = "Entity"
                if IsEntityAVehicle(entity) then type="Vehicle"
                elseif IsEntityAPed(entity) then type="Ped"
                elseif IsEntityAnObject(entity) then type="Object"
                end

                SendNUIMessage({
                    action="laser",
                    type=type,
                    model=GetModelSafe(entity),
                    id=entity,
                    distance = #(GetEntityCoords(PlayerPedId()) - coords),

                    vector3={
                        x=coords.x,
                        y=coords.y,
                        z=coords.z
                    },

                    vector4={
                        x=coords.x,
                        y=coords.y,
                        z=coords.z,
                        h=GetEntityHeading(entity)
                    }
                })

                UI.lastUpdate = GetGameTimer()
            end
        end

        ::continue::
    end

end)


RegisterNUICallback("mode", function(data,cb)

    UI.mode = data.mode
    UI.laser = data.mode == "laser"

    cb("ok")
end)

RegisterNUICallback("copy", function(data,cb)

    lib.setClipboard(data.text)

    lib.notify({
        title="WCoords",
        description="Copied",
        type="success"
    })

    cb("ok")
end)

RegisterNUICallback("close", function(_,cb)
    SetUI(false)
    cb("ok")
end)
