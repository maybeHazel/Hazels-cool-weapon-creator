# Hazels-cool-weapon-creator
A Roblox module that you can use to create weapons with customizable stuff and includable options that might be usefull to use.
You can create custom functions to handle how the weapon deals damage and to add custom properties to use with your custom damage functions and if you
dont want to make all that custom functions stuff, you can just use the default properties and it will still work normally.

also you can add custom attack types and you can add custom setup and damage functions for that custom attack type so,
every weapon that has this attack type will use the type's specific setup or damage function (or both of them if you want)

You can use it like this:

includable stuff:
module.include("built in presets") - including one option at time

local options = {"locked custom damage functions", "locked custom setup functions", "lastHit attribute", "lastHitBy attribute"}
module.include(options) - including multiple options at once
-->
normal use:

local properties = {
["Damage"] = 10,
["AttackRate"] = 1,
["AttackType"] = nil (not obligatory)
}
local mySword = module.new(tool, tool.Hitbox, properties)
mySword:Attack() 

-->

custom damage function:
function overTimeDamageFunction(otherHumanoid,self)

  for i = 0, self.burnCount, do
    otherHumanoid:TakeDamage(self.Damage)
    task.wait(self.burnInterval)
  end

end

module.newDamage("overtimeDamage", overTimeDamageFunction)

local mySword = module.new(tool, tool.Hitbox, {..., ["customDamageFunction"] = "overtimeDamage" })
-->
you can do the same thing for custom setup functions. Setup functions like:
function burnDmgSetup(self, properties)
self["burnCount"] = 4,
self["burnInterval"] = .5
end
-->
