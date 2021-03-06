local function throw_hook(itemstack, user, vel)
	local inv = user:get_inventory()
	local pos = user:getpos()
	local dir = user:get_look_dir()
	local yaw = user:get_look_yaw()
	if pos and dir and yaw then
		if not minetest.setting_getbool("creative_mode") then
			itemstack:add_wear(65535/100)
		end
		pos.y = pos.y + 1.5
		local obj = minetest.add_entity(pos, "grapple:hook")
		if obj then
			obj:setvelocity({x=dir.x * vel, y=dir.y * vel, z=dir.z * vel})
			obj:setacceleration({x=dir.x * -3, y=-10, z=dir.z * -3})
			obj:setyaw(yaw + math.pi)
			local ent = obj:get_luaentity()
			if ent then
				ent.player = ent.player or user
				ent.itemstack = itemstack
			end
		end
	end
end

minetest.register_entity("grapple:hook", {
	physical = true,
	timer = 0,
	visual = "wielditem",
	visual_size = {x=1/2, y=1/2},
	textures = {"grapple:grapple_hook"},
	player = nil,
	itemstack = "",
	collisionbox = {-1/4,-1/4,-1/4, 1/4,1/4,1/4},
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({fleshy=0})
		if staticdata == "expired" then
			self.object:remove()
		end
	end,
	on_step = function(self, dtime)
		if not self.player then
			return
		end
		self.timer = self.timer + dtime
		if self.timer > 0.25 then
			local pos = self.object:getpos()
			local below = {x=pos.x, y=pos.y - 1, z=pos.z}
			local node = minetest.get_node(below)
			if node.name ~= "air" then
				self.object:setvelocity({x=0, y=-10, z=0})
				self.object:setacceleration({x=0, y=0, z=0})
				if minetest.get_item_group(node.name, "liquid") == 0 and
						minetest.get_node(pos).name == "air" then
					self.player:moveto(pos)
				end
				if minetest.get_item_group(node.name, "lava") == 0 then
					minetest.add_item(pos, self.itemstack)
				end
				self.object:remove()
			end
			self.timer = 0
		end
	end,
	get_staticdata = function(self)
		return "expired"
	end,
})

minetest.register_alias("shooter:grapple_hook", "grapple:grapple_hook")

minetest.register_tool("grapple:grapple_hook", {
	description = "Grappling Hook",
	inventory_image = "grapple_hook.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "nothing" then
			return itemstack
		end
		throw_hook(itemstack, user, 14)
		return ""
	end,
})

minetest.register_craft({
	output = "grapple:grapple_hook",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"},
	},
})
