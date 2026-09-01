const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const modRoot = root;
const modInfo = fs.readFileSync(path.join(modRoot, "common", "mod.info"), "utf8");
const lua = fs.readFileSync(
  path.join(modRoot, "common", "media", "lua", "client", "2DWSkinAdapterFix.lua"),
  "utf8",
);

assert.match(modInfo, /^id=2DWSkinAdapterFix$/m);
assert.match(modInfo, /^require=42_VSGirlBodySFW,4123567854998$/m);
assert.match(modInfo, /^modversion=1\.0\.2$/m);
assert.match(lua, /\["Base\.2dw_skinmaskp"\] = 3/);
assert.match(lua, /\["Base\.2dw_skinmaskw"\] = 4/);
assert.match(lua, /local savedSkinIndexKey = "2DWSkinAdapterFix\.skinIndex"/);
assert.match(lua, /local directSkinIndexes = \{ \[3\] = true, \[4\] = true \}/);
assert.match(lua, /local function hasWorn2DWHead\(player\)/);
assert.match(lua, /item:getBodyLocation\(\) == "tdw:stylehead"/);
assert.match(lua, /modData\[savedSkinIndexKey\] = wornSkinIndex/);
assert.match(lua, /local directSkinIndex = humanVisual:getSkinTextureIndex\(\)/);
assert.match(lua, /hasWorn2DWHead\(player\) and directSkinIndexes\[directSkinIndex\]/);
assert.match(lua, /modData\[savedSkinIndexKey\] = directSkinIndex/);
assert.match(lua, /player:transmitModData\(\)/);
assert.match(lua, /return player:getModData\(\)\[savedSkinIndexKey\]/);
assert.match(lua, /player:removeWornItem\(adapter, false\)/);
assert.match(lua, /humanVisual:setSkinTextureIndex\(skinIndex\)/);
assert.match(lua, /Events\.OnClothingUpdated\.Add\(applyWornAdapter\)/);
assert.match(lua, /Events\.OnCreatePlayer\.Add\(onCreatePlayer\)/);
assert.match(lua, /if isClient\(\) then\s+sendVisual\(player\)/);

const removePosition = lua.indexOf("player:removeWornItem(adapter, false)");
const updatePosition = lua.indexOf("humanVisual:setSkinTextureIndex(skinIndex)");
assert.ok(removePosition >= 0 && updatePosition > removePosition, "broken adapter must be removed before applying skin");

const lookupPosition = lua.indexOf("local adapter, wornSkinIndex = findWornAdapter(player)");
const selectionPosition = lua.indexOf("local skinIndex = getSelectedSkinIndex(player, wornSkinIndex, humanVisual)");
const earlyReturnPosition = lua.indexOf("if not skinIndex then");
assert.ok(
  lookupPosition >= 0 && selectionPosition > lookupPosition && earlyReturnPosition > selectionPosition,
  "clothing updates must restore the saved adapter skin after the adapter has been unequipped",
);

console.log("2D Wardrobe skin adapter fix contract passed.");
