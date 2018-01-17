pvpzone.hud = {}

--local player = minetest.get_player_by_name("username")


function pvpzone.update_hud(player)
	local name = player:get_player_name()
	pvpzone.hud[name] = player:hud_add({
		hud_elem_type = "text",
		number		  = "0xFF0000",
		position      = {x = 1, y = 1},
		offset        = {x = -8,   y = -8},
		text          = "Zone PvP!",
		alignment     = {x = -1, y = -1},
		scale         = {x = 100, y = 100},
	})
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		local pos = vector.round(player:getpos())
		
		player:hud_change(pvpzone.hud[name],"text","PvP Safe")
		player:hud_change(pvpzone.hud[name],"number","0xFFFFFF")
		for k, v in pairs(pvpzone_store:get_areas_for_pos(pos, true, true)) do
			if k then
				player:hud_change(pvpzone.hud[name],"text","PvP : "..v.data)
				player:hud_change(pvpzone.hud[name],"number","0xFF0000")
			end
		end
	end
end)


minetest.register_on_joinplayer(pvpzone.update_hud)

minetest.register_on_leaveplayer(function(player)
	--local name = player:get_player_name()
	--pvpzone.hud[name] = nil
end)