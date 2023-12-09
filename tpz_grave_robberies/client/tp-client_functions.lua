
-----------------------------------------------------------
--[[ Prompts  ]]--
-----------------------------------------------------------

Prompts       = GetRandomIntInRange(0, 0xffffff)
PromptsList   = {}

CreatePrompts = function()

    for index, tprompt in pairs (Config.PromptsKeys) do

        local str = tprompt.label
        local keyPress = Config.Keys[tprompt.key]
    
        local dPrompt = PromptRegisterBegin()
        PromptSetControlAction(dPrompt, keyPress)
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(dPrompt, str)
        PromptSetEnabled(dPrompt, 1)
        PromptSetVisible(dPrompt, 1)
        PromptSetStandardMode(dPrompt, 1)
        PromptSetHoldMode(dPrompt, 1000)
        PromptSetGroup(dPrompt, Prompts)
        Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
        PromptRegisterEnd(dPrompt)
    
        table.insert(PromptsList, {prompt = dPrompt, type = index})
    end

end

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

OnShovelEquip = function()

    if ClientData.isHoldingShovel then
        DeleteEntity(ClientData.shovelTool)
    end

    Wait(500)

    local playerPed = PlayerPedId()
    
    LoadModel("p_shovel02x")

    ClientData.shovelTool = CreateObject( "p_shovel02x", GetOffsetFromEntityInWorldCoords(playerPed,0.0,0.0,0.0), true, true, true)

    AttachEntityToEntity(ClientData.shovelTool, playerPed, GetPedBoneIndex(playerPed, 7966), 0.0,0.0,0.0,  0.0,0.0,0.0, 0, 0, 0, 0, 2, 1, 0, 0);

    Citizen.InvokeNative(0x923583741DC87BCE, playerPed, 'arthur_healthy')
    Citizen.InvokeNative(0x89F5E7ADECCCB49C, playerPed, "carry_pitchfork")
    Citizen.InvokeNative(0x2208438012482A1A, playerPed, true, true)
    ForceEntityAiAndAnimationUpdate(ClientData.shovelTool, 1)
    Citizen.InvokeNative(0x3A50753042B6891B, playerPed, "PITCH_FORKS")
end

AttachEnt = function(from, to, boneIndex, x, y, z, pitch, roll, yaw, useSoftPinning, collision, vertex, fixedRot)
    return AttachEntityToEntity(from, to, boneIndex, x, y, z, pitch, roll, yaw, false, useSoftPinning, collision, false, vertex, fixedRot, false, false)
end


GetCurrentTown = function()

    local x, y, z          = table.unpack(GetEntityCoords(PlayerPedId()))
    local ZoneTypeId       = 1
    local currentDistrict = Citizen.InvokeNative(0x43AD8FC02B429D33, x, y, z, ZoneTypeId)

    if Locations.TownListHashes[currentDistrict] then
        return Locations.TownListHashes[currentDistrict]
    end

    return "UNKNOWN"

end

LoadModel = function(model)
    local model = GetHashKey(model)
    RequestModel(model)

    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(10)
    end
end

LoadAnim = function(anim)

    RequestAnimDict(anim[1])
    while not HasAnimDictLoaded(anim[1]) do RequestAnimDict(anim[1])
        Citizen.Wait(100)
    end

end

CanPlayerDoAction = function(player)
    if IsPedOnMount(player) or IsPedInAnyVehicle(player) or IsPedDeadOrDying(player) or IsEntityInWater(player) or IsPedClimbing(player) or not IsPedOnFoot(player) then
        return false
    end

    return true
end
