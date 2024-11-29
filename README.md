![image](https://github.com/user-attachments/assets/a627c34a-fcf4-4350-aba6-5269b15de961)

> # 🎄🎁 OnlyScripts Advent Script 🎁🎄

> [Preview](https://streamable.com/care8w)

# Download Here
> [GitHub](https://github.com/Test1calCutter/os_advent)

# Features
- **Fully customizable!**
- **Efficient!**
- **Supports Ox Inventory, Ox Target & Ox Lib.**
- **You can customize if it should spawn an NPC or Prop, or none of those.**
- **Change the cooldown of getting presents.**
- **Built-in Anti-Cheat! (Untested) Enable to kick players who trigger the event, without being near the location.**
- **"/givePresent (id)". You can give a present to a player.**
- **"/resetTimer (id)". You can reset a players cooldown.**
- **"/stopAdvent". You can temporarily stop the event, so nobody can get more presents.**
- **"/startAdvent". You can re-start the event again, and everybody can get their presents again.**


```
--                      #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
--                      #                                                             #
--                      #                          IMPORTANT                          #
--                      #    You may not upload this script on any other website!     #
--                      #                                                             #
--                      #/////////////////////////////////////////////////////////////#
-- #-#-#-#-#-#-#-#-#-#-#///////////////////////////////////////////////////////////////#-#-#-#-#-#-#-#-#-#-#
-- #                                                                                                       #
-- #                                🎁 OX_INVENTORY CUSTOM  ITEM SUPPORT 🎁                               #
-- #             Add this code snippet to "ox_inventory/modules/items/server.lua" on the bottom            #
-- #                                                                                                       #
-- #    Item('present', function(event, item, inventory, slot, data)                                       #
-- #    	if event == 'usingItem' then                                                                     #
-- #    		if Inventory.GetItem(inventory, item, inventory.items[slot].metadata, true) > 0 then           #
-- #    			return {                                                                                     #
-- #    				inventory.label, event, 'external item use poggies'                                        #
-- #    			}                                                                                            #
-- #    		end                                                                                            #
-- #    	elseif event == 'usedItem' then                                                                  #
-- #    		--print(('%s has used %s on slot %s'):format(inventory.label, item.label, slot))               #
-- #                                                                                                       #
-- #    		local items = { -- what items to give after opening the present                                #
-- #    			{ name = 'bread', amount = 4 },                                                              #
-- #    			{ name = 'water', amount = 4 },                                                              #
-- #    			{ name = 'phone', amount = 1 }                                                               #
-- #    		}                                                                                              #
-- #                                                                                                       #
-- #    		for _, v in ipairs(items) do -- checking if the user can even carry any of the items           #
-- #    			if exports.ox_inventory:CanCarryItem(source, v.name, v.amount) then                          #
-- #    				exports.ox_inventory:AddItem(source, v.name, v.amount)                                     #
-- #    			else                                                                                         #
-- #    				print("no space for this item: " .. v.name)                                                #
-- #    			end                                                                                          #
-- #    		end                                                                                            #
-- #    	end                                                                                              #
-- #    end)                                                                                               #
-- #                                                                                                       #
-- #-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

Config = {}
Config.Stopped = false -- DO NOT CHANGE!

--  General Settings
Config.Locale               = "en"
Config.Location             = vec4(170.13, -985.04, 29.08, 5.0)   --  Where can the player get their gifts?
Config.SpawnRange           = 25                                  --  In what range does it spawn the ped/prop?
Config.SpawnPed             = false                               --  Spawn a ped?
Config.SpawnProp            = true                                --  Spawn a prop?
Config.Ped                  = "u_m_m_jesus_01"                    --  Ped model
Config.Prop                 = "prop_xmas_tree_int"         --  Prop model
Config.InteractionRange     = 2                                   --  At what range can the user interact?
Config.Cooldown             = 1440                                --  Time in minutes (1440 = 24 Hours)

--  Optional Settings
Config.EnableAdminCommands  = true                                --  Commands for admins?
Config.OxLib                = true                                --  Using ox_lib?
Config.UseOxInventory       = true                                --  Using ox_inventory?
Config.CustomItem           = true                                --  If using ox_inventory and using your own item, enable this.  Otherwise you can ignore this 
Config.ThirdEye             = true                                --  Using L-ALT to interact? -- Standard setting is using ox_target! Change in client.lua; line: xx
Config.ThirdEyeRange        = 2.0                                 --  Third Eye Range
Config.Debug                = false                               --  Debugging
Config.UseOXnotification    = true                                --  Set to false for standard ESX notification - For custom notification edit in server.lua; line: 26, 78, 80, 84 
Config.AntiCheat            = true                                --  Try to punish players if cheating is detected? It gets the players position and just checks if the player is within x meters if the event was triggered
Config.MaxRange             = 5                                   --  Kick player if event triggered and player itself isnt in a range of 5 meters


--  Possible items
Config.Gifts = {                      
    small = {                     
        spawnName = "presmall",                                   -- Instead of "presmall" you should type your custom item's spawn-name! Otherwise, just leave it as is
        maxAmount = 1,                                            -- Change to how many gifts the player can get
        items = {                                                 -- Useless if using custom item! Just leave it as is
            ['bread'] = 1,
            ['water'] = 1
        }
    },
    medium = {
        spawnName = "presbig",
        maxAmount = 1,
        items = {
            ['phone'] = 1,
            ['weapon_pistol'] = 1
        }
    }
}


--  Groups
Config.Groups = { 
    ["admin"] = true, 
    ["mod"] = true 
}
```


|                                         |                                |
|-------------------------------------|----------------------------|
| Code is accessible       | Yes                 |
| Subscription-based      | No                 |
| Lines (approximately)  |  600 |
| Requirements                | ESX      |
| Support                           | Until December 24th                 |


Sorry for the messy comments and code. I was in a rush to finish it in 2 days!
 
