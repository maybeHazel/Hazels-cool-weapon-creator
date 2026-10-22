const presets = {

--hi

["damageFunctions"] = {

["Default"] = function(otherHumanoid: Humanoid, Self: {})
		local sucess = false

		if not otherHumanoid and not Self then
			return warn(`missing self or humanoid: {Self} {otherHumanoid}`)
		end

		if otherHumanoid.ClassName ~= "Humanoid" then
			return
		end

		otherHumanoid:TakeDamage(Self["Damage"])
		sucess = true

		return sucess
	end,


	["overTime"] = function(otherHumanoid: Humanoid, Self: {})
		if not otherHumanoid and not Self then
			return
		end

		if otherHumanoid.ClassName ~= "Humanoid" then
			return
		end

		if Self["CurrentlyDamaging"] then return end

		for hitCount = 0, Self["DamageCount"], 1 do
			Self["CurrentlyDamaging"] = true
			otherHumanoid:TakeDamage(Self["Damage"])
			task.wait(Self["DamageInterval"])
		end

		Self["CurrentlyDamaging"] = false
	end,


	["Accumulative"] = function(otherHumanoid: Humanoid, Self: {})
		local sucess = false
		if not otherHumanoid and not Self then return end

		if otherHumanoid.ClassName ~= "Humanoid" then return end

		local hitLimit = 0
		local DamagePerHit = Self["DamagesPerHit"]
		local damageAmount = DamagePerHit[tostring(Self["HitCount"])]

		for _, v in DamagePerHit do hitLimit += 1 end
		if Self["HitCount"] >= hitLimit then Self["HitCount"] = 0 end

		if not damageAmount then return end

		otherHumanoid:TakeDamage(damageAmount)
		Self["HitCount"] += 1

		sucess = true
		return sucess
	end,

	--tipo de ataque carioca pq s kakakakakaka
	["Thief"] = function(otherHumanoid:Humanoid, Self: {})
		if not otherHumanoid and not Self then return end

		if otherHumanoid.ClassName ~= "Humanoid" then
			return
		end

		local myChar = Self["_Tool"].Parent
		if not myChar then return end

		local myPlayer:Player = Players:GetPlayerFromCharacter(myChar)

		local otherChar = otherHumanoid.Parent	
		if not otherChar then return end

		local otherEquippedItem = otherChar:FindFirstChildOfClass("Tool")

		local StealCooldown = Self["StealCooldown"]

		if Self["CanSteal"] == true then

			if StealCooldown then --Im checking this cause the steal cooldown is optional and the item might not even be able to steal, so
				--thats also why theres the check above this btw.
				Self["CanSteal"] = false

				task.delay(StealCooldown, function()
					Self["CanSteal"] = true
				end)
			end


			if myPlayer and otherEquippedItem then
				otherEquippedItem.Parent = myPlayer.Backpack
			end

			if otherEquippedItem and not myPlayer then
				otherEquippedItem.Parent = myChar
			end

		end

		otherHumanoid:TakeDamage(Self.Damage)
	end,
        
}, --end of dmg functions

["setupFunctions"] = {

["overTime"] = function(self: {}, stats: {})
		if not self and not stats then return end

		local Damage_Count = stats["DamageCount"] or math.random(2, 6);
		local Damage_Interval = stats["DamageInterval"] or .5;

		self["DamageCount"] = Damage_Count;
		self["DamageInterval"] = Damage_Interval;
		self["CurrentlyDamaging"] = false;

	end,


	["Accumulative"] = function(self: {}, stats: {})
		if not self and not stats then return end

		local Hit_Count = stats["HitCount"] or 0;
		local Damages_Per_Hit = stats["DamagesPerHit"] or { ["2"] = 20, ["4"] = 25 };

		self["HitCount"] = Hit_Count;
		self["DamagesPerHit"] = Damages_Per_Hit;

	end,


	["Thief"] = function(self: {}, stats: {})
		if not self and not stats then return end

		local Can_Steal = stats["CanSteal"] or false;
		local Steal_Cooldown = stats["StealCooldown"] or nil;

		self["CanSteal"] = Can_Steal;
		self["StealCooldown"] = Steal_Cooldown; 

	end,


	["Guitarrist"] = function(self, stats)
		if not self and not stats then return end

	end,
            
}, --end of setup functions
          
}


return presets