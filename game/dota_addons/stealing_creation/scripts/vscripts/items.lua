-- Stealing Creation
-- By Richard Morrison (2015)
-- wigguno@gmail.com
-- http://steamcommunity.com/id/wigguno/

-- Lua Items
-- handles the runscripts for all data-driven items

function findItemType(name)
	if string.find(name, "sword") 	then return "sword" end
	if string.find(name, "bow") 	then return "bow" end
	if string.find(name, "staff") 	then return "staff" end
	if string.find(name, "armour") 	then return "armour" end
	if string.find(name, "hide") 	then return "hide" end
	if string.find(name, "robes") 	then return "robes" end
	return nil
end

function findItemTier(name)
	return string.match(name, "%d+")
end

function OnWeaponSwitch(keys)
	--PrintTable(keys)
	local hero = keys.caster
	local item = keys.ability
	local itemType = findItemType(item:GetName())
	local itemTier = findItemTier(item:GetName())
	local modifierName = "modifier_sc_" .. itemType .. "_tier_" .. itemTier

	--print("Tier " .. itemTier .. " " .. itemType .. " finished channeling.")

	-- if the hero already has the modifier, remove it and carry on
	if hero:FindModifierByName(modifierName) then
		hero:RemoveModifierByName(modifierName)
		return
	end

	-- remove all modifiers first
	hero:RemoveModifierByName("modifier_sc_sword_tier_1")
	hero:RemoveModifierByName("modifier_sc_sword_tier_2")
	hero:RemoveModifierByName("modifier_sc_sword_tier_3")
	hero:RemoveModifierByName("modifier_sc_sword_tier_4")
	hero:RemoveModifierByName("modifier_sc_sword_tier_5")

	hero:RemoveModifierByName("modifier_sc_bow_tier_1")
	hero:RemoveModifierByName("modifier_sc_bow_tier_2")
	hero:RemoveModifierByName("modifier_sc_bow_tier_3")
	hero:RemoveModifierByName("modifier_sc_bow_tier_4")
	hero:RemoveModifierByName("modifier_sc_bow_tier_5")

	hero:RemoveModifierByName("modifier_sc_staff_tier_1")
	hero:RemoveModifierByName("modifier_sc_staff_tier_2")
	hero:RemoveModifierByName("modifier_sc_staff_tier_3")
	hero:RemoveModifierByName("modifier_sc_staff_tier_4")
	hero:RemoveModifierByName("modifier_sc_staff_tier_5")

	--print("applying modifier: " .. modifierName)
	item:ApplyDataDrivenModifier(hero, hero, modifierName, nil)

	if itemType == "sword" then
	elseif itemType == "bow" then
	elseif itemType == "staff" then
	end

end


function OnArmourSwitch(keys)
	--PrintTable(keys)
	local hero = keys.caster
	local item = keys.ability
	local itemType = findItemType(item:GetName())
	local itemTier = findItemTier(item:GetName())
	local modifierName = "modifier_sc_" .. itemType .. "_tier_" .. itemTier
	
	--print("Tier " .. itemTier .. " " .. itemType .. " finished channeling.")

	-- if the hero already has the modifier, remove it and carry on
	if hero:FindModifierByName(modifierName) then
		hero:RemoveModifierByName(modifierName)
		return
	end

	-- remove all modifiers first
	hero:RemoveModifierByName("modifier_sc_armour_tier_1")
	hero:RemoveModifierByName("modifier_sc_armour_tier_2")
	hero:RemoveModifierByName("modifier_sc_armour_tier_3")
	hero:RemoveModifierByName("modifier_sc_armour_tier_4")
	hero:RemoveModifierByName("modifier_sc_armour_tier_5")

	hero:RemoveModifierByName("modifier_sc_hide_tier_1")
	hero:RemoveModifierByName("modifier_sc_hide_tier_2")
	hero:RemoveModifierByName("modifier_sc_hide_tier_3")
	hero:RemoveModifierByName("modifier_sc_hide_tier_4")
	hero:RemoveModifierByName("modifier_sc_hide_tier_5")

	hero:RemoveModifierByName("modifier_sc_robes_tier_1")
	hero:RemoveModifierByName("modifier_sc_robes_tier_2")
	hero:RemoveModifierByName("modifier_sc_robes_tier_3")
	hero:RemoveModifierByName("modifier_sc_robes_tier_4")
	hero:RemoveModifierByName("modifier_sc_robes_tier_5")

	--print("applying modifier: " .. modifierName)
	item:ApplyDataDrivenModifier(hero, hero, modifierName, nil)

	if itemType == "armour" then
	elseif itemType == "hide" then
	elseif itemType == "robes" then
	end
end