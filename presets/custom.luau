const presets = {

--[[
here is where your custom presets are stored. You can type your damage/setup functions here 
or use the modules's function to do that. I've already explained this in the module function but when a 
function gets called by the main module, both the other Otherhumanoid and the object that called the function 
are respectively given as arguments so the function must have atleast 2 parameters for that ( local function myFunc(otherHum, self) )
]]

["damageFunctions"] = {

    
}, --end of dmg functions


["setupFunctions"] = {

}


} --end of setup functions

return presets