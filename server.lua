local QBCore = exports['qb-core']:GetCoreObject()

-- Successful scam
RegisterNetEvent('qb-scam:server:success', function(scamType, targetNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local scam = Config.ScamTypes[scamType]
    if not scam then return end

    -- Give reward
    if scam.reward.money then
        local amount = math.random(scam.reward.money.min, scam.reward.money.max)
        Player.Functions.AddMoney('cash', amount, "scam-npc")
        TriggerClientEvent('QBCore:Notify', src, "Scam successful! NPC gave you $"..amount, "success")
    elseif scam.reward.items then
        local item = scam.reward.items[math.random(1, #scam.reward.items)]
        Player.Functions.AddItem(item, 1)
        TriggerClientEvent('QBCore:Notify', src, "Scam successful! You got "..item, "success")
    end
end)

-- Failed scam
RegisterNetEvent('qb-scam:server:fail', function(scamType, targetNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local scam = Config.ScamTypes[scamType]
    if not scam then return end

    -- Deduct money
    local loss = math.random(10, 50)
    Player.Functions.RemoveMoney('cash', loss, "scam-failed")
    TriggerClientEvent('QBCore:Notify', src, "Scam failed! You lost $"..loss, "error")

    -- Risk consequences
    local risk = Config.ScamRisk[scamType] or {policeChance=0, attackChance=0}

    -- Police alert
    if math.random(1, 100) <= risk.policeChance then
        local playerPed = GetPlayerPed(src)
        local coords = GetEntityCoords(playerPed)
        for _, police in pairs(QBCore.Functions.GetPlayersByJob("police")) do
            TriggerClientEvent('qb-scam:client:policeBlip', police, coords)
            TriggerClientEvent('QBCore:Notify', police, "Scam attempt reported near your location!", "error")
        end
    end

    -- NPC attack
    if math.random(1, 100) <= risk.attackChance then
        local targetPed = NetworkGetEntityFromNetworkId(targetNetId)
        if targetPed and DoesEntityExist(targetPed) then
            local playerPed = GetPlayerPed(src)
            TaskCombatPed(targetPed, playerPed, 0, 16)
            TriggerClientEvent('QBCore:Notify', src, "The NPC is attacking you!", "error")
        end
    end
end)
