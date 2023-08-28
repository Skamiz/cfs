minetest.register_chatcommand("style", {
    params = "style [mtg|cicrev|mindustry|etc...]",  -- Short parameter description
    description = "Change formspec style. Call without parameters to see aviable styles",  -- Full description

    func = function(name, param)
		if param == "" then
			local s = ""
			for style_name, _ in pairs(cfs.styles) do
				s = s .. style_name .. ", "
			end

			return false, "Aviable styles are: " .. s
		end

		if not cfs.styles[param] then
			return false, "There is no style: '" .. param .. "'"
		else
			local player = minetest.get_player_by_name(name)
			cfs.set_player_style(player, param)
			return true, "Style set to: " .. param

		end

	end,
    -- Called when command is run. Returns boolean success and text output.
    -- Special case: The help message is shown to the player if `func`
    -- returns false without a text output.
})
