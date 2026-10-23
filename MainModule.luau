--i might be using way too much space for the separator comments but i lowkey cant it see when im trying to find something so thats
--why i made them that big

--//Services\\--

const Players = game:GetService("Players");
const GoodSignal = require("./dependencies/GoodSignal");
const BuiltInPresets = require("./presets/built-in");
const customPresets = require("./presets/custom");
--//

const Class = {}
Class.__index = Class

--//--------------------------------------------------------------------------------------------------------------------------------------\\
--\\--------------------------------------------------//TYPES\\---------------------------------------------------------------------------//---
--//--------------------------------------------------------------------------------------------------------------------------------------\\

type includables = "built in presets" | "locked custom damage functions" | "locked custom setup functions" | "lastHit attribute" | "lastHitBy attribute" |
"warn if damage function is not found" | "warn if setup function is not found" | "warn other character on hit" | "warn custom function calls"

type DamageFunction = (otherHumanoid: Humanoid, self: MeleeWeaponBase) -> ()
type ObjectSetupFunction = (self: MeleeWeaponBase, stats: {}) -> ()

type MeleeWeaponBase = {
	Damage: number,
	AttackRate: number,
	Hitbox: BasePart,
	HitboxActivationTime: number,
	HitboxLifeTime: number,
	AttackType: string,

	["customDamageFunction"]: string,
	["UseAttackTypeDamageFunction"]: boolean,
	["setupFunction"]: string,
	["UseTypeSetupFunction"]: boolean,

	Attack: (self: MeleeWeaponBase) -> (),
	Setup: (self: MeleeWeaponBase, Stats: {}) -> (),

	OnHit: RBXScriptSignal,
	OnDestroying: RBXScriptSignal,
}


--//--------------------------------------------------------------------------------------------------------------------------------------\\
--\\-----------------------------------------------// VALUES AND FOLDERS\\----------------------------------------------------------------//---
--//--------------------------------------------------------------------------------------------------------------------------------------\\

const LockedProperties = { "Debounce" }
const LockedTypeFunctions = { "Default", "overTime", "Accumulative" }
const lockedDamageFunctions = { "Default", "overTime", "Accumulative" }

const MeeleTypes = { "overTime", "Accumulative", "Default", "Thief", "Vampire" }

const includableStuff = {
	"built in presets",
	"locked custom damage functions",
	"locked custom setup functions",
	"lastHit attribute",
	"lastHitBy attribute",
	"warn if damage function is not found",
	"warn if setup function is not found",
	"warn other character on hit",
	"warn custom function calls",
}

const enabledIncludables = {}

--//--------------------------------------------------------------------------------------------------------------------------------------\\
--\\--------------------------------------------// FUNCTIONS \\---------------------------------------------------------------------------//---
--//--------------------------------------------------------------------------------------------------------------------------------------\\

--checks if the specified option is enabled
function IsIncluded(option: includables): boolean
	if not option or (option and not table.find(includableStuff, option)) then return nil end

	if table.find(enabledIncludables, option) then
		return true
	end

	return false
end

--//--------------------------------------------------------------------------------------------------------------------------------------\\
--\\--------------------------------------// CLASS FUNCTIONS \\---------------------------------------------------------------------------//---
--//--------------------------------------------------------------------------------------------------------------------------------------\\

--Use this to enable extra options in the module (like csharp "using" or java "include" ig, idk java)
function Class.include(option: includables)
	if not option then return end
	if typeof(option) ~= "string" or typeof(option) ~= "table" then return warn(`expected string or table but got {typeof(option)} instead.`) end

	if not table.find(includableStuff, option) then return warn(`Option {option} does not exist`) end

	if table.find(enabledIncludables, option) then return warn(`{option} option is already included/enabled`) end

	if typeof(option) == "string" then
		table.insert(enabledIncludables, option)

	elseif typeof(option) == "table" then
		for _, v in option do
			table.insert(enabledIncludables, v)
		end
	end

	return nil
end


--Disables the specified option
function Class.DisableIncluded(option: includables)
	if not option then return end
	if typeof(option) ~= "string" then return (`expected string but got {typeof(option)} instead.`) end

	if not table.find(includableStuff, option) then return warn(`Option {option} does not exist`) end

	if not table.find(enabledIncludables, option) then return end

	table.remove(enabledIncludables, table.find(enabledIncludables, option))
	return nil
end


