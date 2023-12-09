Config = {}

Config.Keys = {
    ["ENTER"] = 0xC7B5340A, ['BACKSPACE'] = 0x156F7119,["DOWN"] = 0x05CA7C52,
}

Config.PromptsKeys = {
    ['DIG']            = {label = "Dig Grave",              key = 'ENTER'},
    ['CANCEL_ACTION']  = {label = "Cancel Action",          key = 'BACKSPACE'},
}

Config.ActionDistance   = 1.2

-----------------------------------------------------------
--[[ Discord Webhooking  ]]--
-----------------------------------------------------------

Config.Webhooking = { 
    Enable = true, 
    Url = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -- The discord webhook url.
    Color = 10038562,
}

-----------------------------------------------------------
--[[ General ]]--
-----------------------------------------------------------

Config.ShovelItem       = "shovel"
Config.DurabilityRemove = 4 -- Set to false if you don't want to remove any durability. (100% is maximum)
Config.Animation        = { "amb_work@world_human_gravedig@working@male_b@idle_a", "idle_a" }

Config.PoliceJob        = "police"

-- enabled, firsttext, secondtext, dict, icon, duration, color
Config.AlertPolice      = { 
    enabled = true, 
    first = "Police Department - %s", 
    second = "A Grave robbery was witnessed on %s cemetary.", 
    dict = "generic_textures", 
    icon = "temp_pedshot", 
    duration = 8000, 
    color = "COLOR_WHITE"
}

Config.MaxPolice        = 2

Config.DiggingTimer     = 15 -- (Seconds)

Config.KeyControls = { -- IF PLAYER HAVE THE SHOVEL EQUIPED, HE CANNOT USE THE CONTROLS BELOW.
    Disable = true,

    Controls = {
        [1] = 0x07CE1E61, -- MOUSE1
        [2] = 0xF84FA74F, -- MOUSE2
        [3] = 0xAC4BD4F1, -- TAB
        [4] = 0xCEFD9220, -- MOUNT
        [5] = 0x4CC0E2FE, -- B
        [6] = 0x8CC9CD42, -- X
        [7] = 0x26E9DC00, -- Z
        [8] = 0xDB096B85, -- CTRL       
    },

    InventoryControl = 0xC1989F95, -- The following control is disabled only while player is busy to prevent bugs.
}

-----------------------------------------------------------
--[[ Rewards  ]]--
-----------------------------------------------------------

-- You can use "nothing" and if it does select randomly the following, the player won't find anything.
-- It is an extra way to make the looting harder.
Config.Rewards = {
    { item = "nothing",       label = "Nothing"       , quantity = {0, 0} },
    
    { item = "goldbracelet",  label = "Gold Bracelet" , quantity = {1, 2} },
    { item = "goldnecklace",  label = "Gold Necklace" , quantity = {1, 2} },
    { item = "goldring",      label = "Gold Ring"     , quantity = {1, 2} },
    { item = 'goldtooth',     label = 'Gold Tooth'    , quantity = {1, 2} },
}


-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source is always null when called from client.
function SendNotification(source, message)
    local duration = 3000

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, duration)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, duration)
    end
  
end
