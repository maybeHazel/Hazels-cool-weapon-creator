--[[
class.new():
if an required property isnt found inside the property table, it will just set it to 
the property's default value and
if built in presets is enabled it will call the default setup function.

melee:Attack():
if you are using built in presets or your own presets and a damage function isnt found
it will just damage the other humanoid normally.

same thing happens if you are not using any damage functions. It will damage the other humanoid normally.

custom damage functions:
they are called whenever Attack is called and you can use them to make a different way
of dealing damage, idk how to give an good eaxample on how you could use this but maybe lets say you
want to do burning damage instead of normal damage, you would create a function for that and when the 
melee attacks, it will call that function and do burning damage instead of normal damage.

if you have set your melee to use a custom damage function (mySword.customDamageFunction = "overtime") but
useAttackTypeDamageFunction is enabled (mySword.useAttackTypeDamageFunction = true), it will use the attack type
function instead. Otherwise it will use the damage function you've set it to use.

locked custom functions/properties:
makes it so other scripts cant change or replace/override the function you've locked.
If lockFunction is set to true it will lock the function and it it is set to false it will unlock the function
]]