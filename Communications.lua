local _, e = ...

local BROADCAST = true
local temp = {}
local sender, unitClass, unitRealm, dungeonID, keyLevel, usable, affixOne, affixTwo, affixThree

local arg, content, msg, prefix, sender

local akComms = CreateFrame('FRAME')
akComms:RegisterEvent('CHAT_MSG_ADDON')
RegisterAddonMessagePrefix('AstralKeys')

local function AddonMessage(index)	
	return 'updateV1 ' ..  AstralKeys[index].name .. ":" .. AstralKeys[index].class .. ':' .. AstralKeys[index].realm .. ':' .. AstralKeys[index].map .. ':' .. AstralKeys[index].level .. ':' .. AstralKeys[index].usable .. ':' .. AstralKeys[index].a1 .. ':' .. AstralKeys[index].a2 .. ':' .. AstralKeys[index].a3
end

function e.AnnounceNewKey(keyLink, level)
	if not BROADCAST and not IsInGroup() then return end
	SendChatMessage('Astral Keys: New key ' .. keyLink .. ' +' .. level, 'PARTY')
end

akComms:SetScript('OnEvent', function(self, event, ...)
	prefix, msg, _, sender = ...
	if not (prefix == 'AstralKeys') then return end

	arg, content = msg:match("^(%S*)%s*(.-)$")
	if arg == 'updateV1' then
		sender, unitClass, unitRealm = content:match('(%a+):(%a+):([%a%s-\']+)')
		dungeonID, keyLevel, isUsable, affixOne, affixTwo, affixThree = content:match(':(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)')
		dungeonID = tonumber(dungeonID)
		keyLevel = tonumber(keyLevel)
		isUsable = tonumber(isUsable)
		affixOne = tonumber(affixOne)
		affixTwo = tonumber(affixTwo)
		affixThree = tonumber(affixThree)


		local currenta1 = tonumber(e.GetAffix(1))

		if currenta1 ~= 0 and affixOne ~= 0 then
			if tonumber(affixOne) ~= currenta1 then
				e.WipeFrames()
 				--SendAddonMessage('AstralKeys', 'request', 'GUILD')
			end
		end

		if affixOne ~= 0 then
			e.SetAffix(1, affixOne)
		end

		if affixTwo ~= 0 then
			e.SetAffix(2, affixTwo)
		end

		if affixThree ~= 0 then
			e.SetAffix(3, affixThree)
		end

		local id = e.GetUnitID(sender..unitRealm)

		if id then
			if AstralKeys[id].level < keyLevel or AstralKeys[id].usable ~= isUsable then
				AstralKeys[id].map = dungeonID
				AstralKeys[id].level = keyLevel
				AstralKeys[id].usable = isUsable
				e.UpdateFrames()
			end
		else
			table.insert(AstralKeys, {name = sender, class = unitClass, realm = unitRealm, map = dungeonID, level = keyLevel, usable = isUsable, a1 = affixOne, a2 = affixTwo, a3 = affixThree})
			e.SetUnitID(sender .. unitRealm, #AstralKeys)
			e.UpdateFrames()
		end

		e.UpdateAffixes()
	end
	if arg == 'request' then
		if sender == e.PlayerName() .. '-' .. e.PlayerRealm() then return end
		for i = 1, #AstralKeys do
			SendAddonMessage('AstralKeys', AddonMessage(i), 'GUILD')
		end
	end
	end)

function e.AnounceCharacterKeys(channel)
	for i = 1, #AstralCharacters do
		local id = e.UnitID(e.CharacterName(i))

		if id then
			local link, keyLevel = e.CreateKeyLink(id)
			if channel == 'PARTY' and not IsInGroup() then return end
			SendChatMessage(e.CharacterName(i) .. ' ' .. link .. ' +' .. keyLevel, channel)
		end
	end
end