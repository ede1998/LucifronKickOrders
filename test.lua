
function GetNumGroupMembers()
	return 30;
end

function GetRaidRosterInfo(i)
	if i == 1 then
		return "Trpatches",1,2,3,4,"ROGUE","", true, 0, nil
	elseif i == 2 then
		return "Ragestorm",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 3 then
		return "Chilldose",1,2,3,4,"ROGUE","", true, 0, nil
	elseif i == 4 then
		return "Theddios",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 5 then
		return "Snotti",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 6 then
		return "Sfaix",1,2,3,4,"ROGUE","", true, 0, nil
	elseif i == 7 then
		return "Vojtessara",1,2,3,4,"MAGE","", false, 0, nil
	elseif i == 8 then
		return "Drfjortis",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 9 then
		return "Spaek",1,2,3,4,"ROGUE","", true, 0, nil
	elseif i == 10 then
		return "Lykkeleeten",1,2,3,4,"ROGUE","", true, 0, nil
	elseif i == 11 then
		return "Styxia",1,2,3,4,"ROGUE","", true, 0, nil
	elseif i == 12 then
		return "Velerefodis",1,2,3,4,"DRUID","", true, 0, nil
	elseif i == 13 then
		return "Warrzone",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 14 then
		return "Swiftz",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 15 then
		return "Verres",1,2,3,4,"WARLOCK","", true, 0, nil
	elseif i == 16 then
		return "Ohjohny",1,2,3,4,"WARRIOR","", true, 0, nil
	elseif i == 17 then
		return "Dippindots",1,2,3,4,"WARLOCK","", true, 0, nil
	elseif i == 18 then
		return "Padka",1,2,3,4,"MAGE","", true, 0, nil
	elseif i == 19 then
		return "Psyball",1,2,3,4,"MAGE","", true, 0, nil
	elseif i == 20 then
		return "Zaris",1,2,3,4,"HUNTER","", true, 0, nil
	elseif i == 21 then
		return "Jash",1,2,3,4,"WARRIOR","", true, 0, "MAINTANK"
	elseif i == 22 then
		return "Venomizzy",1,2,3,4,"HUNTER","", true, 0, nil
	elseif i == 23 then
		return "Sylvanasz",1,2,3,4,"HUNTER","", true, 0, nil
	elseif i == 24 then
		return "Strawhatluff",1,2,3,4,"WARRIOR","", true, 0, "MAINTANK"
	elseif i == 25 then
		return "Venuss",1,2,3,4,"WARLOCK","", true, 0, nil
	elseif i == 26 then
		return "Tydeas",1,2,3,4,"PALADIN","", true, 0, nil
	elseif i == 27 then
		return "Cepesh",1,2,3,4,"WARLOCK","", true, 0, nil
	elseif i == 28 then
		return "Toviath",1,2,3,4,"DRUID","", true, 0, "MAINTANK"
	elseif i == 29 then
		return "Bluez",1,2,3,4,"HUNTER","", true, 0, nil
	elseif i == 30 then
		return "Coldzera",1,2,3,4,"MAGE","", true, 0, nil
	end
end

function SendChatMessage(str, bs)
	print(str)
end

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
		SendChatMessage(marks[k].." => "..kickers, "bla")
	end
end

DetermineKickOrders()