--[[Constructor function. Creates a new melee weapon object and has an OnHit event that returns the hit character and player]]
function Class.new(Tool: Tool, Hitbox: BasePart, properties: MeleeWeaponBase): MeleeWeaponBase?
	if not Tool and not Hitbox and not properties then return nil end

	local newSword = {
		["AttackType"] = properties["AttackType"] or "Default",
		["Damage"] = properties["Damage"] or 0,
		["AttackRate"] = properties["AttackRate"] or 0.5,
		["Debounce"] = false,

		["Hitbox"] = Hitbox,
		["HitboxLifeTime"] = properties["HitboxLifeTime"] or 0.6,
		["HitboxActivationTime"] = properties["HitboxActivationTime"] or 0.1,
		["_Tool"] = Tool,

		["OnHit"] = GoodSignal.new(),
		["OnDestroying"] = GoodSignal.new(),
	}

	local setupFunction
	local useBuiltIntSetup = IsIncluded("build in presets")
	local useTypeSetup =  properties["UseTypeSetupFunction"]
	local customSetupFunc = properties["setupFunction"]
	local usedSetupFunc

	if useBuiltIntSetup then
		setupFunction = BuiltInPresets.setupFunctions[newSword.AttackType]
	else
		setupFunction = customPresets.setupFunctions[newSword.AttackType]
	end

	if properties["customDamageFunction"] then
		newSword["customDamageFunction"] = properties["customDamageFunction"]
	end

	if properties["UseAttackTypeDamageFunction"] then
		newSword["UseAttackTypeDamageFunction"] = true
	end

	if useTypeSetup == true then
		setupFunction = customPresets.setupFunctions[newSword.AttackType]
		usedSetupFunc = "type"

	elseif useTypeSetup ~= true and customSetupFunc then
		setupFunction = customPresets.setupFunctions[properties["setupFunction"]]
		usedSetupFunc = "custom"
	end

	if (useTypeSetup == true and customSetupFunc) and not setupFunction then
		if usedSetupFunc == "type" then
			setupFunction = customPresets.setupFunctions[newSword.AttackType]

		elseif usedSetupFunc == "custom" then
			setupFunction = customPresets.setupFunctions[properties["setupFunction"]]
		end
	end

	if setupFunction then
		setupFunction(newSword, properties)
	elseif not setupFunction and IsIncluded("warn if setup function is not found") then
		warn(`a setup function for {newSword.AttackType} was not found`)
	end

	local swordObject = setmetatable(newSword, Class) --[[placing this here to avoid errors in VScode BUT you can just
    move the setMetatable to the return and it will work. like this: return setmetatable(newSword, Class)]]
	return swordObject
end

--Other class functions below

--[[Use this to add custom properties to your object. The function is called when creating a new meele object and the properties can be used with custom damage functions
Code example:
function isaacAttackSetup(isaacObject, stats)
	isaacObject.AttackRate = stats["AttackRate"] or .2
	isaac.DamageEffects = stats["PassiveItems"] or {"Brimstone", "Sacred heart", "Godhead", "Holy mantle"}
end
]]
function Class.newSetupFunction(Type: string, func: ObjectSetupFunction, lockFunction: boolean)
	if not Type and not func then return warn(`missing type or function: {Type}, {func}`) end
	if table.find(LockedTypeFunctions, Type) then return warn(`{Type} is a locked Type and can not be changed`) end

	local isLockIncluded = IsIncluded("locked custom setup functions")
	if isLockIncluded and lockFunction then
		table.insert(LockedTypeFunctions, Type)

	elseif isLockIncluded and lockFunction == false then
		table.remove(LockedTypeFunctions, table.find(lockedDamageFunctions, Type))

	elseif not isLockIncluded and lockFunction then
		return warn("locked functions are not included, please include it by using the .include('locked custom setup functions') function.")
	end

	customPresets.setupFunctions[Type] = func
	return nil
end


--[[Use this to add custom functions for your custom attack types. The function passed as an argument gets called by the :Attack method, giving both the other humanoid and the object itself. 
Code example:
function MyCoolFunc(otherHumanoid, object)
	otherHumanoid:TakeDamage(object["Damage"])
end
meleeClass.newDamageFunction("MyCoolAttackType", MyCoolFunc)
]]
function Class.newDamage(name: string, func: DamageFunction, lockFunction: boolean)
	if not name and not func then return warn(`missing attack type or function: {name}, {func}`) end
	if table.find(lockedDamageFunctions, name) then return warn(`{name} is an default locked function and can not be changed`) end

	local isLockIncluded = IsIncluded("locked custom damage functions")
	if isLockIncluded and lockFunction then
		table.insert(lockedDamageFunctions, name)

	elseif isLockIncluded and lockFunction == false then
		table.remove(lockedDamageFunctions, table.find(lockedDamageFunctions, name))

	elseif not isLockIncluded and lockFunction then
		return warn("locked functions are not included, please include it by using the .include('locked custom damage functions') function.")
	end

	customPresets.damageFunctions[name] = func
	return nil
