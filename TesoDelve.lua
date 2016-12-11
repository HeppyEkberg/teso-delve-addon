
local function loadTesoDelve(eventCode, addOnName)

    if(addOnName == "TesoDelve") then

        local defaults =
        {
            a_characters = {},
            inventory = {}
        }

        local savedVars = ZO_SavedVars:NewAccountWide("TesoDelve", 1, nil, defaults)
        local characterId = GetCurrentCharacterId()
        local itemsExported = 0

        if(savedVars.a_characters == nil) then
            savedVars.a_caracters = {}
        end

        if(savedVars.inventory[characterId] == nil) then
            savedVars.inventory[characterId] = {}
        end

        local function exportInventory(bagSpace)
            local backPackSize = GetBagSize(bagSpace)
            local inventory = {}

            for i=1, backPackSize, 1 do

                local itemName = GetItemName(bagSpace, i)
                if string.len(itemName) >= 1 then
                    local uniqueId = GetItemUniqueId(bagSpace, i)
                    local itemTrait = GetItemTrait(bagSpace, i)
                    local itemStatValue = GetItemStatValue(bagSpace, i)
                    local itemArmorType = GetItemArmorType(bagSpace, i)
                    local itemType = GetItemType(bagSpace, i)
                    local weaponType = GetItemWeaponType(bagSpace, i)
                    local totalCount = GetItemTotalCount(bagSpace, i)
                    local itemLink = GetItemLink(bagSpace, i)
                    local itemInfo =  {GetItemInfo(bagSpace, i) }
                    local itemPlayerLocked = IsItemPlayerLocked(bagSpace, i)
                    local quality = GetItemLinkQuality(itemLink)
                    local setInfo =  {GetItemLinkSetInfo(itemLink, true) }
                    local enchantInfo = {GetItemLinkEnchantInfo(itemLink) }
                    local championPoints = GetItemRequiredChampionPoints(bagSpace, i)
                    local itemLevel = GetItemRequiredLevel(bagSpace, i)

                    local item = {
                        uniqueId, -- Unique ID
                        itemName, -- Name
                        itemTrait, -- Trait
                        itemInfo[6], -- EquipType
                        setInfo[2], -- SetName
                        quality, -- Quality
                        itemArmorType, -- Heavy/Medium/Light armor
                        tostring(itemPlayerLocked), -- Locked?
                        enchantInfo[2], -- ItemLink enchant
                        itemInfo[1], -- icon,
                        itemType, -- Itemtype /armor/jewelry/weapon etc
                        championPoints, -- cp needed
                        itemLevel, -- level neeeded
                        weaponType, -- Weapontype axe/dagger/bow etc
                        characterId, -- characters unique id
                        bagSpace, -- space enum, to see if it's a bank item
                    }

                    --d('<--- start item --->')
                    --d(enchantInfo)
                    --d(itemName ..": " .. tostring(itemInfo[5]) .. " - " .. tostring(itemPlayerLocked))
                    --d(setInfo)
                    --d(i .. ":" .. itemName .. " exported")
                    --d(itemName .. ", " .. uniqueId .. " exported. (".. bagSpace .."-"..i..")")

                    itemsExported = itemsExported + 1
                    inventory['BAG-' .. i] = "ITEM:"..table.concat(item, ';')

                end
            end


            if(bagSpace == BAG_BANK) then
                savedVars.inventory['bank'] = {}
                savedVars.inventory['bank'] = inventory
            else
                savedVars.inventory[characterId][bagSpace] = inventory
            end

        end

        local function exportCharacter()
            if(savedVars.a_characters == nil) then
                savedVars.a_characters = {}
            end

            local name = GetUnitName('player')
            local class = GetUnitClass('player')
            local classId = GetUnitClassId('player')
            local level = GetUnitLevel('player')
            local championLevel = GetUnitChampionPoints('player')
            local race = GetUnitRace('player')
            local raceId = GetUnitRaceId('player')
            local alliance = GetUnitAlliance('player')
            local ridingTime = GetTimeUntilCanBeTrained()
            local currentTime = GetTimeStamp()

            savedVars.a_characters[characterId] = 'CHARACTER:'..characterId..";"..name..";"..class..";"..classId..";"..level..";"..championLevel..";"..race..";"..raceId..";"..alliance..";"..ridingTime..";"..currentTime
        end

        local function startExport()
            itemsExported = 0
            d('TesoDelve: Export started, exporting all your items')
            exportCharacter()
            exportInventory(BAG_BACKPACK)
            exportInventory(BAG_WORN)
           exportInventory(BAG_BANK)
            d('TesoDelve: ' .. itemsExported .. ' successfully exported')
        end

        SLASH_COMMANDS["/tesodelve"] = startExport

        local inventoryScene = SCENE_MANAGER:GetScene("inventory")
        inventoryScene:RegisterCallback("StateChange", function(oldState, newState)
            if(oldState == 'shown') then
                zo_callLater(startExport, 100)
            end
        end)

    end
end

EVENT_MANAGER:RegisterForEvent("TesoDelveLoaded", EVENT_ADD_ON_LOADED, loadTesoDelve)


