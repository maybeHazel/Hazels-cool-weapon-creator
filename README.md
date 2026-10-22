# Hazels-cool-weapon-creator
A Roblox module that you can use to create weapons with customizable stuff and includable options that might be usefull to use.

You can create functions to handle how the weapon deals damage and you can also create functions to add custom properties to work with custom
damage functions. Custom functions are stored inside the "custom" module in the presets folder.
 
You can also make functions for custom attack types and every weapon that has the custom type will use the functions for that type
if you are using a custom type function and the function for that type isnt found but you are also using a normal custom function, it will
use the normal custom function instead of type function.

Brief tutorial on how to use the module:

includable stuff:
```luau
module.include("built in presets") -- including one option at time

local options = {"locked custom damage functions", "locked custom setup functions", "lastHit attribute", "lastHitBy attribute"}
module.include(options) -- including multiple options at once
```
normal use:
```luau
local properties = {
  ["Damage"] = 10,
  ["AttackRate"] = 1,
  ["AttackType"] = nil (not obligatory)
}
local mySword = module.new(tool, tool.Hitbox, properties)
mySword:Attack() 
```

custom damage function:
```luau
function overTimeDamageFunction(otherHumanoid,self)

  for i = 0, self.burnCount, 1 do
    otherHumanoid:TakeDamage(self.Damage)
    task.wait(self.burnInterval)
  end

end

module.newDamage("overtimeDamage", overTimeDamageFunction)
local mySword = module.new(tool, tool.Hitbox, {..., ["customDamageFunction"] = "overtimeDamage" })
```
you can do the same thing for custom setup functions:
```luau
function burnDmgSetup(self, properties)
  self["burnCount"] = 4,
  self["burnInterval"] = .5
end

module.newSetupFunction("burnDamage", burnDmgSetup)
```

custom functions for custom types:
```luau
function burnDmgSetup(self, properties)
  self["burnCount"] = 4,
  self["burnInterval"] = .5
end

function burnDamage(otherHumanoid,self)

  for i = 0, self.burnCount, 1 do
    otherHumanoid:TakeDamage(self.Damage)
    task.wait(self.burnInterval)
  end

end

module.newDamage("burn", burnDamage)
newSetupFunction("burn", burnDmgSetup)

local properties = {
["AttackType"] = "burn",
["UseAttackTypeDamageFunction"] = true,
["Damage"] = 5
}

local mySword = module.new(tool, tool.Hitbox, properties)
local myOtherSword = module.new(tool, tool.Hitbox, properties)
myOtherSword.Damage = 6
myOtherSword.burnCount = 6

mySword:Attack()
myOtherSword:Attack() 
```
