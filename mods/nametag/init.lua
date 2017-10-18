local nametags = {}
local checktimer = 0

function addtag(player)
    local pos = player:getpos()
    local ent = minetest.env:add_entity(pos, "nametag:tag")
	if not nametags[player] then
		local color = "W"
		local texture = "npcf_tag_bg.png"
		local x = math.floor(134 - ((player:get_player_name():len() * 11) / 2))
		local i = 0
		player:get_player_name():gsub(".", function(char)
			if char:byte() > 64 and char:byte() < 91 then
				char = "U"..char
			end
			texture = texture.."^[combine:84x14:"..(x+i)..",0="..color.."_"..char..".png"
			i = i + 11
		end)
			ent:set_properties({textures={texture}})
		if ent~= nil then
			ent:set_attach(player, "", {x=0,y=9,z=0}, {x=0,y=0,z=0})
			ent = ent:get_luaentity() 
			ent.wielder = player
			nametags[player:get_player_name()] = ent.object
		end
    end
end

function removetag(player)
	local tag = nametags[player:get_player_name()]
	if tag then
		tag:remove()
		tag = nil
	end
end

local nametag = {
	npcf_id = "nametag",
	physical = false,
	collisionbox = {x=0, y=0, z=0},
	visual = "sprite",
	textures = {"default_dirt.png"},--{"npcf_tag_bg.png"},
	visual_size = {x=2.16, y=0.18, z=2.16},--{x=1.44, y=0.12, z=1.44},
	on_activate = function(self, staticdata, dtime_s)
		if staticdata == "expired" then
			if self.wielder then
				removetag(wielder)
			else
				self.object:remove()
			end
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
}

minetest.register_globalstep(function(dtime)
	if checktimer > 2 then
		checktimer = 0
		for _, player in pairs(minetest.get_connected_players()) do
			if nametags[player:get_player_name()] then
				return
			else
				addtag(player)
			end
		end
	else
		checktimer = checktimer + dtime
	end
end)

function nametag:on_step(dtime)
	local wielder = self.wielder
	if wielder == nil then
		self.remove()
		 return
	elseif minetest.env:get_player_by_name(wielder:get_player_name()) == nil then
		self.remove()
		return
	else
		self.object:set_attach(wielder, "", {x=0,y=9,z=0}, {x=0,y=0,z=0})
		nametags[wielder:get_player_name()] = self.object
	end
end

minetest.register_entity("nametag:tag", nametag)

minetest.register_on_joinplayer(function (player)
	addtag(player)
end)

minetest.register_on_leaveplayer(function (player)
	removetag(player)
end)