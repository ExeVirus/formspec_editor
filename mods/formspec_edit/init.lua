---------------------------------
---------Formspec Editor---------
---------------------------------
-----------By ExeVirus-----------

formspec_edit = {}

--Fix builtin
minetest.register_alias("mapgen_stone", "air")
minetest.register_alias("mapgen_water_source", "air")

--Variables
local modpath = minetest.get_modpath("formspec_edit")

local insecure_env = minetest.request_insecure_environment()
if not insecure_env then
	error("[formspec_editor] Cannot access insecure environment!\n"..
	      "Please add 'formspec_edit' to your list of trusted mods in your settings")
end

local io = insecure_env.io
local update_time = tonumber(minetest.settings:get("formspec_editor.update_time")) or 0.2

--Get provided modpath if present
local filepath = minetest.settings:get("formspec_editor.file_path")
if not filepath or filepath == "" then
	filepath = modpath .. "/formspec.lua"
end

local error_formspec = [[
formspec_version[4]
size[8,2]
label[0.375,0.5;Error: formspec.lua is either]
label[0.375,1;non-existent,or empty]
]]

--Crash if not singleplayer
if not minetest.is_singleplayer() then
	error("[formspec_editor] This game doesn't work in multiplayer!")
end

-----------------------------------
--error_handler()
-----------------------------------
local function error_handler(msg)
	return string.format([[
		formspec_version[4]
		size[8,2]
		label[0.375,0.5;Error: %s]
	]], msg)
end


--Define the basic lua env (only contains safe functions)
formspec_edit.lua_env = {
	print = print, --can be useful for debugging
	dump = dump,
	dump2 = dump2,
	table = table,
	string = string,
	math = math,
	vector = vector,
	F = minetest.formspec_escape,
	C = minetest.colorize,
	CE = minetest.get_color_escape_sequence,
	S = function(str, ...) --oversimplificated version of minetest.translate
		local arg = {n=select('#', ...), ...}
		local arg_index = 1
		local translated = str:gsub("@(.)", function(matched)
			local c = string.byte(matched)
			if string.byte("1") <= c and c <= string.byte("9") then
				local a = c - string.byte("0")
				if a ~= arg_index then
					return str
				end
				if a > arg.n then
					return str
				end
				arg_index = arg_index + 1
				return arg[a]
			elseif matched == "n" then
				return "\n"
			else
				return matched
			end
		end)
		return translated
	end,
}

dofile(modpath.."/game_specific.lua")

--function definitions

---------------------------------
--check_updates()
---------------------------------

local cached_file = ""

local function check_updates()
	--attemp to open the file
	local file = io.open(filepath, "rb")
	if file == nil then
		return error_formspec
	else
		--read file content
		local content = file:read("*all")
		file:close()

		--validate content
		if content == nil then
			return error_formspec
		else
			if content == cached_file then
				return
			else
				cached_file = content
				--load code
				local func = load(content, "formspec_editor", "bt", formspec_edit.lua_env)
				local state, msg = pcall(func)
				if not state then
					return error_handler(msg)
				end
				print(dump(msg))
				return msg or "size[8,2]"
			end
		end
	end
end

-----------------------------------
--update_formspec()
-----------------------------------
local function update_formspec(player_name)
	local new = check_updates()
	if new then
		minetest.after(0.1, function(name)
			minetest.show_formspec(name, "fs", new)
		end, player_name)
	end
end


--Registrations

-----------------------------------
--on_joinplayer()
-----------------------------------
minetest.register_on_joinplayer(function(player,_)
	--Apply formspec prepend
	player:set_formspec_prepend(formspec_edit.prepend)

	--Create inventories
	local inv = player:get_inventory()
	for name,def in pairs(formspec_edit.inventories) do
		inv:set_size(name, def.size)
		if def.width then
			inv:set_width(name, def.width)
		end
	end

	--Hide builtin HUD elements
	player:hud_set_flags({
		hotbar = false,
		healthbar = false,
		crosshair = false,
		wielditem = false,
		breathbar = false,
		minimap = false,
		minimap_radar = false,
	})

	--Update sky
	player:set_sky({
		base_color = "#AAF",
		type = "plain",
		clouds = false,
	})
	player:set_stars({visible = false})
    player:set_sun({visible = false})
    player:set_moon({visible = false})
	player:override_day_night_ratio(0)
end)

-----------------------------------
--on_player_receive_fields()
-----------------------------------
minetest.register_on_player_receive_fields(function(player, _, fields)
	if fields.quit then
		minetest.request_shutdown()
	end
	update_formspec(player:get_player_name())
end)

local time = 0
minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time >= update_time then
		local player = minetest.get_connected_players()[1] --The game isn't supposed to work in multiplayer
		if player then
			update_formspec(player:get_player_name())
		end
		time = 0
	end
end)
