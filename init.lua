local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--[[
Sources of formspecs:
	'minetest.show_formspec' calls
	'player.set_inventory_formspec' calls
	"formspec" field in node metadata
	builtin formspecs like the Esc menu

	TODO: style choosing formspec, imediatelly updates to show selected style
]]
-- when true, changing the players style doesn't override the prepend
local soft_prepend = minetest.settings:get_bool("soft_prepend", false)

cfs = {
	styles = {},
	soft_prepend = soft_prepend
}
dofile(modpath .. "/api.lua")
dofile(modpath .. "/style_null.lua")
dofile(modpath .. "/style_example.lua")
dofile(modpath .. "/testing_fs.lua")
dofile(modpath .. "/command.lua")





-- debug function
local function print_table(t)
	for k, v in pairs(t) do
		-- minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
		print(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

-- in theory it would be nice if it were possible to affect all formspecs
-- in practice it's only really possible for 'minetest.show_formspec' calls
local interception_mode = true

-- can't insert anything before these elemnets
local skip_elements = {
	["formspec_version"] = true,
	["size"] = true,
	["position"] = true,
	["anchor"] = true,
	["padding"] = true,
	["no_prepend"] = true,
}

-- fs - formspec to be styled
-- style_name - style to be used, if player, take style from players meta key: "formspec_style"
-- force_prepend - disable player prepend and add style prepend to formspec
function cfs.style_formspec(fs, style_name, force_prepend)

	-- Get the players choosen style
	if type(style_name) == "userdata" then
		local meta = style_name:get_meta()
		style_name = meta:get("formspec_style")
	end
	if not style_name then
		style_name = "null"
	end

	-- style validation
	local style = cfs.styles[style_name]
	if not style then
		minetest.log("warning", "Trying to style formspec with invalid style: '" .. style_name .. "'")
		return fs
	end

	-- formspec_version
	local version = tonumber(fs:match("formspec_version%[(%d)%]")) or 1

	-- formspec_table
	local ft = cfs.formspec_to_table(fs)

	local tbi = {} -- to be inserted
	local ii = 1 -- insertion index
	-- skip a few element that have to come first
	while skip_elements[ft[ii]:match("[^%[]*")] do
		ii = ii + 1
	end

	-- ignore player prepend in favor of style prepend
	if force_prepend or cfs.soft_prepend then
		tbi[#tbi + 1] = {ii, "no_prepend[]"}
		tbi[#tbi + 1] = {ii, (style.prepend or "")}
	end

	-- add unique per formspec elements like backgrounds
	local once = style.do_once and style.do_once(fs, version)
	if once then
		tbi[#tbi + 1] = {ii, once}
	end

	-- for each formspec elemnt do
	for i, element in pairs(ft) do

		local el_name, el_args = element:match("([^%[%]]+)(%[[^%[%]]*%])")
		-- if the style has a callback for the current elemnt, call it
		if style[el_name] then
			local replacement, addition = style[el_name](el_args, fs, version)
			-- replace current elemnt
			if replacement then
				ft[i] = replacement
			end
			-- and que new elements for addition
			if addition then
				tbi[#tbi + 1] = {ii, addition}
			end
		end

		-- update minimal index at which new elements can be added
		if element:find("container", nil, true) then
			ii = i + 1
		end

	end

	-- print_table(ft)

	-- apply changes
	for n, e in ipairs(tbi) do
		table.insert(ft, (n - 1) + e[1], e[2])
	end

	return table.concat(ft)
end


minetest.register_on_joinplayer(function(player, last_login)
	local meta = player:get_meta()
	local style_name = meta:get("formspec_style")

	if style_name and cfs.styles[style_name] and not cfs.soft_prepend then
		player:set_formspec_prepend(cfs.styles[style_name].prepend)
	end
end)
