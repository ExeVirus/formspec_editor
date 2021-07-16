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
local auto_update_time = 0.2 --seconds
local error_formspec = [[
formspec_version[4]
size[8,2]
position[0.5,0.5]
label[0.375,0.5;Error:formspec.spec is either ]
label[0.375,1;non-existent,or empty]
]]

--function declarations
local update_formspec = nil
local load_formspec = nil
local auto_update = nil
local turn_off_hud = nil

--Registrations

-----------------------------------
--on_joinplayer()
-----------------------------------
minetest.register_on_joinplayer(
function(player_ref,_)
    auto_update(player_ref:get_player_name())
    turn_off_hud(player_ref)
    set_sky(player_ref)
end
)
-----------------------------------
--on_player_receive_fields()
-----------------------------------
minetest.register_on_player_receive_fields(
function(player_ref, _, fields)
    if(fields.quit) then
        minetest.request_shutdown()
    end
    update_formspec(player_ref:get_player_name())
end
)

--function definitions

-----------------------------------
--auto_update()
-----------------------------------
auto_update = function(player_name)
    update_formspec(player_name)
    minetest.after(auto_update_time,auto_update,player_name)
end

-----------------------------------
--update_formspec()
-----------------------------------
update_formspec = function(player_name)
    minetest.after(0.1,
        function(player_name)
            minetest.show_formspec(player_name, "fs", load_formspec())
        end,
        player_name)
end

-----------------------------------
--load_formspec()
-----------------------------------
load_formspec = function()
    local io = insecure_env.io
    local file = io.open(modpath .. "/formspec.spec", "rb")
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
--turn_off_hud()
-----------------------------------
turn_off_hud = function(player_ref)
    local flags = {
        hotbar = false,
        healthbar = false,
        crosshair = false,
        wielditem = false,
        breathbar = false,
        minimap = false,
        minimap_radar = false,
    }
    player_ref:hud_set_flags(flags)
end

-----------------------------------
--set_sky()
-----------------------------------
set_sky = function(player_ref)
    local sky = {
        base_color = "#AAF",
        type = "plain",
        clouds = false,
    }
    player_ref:set_sky(sky)
    player_ref:override_day_night_ratio(0)
end