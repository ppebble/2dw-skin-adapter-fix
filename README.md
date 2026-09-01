# 2D Wardrobe Skin Adapter Fix

Compatibility fix for 2Dimension Wardrobe and the SFW small-body option from
VSGirlBody Integrated.

2D Wardrobe's current Build 42 skin-adapter XML uses masks that its author has
documented as non-functional. Equipping the adapter can therefore hide or
corrupt the character and other clothing without producing a Lua error.

This mod turns the two adapter items into safe skin-tone selectors:

- `Base.2dw_skinmaskp` selects skin index 3 (`FemaleBody04`, pink).
- `Base.2dw_skinmaskw` selects skin index 4 (`FemaleBody05`, white).

The adapter is immediately unequipped but remains in the inventory. The selected
skin tone is saved on the character and reapplied after later clothing updates,
including when a 2D Wardrobe character mask rebuilds the visual. This keeps the
native face from reappearing through the flat character mask.

When a 2D Wardrobe head is worn, choosing the fourth or fifth skin directly
through Skin Color Changer is also remembered and reapplied. Other skin choices
and characters without a 2D Wardrobe head remain untouched.

Required load order:

1. `42_VSGirlBodySFW`
2. `4123567854998` (2Dimension Wardrobe)
3. `2DWSkinAdapterFix`

The Workshop/source mods are not modified.

