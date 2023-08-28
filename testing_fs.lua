local modname = minetest.get_current_modname()



local function get_style_buttons()
	local tba = {}
	local n = 0
	for style_name, _ in pairs(cfs.styles) do
		tba[#tba + 1] = "button[0," .. n ..";2,0.75;" .. style_name .. ";" .. style_name .. "]"
		n = n + 1
	end
	return table.concat(tba)
end

-- TODO: add all the possible formspec elements
local p = 1 / 16
local function get_style_fs()
	local fs = {
		"formspec_version[6]",
		"size[13.75,10.75]",
		-- "no_prepend[]",
		"container[0.5,0.5]",
		"container[0,0]",
		"box[0,0;2,9.75;#0000]",
		get_style_buttons(),
		"container_end[]",


		"container[3,0]",

		"list[current_player;main;0,5;8,4;]",

		"container[0,0]",
		"box[-0.25,-0.25;6.5,4;#FFF0]",
		"list[current_player;craft;0,0;3,3;]",
		"list[current_player;craftpreview;5,1.25;1,1;]",
		"container_end[]",



		"listring[current_player;main]",
		"listring[current_player;craft]",

		"scrollbaroptions[smallstep=1;max=30]",
		"scrollbar[7.5,4;2.25,0.25;horizontal;scrl_bar;0]",
		"scroll_container[7.5,0;2.25,3.5;scrl_bar;horizontal;]",

		-- button[<X>,<Y>;<W>,<H>;<name>;<label>]
		"button[0,0;2,1;button1;B1]",
		"image_button[0,1.25;1,1;cfs_test_item.png;button2;B2]",
		"item_image_button[0,2.5;1,1;cfs:test_node;button3;B3]",

		"scroll_container_end[]",

		"container_end[]",
		"container_end[]",
	}
	return table.concat(fs)
end

-- print(fs)

-- show debug formspec
-- minetest.register_on_joinplayer(function(player, last_login)
-- 	minetest.after(0.1, cfs.set_player_style, player, "mtg")
--
-- 	local fs = cfs.style_formspec(fs, player)
-- 	minetest.after(0.1, player.set_inventory_formspec, player, fs)
-- end)

minetest.register_craftitem("cfs:test_item", {
	description = "cfs test item",
	inventory_image = "cfs_test_item.png",
	on_use = function(itemstack, user, pointed_thing)
		local fs = cfs.style_formspec(get_style_fs(), user, true)
		minetest.show_formspec(user:get_player_name(), "cfs:test", fs)
	end,
})
minetest.register_node("cfs:test_node", {
	description = "cfs test node",
	tiles = {"cfs_test_node.png"},
	groups = {oddly_breakable_by_hand = 3},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local fs = cfs.style_formspec(get_style_fs(), clicker, true)
		minetest.show_formspec(clicker:get_player_name(), "cfs:test", fs)
	end,
})


minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "cfs:test" then return end
	for k, v in pairs(fields) do
		if cfs.styles[k] then
			cfs.set_player_style(player, k)
			local fs = cfs.style_formspec(get_style_fs(), player, true)
			minetest.show_formspec(player:get_player_name(), "cfs:test", fs)
		end
	end

end)
