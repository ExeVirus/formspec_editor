---------------------------------
---------Formspec Editor---------
---------------------------------
-----------By ExeVirus-----------

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

--Load provided file if present
local filepath = minetest.settings:get("formspec_editor.file_path")
if not filepath or filepath == "" then
	filepath = modpath .. "/formspec.spec"
end

--Get styling presets
local styling = minetest.settings:get("formspec_editor.style")
if not styling or styling == "" then
	styling = "builtin"
end

local error_formspec = [[
formspec_version[4]
size[8,2]
label[0.375,0.5;Error:formspec.spec is either ]
label[0.375,1;non-existent,or empty]
]]

--Crash if not singleplayer
--TODO: hide the 'Host server' checkbox in main menu then possible
if not minetest.is_singleplayer() then
	error("[formspec_editor] This game doesn't work in multiplayer!")
end

--function definitions

-----------------------------------
--load_formspec()
-----------------------------------
local function load_formspec()
	local file = io.open(filepath, "rb")
	if file == nil then
		return error_formspec
	else
		local content = file:read("*all")
		file:close()
		if content == nil then
			return error_formspec
		else
			return content
		end
	end
end

-----------------------------------
--update_formspec()
-----------------------------------
local function update_formspec(player_name)
	minetest.after(0.1, function(name)
		minetest.show_formspec(name, "fs", load_formspec())
	end, player_name)
end

-----------------------------------
--apply_styling()
-----------------------------------
local function apply_styling(player_ref)
	local prepend = ""
	if styling == "minetest_game" then
		------------------------------------------------
		---------------Minetest Game code---------------
		------------------------------------------------
		prepend = [[
			bgcolor[#080808BB;true]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
		]]
		local name = player_ref:get_player_name()
		local info = minetest.get_player_information(name)
		if info.formspec_version > 1 then
			prepend = prepend .. "background9[5,5;1,1;mtg_gui_formbg.png;true;10]"
		else
			prepend = prepend .. "background[5,5;1,1;mtg_gui_formbg.png;true]"
		end
	elseif styling == "mineclone2" then
		------------------------------------------------
		---------------MineClone2 code------------------
		------------------------------------------------
		--Sadly, this code doesn't support inventory slot styling (texture based)
		prepend = "listcolors[#9990;#FFF7;#FFF0;#000;#FFF]"..
			"style_type[image_button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
			"style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]"..
			"style_type[field;textcolor=#323232]"..
			"style_type[label;textcolor=#323232]"..
			"style_type[textarea;textcolor=#323232]"..
			"style_type[checkbox;textcolor=#323232]"..
			"bgcolor[#00000000]"..
			"background9[1,1;1,1;mcl_base_textures_background9.png;true;7]"
	end
	player_ref:set_formspec_prepend(prepend)
end

-----------------------------------
--turn_off_hud()
-----------------------------------
local function turn_off_hud(player_ref)
	player_ref:hud_set_flags({
		hotbar = false,
		healthbar = false,
		crosshair = false,
		wielditem = false,
		breathbar = false,
		minimap = false,
		minimap_radar = false,
	})
end

-----------------------------------
--set_sky()
-----------------------------------
local function set_sky(player_ref)
	player_ref:set_sky({
		base_color = "#AAF",
		type = "plain",
		clouds = false,
	})
	player_ref:set_stars({visible = false})
    player_ref:set_sun({visible = false})
    player_ref:set_moon({visible = false})
	player_ref:override_day_night_ratio(0)
end

--Registrations

-----------------------------------
--on_joinplayer()
-----------------------------------
minetest.register_on_joinplayer(function(player_ref,_)
	apply_styling(player_ref)
	turn_off_hud(player_ref)
	set_sky(player_ref)
end)
-----------------------------------
--on_player_receive_fields()
-----------------------------------
minetest.register_on_player_receive_fields(function(player_ref, _, fields)
	if fields.quit then
		minetest.request_shutdown()
	end
	update_formspec(player_ref:get_player_name())
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
