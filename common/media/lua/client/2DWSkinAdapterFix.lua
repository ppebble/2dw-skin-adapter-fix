local adapterSkinIndexes = {
    ["Base.2dw_skinmaskp"] = 3, -- FemaleBody04 / pink adapter
    ["Base.2dw_skinmaskw"] = 4, -- FemaleBody05 / white adapter
}

local savedSkinIndexKey = "2DWSkinAdapterFix.skinIndex"
local directSkinIndexes = { [3] = true, [4] = true }
local applyingAdapter = false

local function findWornAdapter(player)
    local wornItems = player:getWornItems()
    for index = 0, wornItems:size() - 1 do
        local item = wornItems:get(index):getItem()
        local skinIndex = item and adapterSkinIndexes[item:getFullType()]
        if skinIndex then
            return item, skinIndex
        end
    end

    return nil, nil
end

local function hasWorn2DWHead(player)
    local wornItems = player:getWornItems()
    for index = 0, wornItems:size() - 1 do
        local item = wornItems:get(index):getItem()
        if item and item:getBodyLocation() == "tdw:stylehead" then
            return true
        end
    end

    return false
end

local function getSelectedSkinIndex(player, wornSkinIndex, humanVisual)
    if wornSkinIndex then
        local modData = player:getModData()
        if modData[savedSkinIndexKey] ~= wornSkinIndex then
            modData[savedSkinIndexKey] = wornSkinIndex
            if isClient() then
                player:transmitModData()
            end
        end
        return wornSkinIndex
    end

    local directSkinIndex = humanVisual:getSkinTextureIndex()
    if hasWorn2DWHead(player) and directSkinIndexes[directSkinIndex] then
        local modData = player:getModData()
        if modData[savedSkinIndexKey] ~= directSkinIndex then
            modData[savedSkinIndexKey] = directSkinIndex
            if isClient() then
                player:transmitModData()
            end
            print("[2DWSkinAdapterFix] Saved direct 2DW head skin index " .. tostring(directSkinIndex))
        end
        return directSkinIndex
    end

    return player:getModData()[savedSkinIndexKey]
end

local function applyWornAdapter(player)
    if applyingAdapter or not player then
        return
    end

    local adapter, wornSkinIndex = findWornAdapter(player)
    local humanVisual = player:getHumanVisual()
    if not humanVisual then
        return
    end
    local skinIndex = getSelectedSkinIndex(player, wornSkinIndex, humanVisual)
    if not skinIndex then
        return
    end

    applyingAdapter = true

    if adapter then
        -- The current 2D Wardrobe XML mask item is documented as non-functional
        -- on Build 42 and can hide or corrupt other clothing. Keep the item in
        -- the inventory instead of rendering the broken clothing layer.
        player:removeWornItem(adapter, false)
        player:getInventory():setDrawDirty(true)
    end

    -- Reapply the saved selection after every clothing update. Equipping a 2DW
    -- character mask rebuilds the visual and can otherwise restore the visible
    -- vanilla face underneath the flat character mask.
    humanVisual:setSkinTextureIndex(skinIndex)
    player:resetModelNextFrame()

    if isClient() then
        sendVisual(player)
    end

    if adapter then
        triggerEvent("OnClothingUpdated", player)
        print("[2DWSkinAdapterFix] Saved skin index " .. tostring(skinIndex)
            .. " from " .. adapter:getFullType() .. " and unequipped the broken adapter")
    end

    applyingAdapter = false
end

local function onCreatePlayer(_, player)
    applyWornAdapter(player)
end

Events.OnClothingUpdated.Add(applyWornAdapter)
Events.OnCreatePlayer.Add(onCreatePlayer)

