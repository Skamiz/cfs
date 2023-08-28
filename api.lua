-- set players style prepend, and meta tag
function cfs.set_player_style(player, style_name)
	-- print("Switching to style: " .. style_name)
	local style = cfs.styles[style_name]
	if not style then
		minetest.log("warning", "Trying to set player style to invalid style: '" .. style_name .. "'")
	end
	local meta = player:get_meta()
	meta:set_string("formspec_style", style_name)
	if style.prepend and not cfs.soft_prepend then
		player:set_formspec_prepend(style.prepend)
	end
end

-- turn formspec into a table containing individual elements
function cfs.formspec_to_table(fs)
	local ft = {}
	-- for s in fs:gmatch ("[^%[%]]+%[[^%[%]]*%]") do -- this breaks images which use "[combine:"
	for s in fs:gmatch ("[^%[%]]+%[[^%]]*%]") do
		ft[#ft + 1] = s
	end
	return ft
end

-- return the coordinates coresponding to each inventory slot in a list
-- assuming the list has default size and offset
function cfs.slot_in_list(x, y, w, h)
	local f = function()
		for i = 0, w-1 do
			for j = h-1, 0, -1 do
				coroutine.yield(x + i*1.25, y + j*1.25)
			end
		end
	end

	return coroutine.wrap(f)
end

-- sepparate arguments of formspec elenents
-- turn position and size arguments into vectors
function cfs.explode_fs_args(args)
	local at = {}
	for arg in args:gmatch("[%[%];]([^;%[%]]*)") do
		-- print (arg)
		local x, y = arg:match("(%--[%d%.]+),(%--[%d%.]+)")

		if x and y then
			x, y = tonumber(x), tonumber(y)
			arg = vector.new(x, y, 0)
			-- convenience allias
			arg.w, arg.h = arg.x, arg.y
		end

		at[#at + 1] = arg
	end
	-- dispose of garbage result
	at[#at] = nil

	return unpack(at)
end

local replacements = {[":"] = "\\:", ["^"] = "\\^"}

function cfs.escape_image_modifiers(image)
	-- return image:gsub("[^\\]([:%^])", replacements)
	return image:gsub("[:%^]", replacements)
end

-- image, image width, image height, tiled width, tiled height
function cfs.tile_image(image, iw, ih, nx, ny)
	local tba = {"[combine:" .. nx .. "x" .. ny .. ""}
	for x = 0, math.ceil(nx/iw)-1 do
		for y = 0, math.ceil(ny/ih)-1 do
			tba[#tba + 1] = ":" .. x * iw .. "," .. y * ih .. "=" .. image
		end
	end
	return table.concat(tba)
end

-- image, image width, image height, direction, offset?
-- 		direction - "horizontal"/"vertical"
-- WARNING: can only handle simple images, nested '[combines' are a crapjob
function cfs.mirror_image(image, iw, ih, direction, offset)
	if not offset then offset = 0 end
	if image:find("[:%^]") then
		image = cfs.escape_image_modifiers(image)
	end
	local mirrored
	if direction == "horizontal" then
		mirrored = "(" .. image .. "^[transformFX)"
		return "[combine:" .. 2*iw + offset .. "x" .. ih .. ":0,0=" .. image .. ":" .. iw + offset ..",0=" .. mirrored
	else
		mirrored = "(" .. image .. "^[transformFY)"
		return "[combine:" .. iw .. "x" .. 2*ih + offset .. ":0,0=" .. image .. ":0," .. ih + offset .."=" .. mirrored
	end
end
