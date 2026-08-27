local adapterSkinIndexes = {
    ["Base.2dw_skinmaskp"] = 3, -- FemaleBody04 / pink adapter
    ["Base.2dw_skinmaskw"] = 4, -- FemaleBody05 / white adapter
}

local savedSkinIndexKey = "2DWSkinAdapterFix.skinIndex"
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

local function getSelectedSkinIndex(player, wornSkinIndex)
    if wornSkinIndex then
        player:getModData()[savedSkinIndexKey] = wornSkinIndex
        return wornSkinIndex
    end

    return player:getModData()[savedSkinIndexKey]
end

local function applyWornAdapter(player)
    if applyingAdapter or not player then
        return
    end

    local adapter, wornSkinIndex = findWornAdapter(player)
    local skinIndex = getSelectedSkinIndex(player, wornSkinIndex)
    if not skinIndex then
        return
    end

    local humanVisual = player:getHumanVisual()
    if not humanVisual then
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

