local pvpzone = {}
local pvpzone_store = AreaStore()
pvpzone_store:from_file(minetest.get_worldpath() .. "/pvpzone_store.dat")

-- Register privilege and chat command.
minetest.register_privilege("pvpzone_admin", "Can set and remove PvP areas.")

minetest.register_chatcommand("pvpzone", {
	description = "Mark and set areas for PvP.",
	params = "{ pos1 | pos2 | set | named <areaname> | remove <id> | list }",
	privs = "pvpzone_admin",
	func = function(name, paramlist)
		local piterator = string.gmatch(paramlist,"%S+")
		local param = piterator()
		local pos = vector.round(minetest.get_player_by_name(name):getpos())
		if param == "pos1" then
			if not pvpzone[name] then
				pvpzone[name] = {pos1 = pos}
			else
				pvpzone[name].pos1 = pos
			end
			minetest.chat_send_player(name, "Position 1: " .. minetest.pos_to_string(pos))
		elseif param == "pos2" then
			if not pvpzone[name] then
				pvpzone[name] = {pos2 = pos}
			else
				pvpzone[name].pos2 = pos
			end
			minetest.chat_send_player(name, "Position 2: " .. minetest.pos_to_string(pos))
		elseif param == "set" or param == "named" then
			local areaname = "pvp_area"
			if param == "named" then
				local newname = piterator()
				if newname then areaname = newname end
			end

			if not pvpzone[name] or not pvpzone[name].pos1 then
				minetest.chat_send_player(name, "Position 1 missing, use \"/pvpzone pos1\" to set.")

			elseif not pvpzone[name].pos2 then
				minetest.chat_send_player(name, "Position 2 missing, use \"/pvpzone pos2\" to set.")

			else
				local areaID = pvpzone_store:insert_area(pvpzone[name].pos1, pvpzone[name].pos2, areaname)
				minetest.chat_send_player(name, "Area "..areaname.." ["..areaID.."] has been set.")
				pvpzone_store:to_file(minetest.get_worldpath() .. "/pvpzone_store.dat")
				area_list[areaID] = {name = name, min = pvpzone[name].pos1, max = pvpzone[name].pos2, data = areaname}
				save_area_list()
			end

		elseif param == "remove" then
			local areaID = piterator()
			if pvpzone_store:remove_area(areaID) then
				pvpzone_store:to_file(minetest.get_worldpath() .. "/pvpzone_store.dat")
				area_list[areaID] = nil
				save_area_list()
				minetest.chat_send_player(name, "Removed area "..areaID)
			else
				minetest.chat_send_player(name, "Invalid area "..areaID)
			end

		elseif param == "list" then
			local i = 1
			while true do
				local thisarea = pvpzone_store:get_area(i,true,true)
				if thisarea == nil or i > 10 then
					break
				end

				local areastring = "Area "..i.." : "
				areastring = areastring .. thisarea.data .. " from "..minetest.pos_to_string(thisarea.min).." to "..minetest.pos_to_string(thisarea.max)

				minetest.chat_send_player(name, areastring )
				i = i+1
			end
		else
			minetest.chat_send_player(name, "Invalid usage.  Type \"/help pvpzone\" for more information.")
		end
	end
})

-- Register punchplayer callback.
minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	for k, v in pairs(pvpzone_store:get_areas_for_pos(player:getpos())) do
		if k then
			return false
		end
	end
	return true
end)
