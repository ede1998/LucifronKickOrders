numberOfAdds = 4
kickersPerAdd = 3

kickerPriority = {
	["ROGUE"] = 1,
	["WARRIOR"] = 1,
	["MAGE"] = 2
}

marks = {
	"{skull}",
	"{cross}",
	"{square}",
	"{triangle}"
}

function compareKickerPriority(a,b)
	if a.ClassPriority == b.ClassPriority then
		return a.Name < b.Name
	else
		return a.ClassPriority < b.ClassPriority
	end
end

function FindPotentialKickers()
	local potential_kickers = {}
	for i = 1,GetNumGroupMembers() do
		local name, _, _, _,_, class, _, online, _, role = GetRaidRosterInfo(i)
		if name ~= nil and class ~= nil and online then
			local kickerPriority = kickerPriority[class] or 1000
			if role ~= "MAINTANK" and kickerPriority < 100 then
				table.insert(potential_kickers, { Name = name, Class = class, ClassPriority = kickerPriority })
			end
			--if role == nil then role = "" end
			--SendChatMessage("name: "..name..", class: "..class..", role: "..role, "RAID_WARNING")
		end
	end
	return potential_kickers
end

function AssignKickersToTarget(potential_kickers)
	local add_to_kickers = {}
	for i = 1, #potential_kickers do
		local add_number = (i-1)%numberOfAdds+1;
		print("ADD: "..add_number)
		local currently_assigned_kickers = add_to_kickers[add_number] or {}

		print("BEFORE=> "..table.concat(currently_assigned_kickers,","))
		table.insert(currently_assigned_kickers, potential_kickers[i].Name)
		add_to_kickers[add_number] = currently_assigned_kickers
		print("AFTER => "..table.concat(currently_assigned_kickers,","))

		if numberOfAdds * kickersPerAdd  <= i then
			break
		end
	end
	return add_to_kickers
end

function DetermineKickOrders()
	local potential_kickers = FindPotentialKickers()

	table.sort(potential_kickers, compareKickerPriority)
	print("Potential kickers in raid: "..#potential_kickers)

	local add_to_kickers = AssignKickersToTarget(potential_kickers)

	print("Done assigning kickers.")

	for k,v in pairs(add_to_kickers) do
		local kickers = table.concat(v, " ")
		SendChatMessage(marks[k].." => "..kickers, "RAID_WARNING")
	end
end

function SlashCmdList_AddSlashCommand(name, func, ...)
    SlashCmdList[name] = func
    local command = ''
    for i = 1, select('#', ...) do
        command = select(i, ...)
        if strsub(command, 1, 1) ~= '/' then
            command = '/' .. command
        end
        _G['SLASH_'..name..i] = command
    end
end

function RegisterSlashCommand()
	SlashCmdList_AddSlashCommand("LUCIFRONKICKORDERS_SLASHCMD", function(parameters)
		DetermineKickOrders()
	end, "lucifronkickorders", "lko")
end

local function OnAddonLoaded()
		RegisterSlashCommand()
end

local function OnEvent(self, event, arg1, arg2)
	if event == "ADDON_LOADED" and arg1 == "LucifronKickOrders" then
		OnAddonLoaded()
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)
