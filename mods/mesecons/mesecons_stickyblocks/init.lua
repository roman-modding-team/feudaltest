-- Sticky blocks can be used together with pistons or movestones to push / pull
-- structures that are "glued" together using sticky blocks

-- All sides sticky block
minetest.register_node("mesecons_stickyblocks:sticky_block_all", {
	description = "All-sides sticky block",
	tiles = {"default_grass.png^default_footprint.png"},
	groups = {dig_immediate=2},
	mvps_sticky = function (pos, node)
		local connected = {}
		for _, r in ipairs(mesecon.rules.alldirs) do
			table.insert(connected, vector.add(pos, r))
		end
		return connected
	end
})
minetest.register_craft({
	output = "mesecons_stickyblocks:sticky_block_all",
	recipe = {
		{"group:mesecon_conductor_craftable","default:stone", "mesecons_pistons:wax"},
	}
})