
ClientData = { 
    graveIndex      = 0, 
    isDoingAction   = false, 
    isDigging       = false, 
    isHoldingShovel = false, 
    shovelTool      = nil,
    durability      = 100,
    itemId          = 0,
}

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

-- When resource stops, we remove the attached shovel object from the player (if exists).
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if ClientData.isHoldingShovel then

        ClearPedTasks(PlayerPedId())
        Citizen.InvokeNative(0xED00D72F81CF7278, ClientData.shovelTool, 1, 1)
        DeleteObject(ClientData.shovelTool)
        Citizen.InvokeNative(0x58F7DB5BD8FA2288, PlayerPedId()) -- Cancel Walk Style

        ClientData.isHoldingShovel = false
    end

end)


-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

-- When following event is triggered, if the player is not holding any shovel, we attach it, otherwise we detach the shovel.
RegisterNetEvent('tpz_grave_robberies:onShovelItemUse')
AddEventHandler('tpz_grave_robberies:onShovelItemUse', function(itemId, durability)
    local playerPed = PlayerPedId()

    ClientData.itemId     = itemId
    ClientData.durability = durability

    if not ClientData.isHoldingShovel then

        ClientData.isHoldingShovel = true

        OnShovelEquip()
    else

        ClearPedTasks(playerPed)
        Citizen.InvokeNative(0xED00D72F81CF7278, ClientData.shovelTool, 1, 1)
        DeleteObject(ClientData.shovelTool)
        Citizen.InvokeNative(0x58F7DB5BD8FA2288, playerPed) -- Cancel Walk Style

        ClientData.isHoldingShovel = false
    end
end)

-- The following event is triggered to update the current shovel durability during changes (actions).
RegisterNetEvent('tpz_grave_robberies:updateShovelDurability')
AddEventHandler('tpz_grave_robberies:updateShovelDurability', function(cb)
    ClientData.durability = cb
end)

RegisterNetEvent("tpz_grave_robberies:startGraveDigging")
AddEventHandler("tpz_grave_robberies:startGraveDigging", function(id)

    local currentTown = GetCurrentTown()

    TriggerEvent("tpz_core:ExecuteServerCallBack", "tpz_grave_robberies:hasOnlinePolice", function(hasMinimPolice)

        if hasMinimPolice then

            ClientData.isDoingAction = true
            ClientData.isDigging     = true

            local pedp               = PlayerPedId()
            local heading            = Locations.Graves[id].heading
            local anim               = Config.Animation

            SetEntityHeading(PlayerPedId(), heading)

            LoadAnim(anim)

            TaskPlayAnim(pedp, anim[1], anim[2], 1.0, 1.0, -1, 1, 0, false, false, false)

            Citizen.Wait(1000 * Config.DiggingTimer)

            if ClientData.isDoingAction and ClientData.isDigging then
                TriggerServerEvent("tpz_grave_robberies:onGraveRobberySuccess", ClientData.graveIndex)
            end

            ClearPedTasks(PlayerPedId())

            ClientData.isDoingAction = false
            ClientData.isDigging     = false

            if Config.DurabilityRemove then
                
                TriggerServerEvent("tpz_grave_robberies:removeDurability", ClientData.itemId)

                Wait(500)
                TriggerServerEvent("tpz_grave_robberies:requestDurability", ClientData.itemId)

            end

        else
            SendNotification(nil, Locales['NOT_POLICE'])
        end
    end, {town = currentTown, grave = ClientData.graveIndex })
end)

---------------------------------------------------------------
-- Threads
---------------------------------------------------------------


Citizen.CreateThread(function()

    CreatePrompts()

    while true do
        Citizen.Wait(0)

        local sleep        = true
        local player       = PlayerPedId()
        local isPlayerDead = IsEntityDead(player)
        --local currentTown  = GetCurrentTown()

        if not isPlayerDead and ClientData.isHoldingShovel then

            local coords = GetEntityCoords(player)

            for index, graveConfig in pairs(Locations.Graves) do

                local coordsDist = vector3(coords.x, coords.y, coords.z)
                local coordsStore = graveConfig.coords
                local distance = #(coordsDist - coordsStore)

                if (distance <= Config.ActionDistance) then -- check distance
                    sleep = false

                    ClientData.graveIndex = index

                    local label = CreateVarString(10, 'LITERAL_STRING', Locales['GRAVE'] .. graveConfig.name .. " | " .. ClientData.durability .. "%")
                    PromptSetActiveGroupThisFrame(Prompts, label)

                    for i, prompt in pairs (PromptsList) do

                        PromptSetEnabled(prompt.prompt, 0)

                        if ClientData.isDoingAction then
                            
                            if prompt.type == "CANCEL_ACTION" then
                                PromptSetEnabled(prompt.prompt, 1)
                            end

                        else
                            if prompt.type == "DIG" then
                                PromptSetEnabled(prompt.prompt, 1)

                            end
                        end

                        if PromptHasHoldModeCompleted(prompt.prompt) then

                            if prompt.type == "DIG" then
                                TriggerServerEvent("tpz_grave_robberies:checkGraveStatus", index, ClientData.itemId)

                            elseif prompt.type == "CANCEL_ACTION" then
                                if ClientData.isDoingAction then

                                    ClearPedTasks(PlayerPedId())

                                    ClientData.isDoingAction = false
                                    ClientData.isDigging     = false
                                else
                                    SendNotification(nil, Locales['NO_ACTION_TO_CANCEL'] )
                                end

                            end

                            Wait(2000)
                        end
                    end
                            
                end

            end

        end

        if sleep then
            Citizen.Wait(1000)
        end

    end
end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(1000)

        if ClientData.isDoingAction then
            TriggerEvent('tpz_inventory:closePlayerInventory')
        end

    end

end)