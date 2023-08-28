--[[
example stlye

read this file to get started on writng your own style
]]
local p = 1/16
local style = {
	prepend = ""
		-- putting 'formspec_version' into the prepend is problematic since it messes up formpecs which are designed for version 1
		-- on the other hand, some variations of 'bgcolor' can not be used on version 1
		-- and the prepend is the only way to style builting formspecs like the Escape menu

		-- if you want the best of both worlds, use the prepend to style the Ecs menu and
		-- enable the 'soft_prepend' setting which causes this style prepend to be applied
		-- on a per formspec basis, rather then a per player one

		-- .. "formspec_version[6]"
		-- .. "bgcolor[;neither;]"

		-- background elements with enabled auto scaling are actually 1 pixel larger then they are supposed to be
		-- use manually sized backgrounds instead

		-- .. "background9[0,0;10.25,10.25;cfs_example_background.png;true;12]"

		-- listcolors[<slot_bg_normal>;<slot_bg_hover>;<slot_border>;<tooltip_bgcolor>;<tooltip_fontcolor>]
		.. "listcolors[#0000;#fff2]"

		.. "style_type[button;font=mono;border=false;bgimg_middle=4;padding=-4]"
		.. "style_type[button;bgimg=cfs_example_button.png]"
		.. "style_type[button:hovered;bgimg=cfs_example_button_hovered.png]"
		.. "style_type[button:pressed;bgimg=cfs_example_button_pressed.png]"

		-- 'bgimg_middle' adds automatic padding when used,
		-- use explicit negative padding to counter this and maintain image resolution
		.. "style_type[image_button;font=mono;border=false;bgimg_middle=4;padding=-4]"
		.. "style_type[image_button;bgimg=cfs_example_button.png]"
		.. "style_type[image_button:hovered;bgimg=cfs_example_button_hovered.png]"
		.. "style_type[image_button:pressed;bgimg=cfs_example_button_pressed.png]"

		-- item_image_button inherits style from image_button when not specified
		,

		-- callback for stuff that needs to be done only once per formspec, like setting an acurately sized background
		-- fs - original unmodified formspec to be styled
		-- version - formspec version
		-- 		in theory this could be used to support styling of both version 1 and the later 'true' coordinate systems
		-- 		but v1 coordinates are awful to work with, just update all your formspecs to the latest version instead
		do_once = function(fs, version)
			-- capture patern to get formspec size
			local w, h = fs:match("size%[([%d%.]+),([%d%.]+)")
			local f = ""
				.. "bgcolor[;neither;]"
				.. "background9[0,0;" .. w .. "," .. h .. ";cfs_example_background.png;false;12]"
			-- returned string will be added the the formspec
			return f
		end,

		-- to modify / add to a specific formspec element write a callback function with the elements name
		-- args - string containing argumets/properties of a formspec elements
		-- fs - original unmodified formspec to be styled
		-- version - formspec version
		list = function(args, fs, ver)
			-- sepparate args string into individual components and turn position/size args into vectors
			local inv_loc, list_name, pos, size = cfs.explode_fs_args(args)
			-- vector coordinates are mapped both, to x and y, and w and h, to make the resulting code more readable
			local tba = {}
			-- helper function which, when provided with list pos and size,
			-- returns coordinates of each individual list slot
			for x, y in cfs.slot_in_list(pos.x , pos.y , size.w, size.h) do
				tba[#tba + 1] = "image[" .. x - p .. "," .. y - p .. ";" .. 1 + 2*p .. "," .. 1 + 2*p .. ";cfs_example_list_slot.png]"
			end

			-- two return values
			-- the first can be used to replace the curent forsmpec element
			-- 		return an empty string to completely delete it or nil to leave it unchanged
			-- the second value is used to add new elements to the forsmpec
			-- they will be inserted as early as possible into the element order
			-- to allow them to be used as background to the current one
			-- though the acutall insertion won't happen until all callbacks are finished
			return nil, table.concat(tba)
		end,

		-- need to style something for which formspecs don't have an equivalent?
		-- use boxes instead!
		-- boxes provide a position and size with which you can specify areas for highliting, placing style specific images, etc...
		-- use the box color to encode what it is supposed to represent
		-- the box color can be fully transprant, that way, when a style doesn't provide
		-- a callback that does anything with them, they stay hidden and out of the way
		box = function(args, fs, ver)
			local pos, size, color = cfs.explode_fs_args(args)
			-- sugested convention
			-- use transparent white for outsets, areas that are raised above their surroundings
			if color == "#FFF0" then
				local outset = "image[" .. pos.x - p .. "," .. pos.y - p .. ";" .. size.x + 2*p .. "," .. size.y + 2*p .. ";cfs_example_outset.png;4]"
				return "", outset
			-- use transparent black, for insets, areas that are set deeper into the formspec
			elseif color == "#0000" then
				local inset = "image[" .. pos.x - p .. "," .. pos.y - p .. ";" .. size.x + 2*p .. "," .. size.y + 2*p .. ";cfs_example_inset.png;4]"
				return "", inset
			else
				-- if a box doesn't match a color which we use to signyfy a special function
				-- don't make any changes, since it's problaby used for their intended purpose
				return
			end
		end,
}

-- don't forget to add your style to this table, so it actually becomes available
cfs.styles["example"] = style
