formspec_edit.prepend = ""
formspec_edit.inventories = {
	main = {width = 8, size = 32}
}

--Get formspec style
local styling = minetest.settings:get("formspec_editor.style")
if not styling or styling == "" then
	styling = "builtin"
end

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

	formspec_edit.lua_env.default = {}
	function formspec_edit.lua_env.default.get_hotbar_bg(x, y)
		local out = ""
		for i=0,7,1 do
			out = out .."image["..x+i..","..y..";1,1;gui_hb_bg.png]"
		end
		return out
	end
elseif styling == "mineclone2" then
	------------------------------------------------
	---------------MineClone2 code------------------
	------------------------------------------------
	--Sadly, this code doesn't support inventory slot styling (texture based)
	prepend = table.concat({
		"listcolors[#9990;#FFF7;#FFF0;#000;#FFF]",
		"style_type[image_button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]",
		"style_type[button;border=false;bgimg=mcl_inventory_button9.png;bgimg_pressed=mcl_inventory_button9_pressed.png;bgimg_middle=2,2]",
		"style_type[field;textcolor=#323232]",
		"style_type[label;textcolor=#323232]",
		"style_type[textarea;textcolor=#323232]",
		"style_type[checkbox;textcolor=#323232]",
		"bgcolor[#00000000]",
		"background9[1,1;1,1;mcl_base_textures_background9.png;true;7]",
	})

	--Add custom inventory function to lua env
	formspec_edit.lua_env.mcl_formspec = {}
	function formspec_edit.lua_env.mcl_formspec.get_itemslot_bg(x, y, w, h)
		local out = ""
		for i = 0, w - 1, 1 do
			for j = 0, h - 1, 1 do
				out = out .."image["..x+i..","..y+j..";1,1;mcl_formspec_itemslot.png]"
			end
		end
		return out
	end

	--Same as above, but for v4 forms
	function mcl_formspec.get_itemslot_bg_v4(x, y, w, h)
		local out = ""
		for i = 0, w - 1, 1 do
			for j = 0, h - 1, 1 do
				out = out .."image["..x+i+(i*0.25)..","..y+j+(j*0.25)..";1,1;mcl_formspec_itemslot.png]"
			end
		end
		return out
	end

	--Add mcl2 color codes
	formspec_edit.lua_env.mcl_colors = {
		BLACK = "#000000",
		DARK_BLUE = "#0000AA",
		DARK_GREEN = "#00AA00",
		DARK_AQUA = "#00AAAA",
		DARK_RED = "#AA0000",
		DARK_PURPLE = "#AA00AA",
		GOLD = "#FFAA00",
		GRAY = "#AAAAAA",
		DARK_GRAY = "#555555",
		BLUE = "#5555FF",
		GREEN = "#55FF55",
		AQUA = "#55FFFF",
		RED = "#FF5555",
		LIGHT_PURPLE = "#FF55FF",
		YELLOW = "#FFFF55",
		WHITE = "#FFFFFF",
		background = {
			BLACK = "#000000",
			DARK_BLUE = "#00002A",
			DARK_GREEN = "#002A00",
			DARK_AQUA = "#002A2A",
			DARK_RED = "#2A0000",
			DARK_PURPLE = "#2A002A",
			GOLD = "#2A2A00",
			GRAY = "#2A2A2A",
			DARK_GRAY = "#151515",
			BLUE = "#15153F",
			GREEN = "#153F15",
			AQUA = "#153F3F",
			RED = "#3F1515",
			LIGHT_PURPLE = "#3F153F",
			YELLOW = "#3F3F15",
			WHITE = "#373501",
		}
	}

	--Add mcl2 inventory lists
	formspec_edit.inventories = {
		main = {width = 9, size = 36},
		armor = {size = 5},
		craft = {width = 3, size = 9},
	}
end

formspec_edit.prepend = prepend