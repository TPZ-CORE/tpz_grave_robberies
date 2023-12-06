local TPZ    = {}
local TPZInv = exports.tpz_inventory:getInventoryAPI()

local Graves = {}

TriggerEvent("getTPZCore", function(cb) TPZ = cb end)

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    Graves = nil
    Graves = {}
end)
-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

-- When the following event is triggered when a player is trying to rob a grave and we need to check the grave's status.
RegisterServerEvent("tpz_grave_robberies:checkGraveStatus")
AddEventHandler("tpz_grave_robberies:checkGraveStatus", function(graveId, itemId)
    local _source = source

    if Graves[graveId] ~= nil then
        SendNotification(_source, Locales['GRAVE_ALREADY_ROBBED'] )
        return
    end

    local currentDurability = TPZInv.getItemDurability(_source, Config.ShovelItem, itemId)

    if currentDurability <= 0 then
		SendNotification(_source, Locales['NOT_DURABILITY'])
		return
	end

	TriggerClientEvent("tpz_grave_robberies:startGraveDigging", _source, graveId)
end)

-- The following event is triggered to update the current shovel durability in client side for updating properly.
RegisterServerEvent("tpz_grave_robberies:requestDurability")
AddEventHandler("tpz_grave_robberies:requestDurability", function(itemId)
	local _source           = source

    local currentDurability = TPZInv.getItemDurability(_source, Config.ShovelItem, itemId)
    TriggerClientEvent('tpz_grave_robberies:updateShovelDurability', _source, currentDurability)
end)

-- The following event is triggered on every action in order to remove the requested durability.
RegisterServerEvent("tpz_grave_robberies:removeDurability")
AddEventHandler("tpz_grave_robberies:removeDurability", function(itemId)
	local _source           = source

    local currentDurability = TPZInv.getItemDurability(_source, Config.ShovelItem, itemId)

    if currentDurability <= 0 then
        return
    end

	TPZInv.removeItemDurability(_source, Config.ShovelItem, Config.DurabilityRemove, itemId, false)

    -- We check if the amount we removed goes to 0, to remove the shovel from the player hands after finishing the grave robbery.
    if (currentDurability - Config.DurabilityRemove) <= 0 then
        TriggerClientEvent('tpz_grave_robberies:onShovelItemUse', _source, 0, 100)
    end

end)

-- The following event is triggered when successfully robbed a grave, in order to give rewards.
RegisterServerEvent("tpz_grave_robberies:onGraveRobberySuccess")
AddEventHandler("tpz_grave_robberies:onGraveRobberySuccess", function(graveId)
    local _source         = source

    local xPlayer         = TPZ.GetPlayer(_source)
    local identifier      = xPlayer.getIdentifier()
    local charidentifier  = xPlayer.getCharacterIdentifier()
    local steamName       = GetPlayerName(_source)

    local webhookData     = Config.Webhooking
    local message         = "**Steam name: **`" .. steamName .. "`**\nIdentifier: **`" .. identifier .. " (Char: " .. charidentifier .. ") `"

    if Graves[graveId] ~= nil then
        SendNotification(_source, Locales['GRAVE_ALREADY_ROBBED'] )
        return
    end

    Graves[graveId]   = true

    local randomItem  = Config.Rewards[ math.random( #Config.Rewards ) ]
    local item, label = randomItem.item, randomItem.label
    
    if item ~= "nothing" then
        
        local quantity     = math.random(randomItem.quantity[1], randomItem.quantity[2])
        local canCarryItem = TPZInv.canCarryItem(_source, item, quantity)

        if canCarryItem then

            TPZInv.addItem(_source, item, quantity, nil)

            SendNotification(_source, string.format(Locales['SUCCESSFULLY_FOUND'], quantity, label))

            if webhookData.Enable then
                local title = "🥄` The following player found X" .. quantity .. " " .. label .. ".`"
                TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
            end

        else
            SendNotification(_source, Locales['GRAVE_WAS_EMPTY'])

            local title = "🥄` The following haven't found anything.`"
            TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
        end

    else
        SendNotification(_source, Locales['GRAVE_WAS_EMPTY'])

        local title = "🥄` The following haven't found anything.`"
        TriggerEvent("tpz_core:sendToDiscord", webhookData.Url, title, message, webhookData.Color)
    end
end)


--------------------------------------------------------------------------------------------------------
-- Callbacks
--------------------------------------------------------------------------------------------------------

exports.tpz_core:rServerAPI().addNewCallBack("tpz_grave_robberies:hasOnlinePolice", function(source, cb, data)

    local jobPlayerList     = TPZ.GetJobPlayers(Config.PoliceJob)

    if Config.AlertPolice.enabled then

        if jobPlayerList.count >= 0 then

            local notify = Config.AlertPolice

            for _i, allowedPlayer in pairs (jobPlayerList.players) do
  
                TriggerClientEvent('tpz_core:sendLeftNotification', allowedPlayer.source, string.format(notify.first, data.town), string.format(notify.second, data.town), notify.dict, notify.icon, notify.duration, notify.color)
            end
    
        end

    end

    cb(jobPlayerList.count >= Config.MaxPolice)
end)