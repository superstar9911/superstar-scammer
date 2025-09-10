local QBCore = exports['qb-core']:GetCoreObject()
local scamCooldown = false

-- Add target to all NPCs
Citizen.CreateThread(function()
    exports['qb-target']:AddGlobalPed({
        options = {
            {
                type = "client",
                icon = "fas fa-handshake",
                label = "Attempt Scam",
                action = function(entity)
                    OpenScamMenu(entity)
                end,
                canInteract = function(entity)
                    return not scamCooldown and DoesEntityExist(entity)
                        and not IsPedDeadOrDying(entity, true)
                        and not IsPedAPlayer(entity)
                end
            }
        },
        distance = 3.0
    })
end)

-- Open scam menu
function OpenScamMenu(target)
    local menuOptions = {}
    for k, v in pairs(Config.ScamTypes) do
        table.insert(menuOptions, {
            header = v.name,
            txt = v.description,
            params = {
                event = "qb-scam:client:attemptScam",
                args = {
                    scamType = k,
                    target = target
                }
            }
        })
    end
    exports['qb-menu']:openMenu(menuOptions)
end

-- Scam minigame with immediate 15s timeout, guaranteed success if correct
function StartScamMinigame(cb)
    local keys = {"1", "2", "3", "4", "W", "A", "S", "D"}
    local sequence = {}
    for i = 1, 4 do
        table.insert(sequence, keys[math.random(1, #keys)])
    end
    local code = table.concat(sequence, "")

    local timedOut = false

    -- Start 15-second timer immediately
    Citizen.SetTimeout(15000, function()
        timedOut = true
    end)

    local dialog = exports['qb-input']:ShowInput({
        header = "Scam Minigame (15s to type)",
        submitText = "Submit",
        inputs = {
            {
                text = "Enter code: " .. code,
                name = "attempt",
                type = "text",
                isRequired = true
            }
        }
    })

    -- Fail if timeout triggered
    if timedOut then
        QBCore.Functions.Notify("Time's up! Scam failed.", "error")
        cb(false)
        return
    end

    if not dialog or not dialog.attempt then
        cb(false)
        return
    end

    if dialog.attempt:upper() == code then
        cb(true) -- success guaranteed
    else
        cb(false)
    end
end

-- Scam attempt
RegisterNetEvent('qb-scam:client:attemptScam', function(data)
    local scamType = Config.ScamTypes[data.scamType]
    local playerPed = PlayerPedId()
    local targetPed = data.target

    if #(GetEntityCoords(playerPed) - GetEntityCoords(targetPed)) > Config.MaxDistance then
        QBCore.Functions.Notify("Target is too far away", "error")
        return
    end

    -- Animation
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)
    Citizen.Wait(2000)
    ClearPedTasks(playerPed)

    -- Minigame
    StartScamMinigame(function(miniSuccess)
        if not miniSuccess then
            TriggerServerEvent('qb-scam:server:fail', data.scamType, NetworkGetNetworkIdFromEntity(targetPed))
            return
        end

        -- If minigame passed, scam is automatically successful
        TriggerServerEvent('qb-scam:server:success', data.scamType, NetworkGetNetworkIdFromEntity(targetPed))
    end)

    -- Cooldown
    scamCooldown = true
    Citizen.SetTimeout(Config.ScamCooldown * 1000, function()
        scamCooldown = false
    end)
end)

-- Police blip handler
RegisterNetEvent('qb-scam:client:policeBlip', function(coords)
    local blip = AddBlipForRadius(coords.x, coords.y, coords.z, Config.BlipRadius)
    SetBlipColour(blip, Config.BlipColor)
    SetBlipAlpha(blip, 150)

    local blipCenter = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipCenter, 161)
    SetBlipScale(blipCenter, 0.8)
    SetBlipColour(blipCenter, Config.BlipColor)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Scam Report Area")
    EndTextCommandSetBlipName(blipCenter)

    Citizen.SetTimeout(Config.BlipDuration * 1000, function()
        if DoesBlipExist(blip) then RemoveBlip(blip) end
        if DoesBlipExist(blipCenter) then RemoveBlip(blipCenter) end
    end)
end)