end

--//--------------------------------------------------------------------------------------------------------------------------------------\\
--\\--------------------------------------------//CLASS METHODS\\-------------------------------------------------------------------------//--
--//--------------------------------------------------------------------------------------------------------------------------------------\\

--Use this to change the object properties
function Class:Setup(properties: {})
	if not properties then return end

	for propertyName, Value in properties do
		if not self[propertyName] then
			continue
		end

		if
			table.find(LockedProperties, propertyName)
			or typeof(self[propertyName]) == "table" and self[propertyName]["LockedProperty"]
		then
			continue
		end

		self[propertyName] = Value
	end
end


--If a custom damage function for the object's attack type is found it gets called here with the otherHumanoid and the object that called this method being given as arguments
function Class:Attack()
	if not self and not self.Hitbox then
		return warn(`missing self or hitbox: {self} {self.hitbox}`)
	end

	if self.Debounce then
		return
	end
	self.Debounce = true

	local warnCount = 0

	local hitVictims = {}

	local Tool = self._Tool
	local hitbox: BasePart = self.Hitbox
	local HitboxLifeTime = self["HitboxLifeTime"]
	local HitboxActivationTime = self["HitboxActivationTime"]
	local myCharacter = Tool.Parent

	if HitboxLifeTime then
		task.delay(HitboxLifeTime, function()
			hitbox.CanTouch = false
		end)
	end

	local hitInstances = workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size)
	for _, victim in hitInstances do
		local OtherCharacter = victim:FindFirstAncestorOfClass("Model")
		if OtherCharacter then
			local OtherPlayer = Players:GetPlayerFromCharacter(OtherCharacter)

			local otherHumanoid: Humanoid = OtherCharacter:FindFirstChildOfClass("Humanoid")
			if not otherHumanoid or (otherHumanoid and otherHumanoid == myCharacter.Humanoid) then
				continue
			end
			if table.find(hitVictims, otherHumanoid) then
				continue
			end

			local damageFunction

			if IsIncluded("built in preset functions") then
				damageFunction = BuiltInPresets.damageFunctions[self.AttackType]
			else

				if self["UseAttackTypeDamageFunction"] == true then
					damageFunction = customPresets.damageFunctions[self.AttackType]
				
				if not damageFunction and self["customDamageFunction"] then
					damageFunction = customPresets.damageFunctions[self.customDamageFunction]
				end

				elseif self["UseAttackTypeDamageFunction"] ~= true and self["customDamageFunction"] then
					damageFunction = customPresets.damageFunctions[self.customDamageFunction]
				end

			end

			if not damageFunction then
				otherHumanoid:TakeDamage(self.Damage)

				if IsIncluded("warn if custom damage function is not found") and warnCount < 1 then
					warn(`Invalid attack type ({self.AttackType}). {self.AttackType} does not have a function to handle damage: {damageFunction}.`)
					warnCount = 1
				end
			end


			if IsIncluded("lastHit attribute") then
				myCharacter:SetAttribute("LastHit", OtherCharacter)
			end

			if IsIncluded("lastHitBy attribute") then
				OtherCharacter:SetAttribute("LastHitBy", myCharacter)
			end

			if IsIncluded("warn other character on hit") then
				warn(OtherCharacter.Name)
			end

			table.insert(hitVictims, otherHumanoid)
			damageFunction(otherHumanoid, self)
			self.OnHit:Fire(otherHumanoid, OtherPlayer)

			if IsIncluded("warn custom function calls") then
				warn(`{self.AttackType} damage function has been called`)
			end

		end

	end

	if not hitbox.CanTouch then
		if HitboxActivationTime then
			task.delay(HitboxActivationTime, function()
				hitbox.CanTouch = true
			end)
		else
			hitbox.CanTouch = true
		end
	end

	table.clear(hitVictims)
	task.wait(self.AttackRate or 1)
	self.Debounce = false
end

function Class:Destroy()
	if not self then
		return warn("ay bro, what are you trying to destroy, i mean, you havent even created a melee weapon yet bruh :sob:")
	end

	self.OnDestroying:Fire("nooooooo, im DEAD son????")

	table.clear(self)
	setmetatable(self, nil)
	return {}
end

--//--------------------------------------------------------------------------------------------------------------------------------------\\

return Class