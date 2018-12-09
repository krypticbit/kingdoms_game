rule_table = {}
rule_language = {}
dofile(minetest.get_modpath("interact") .. "/rules-english.lua") --I put the rules in their own file so that they don't get lost/overlooked!
dofile(minetest.get_modpath("interact") .. "/rules-russian.lua")
dofile(minetest.get_modpath("interact") .. "/rules-deutsch.lua")
dofile(minetest.get_modpath("interact") .. "/rules-francais.lua")
dofile(minetest.get_modpath("interact") .. "/rules-espanol.lua")
dofile(minetest.get_modpath("interact") .. "/config.lua")

local all_languages = interact.default_language
for k in pairs(rule_table) do
	if k ~= interact.default_language then
		all_languages = all_languages..", "..k
		if rule_table[k].secondaryname then
			all_languages = all_languages.." ("..rule_table[k].secondaryname..")"
		end
	end
end

local function make_formspec(player, language)
	if not language then language = interact.default_language end
	local name = player:get_player_name()
	local size = { "size[10,4]" }
	table.insert(size, "label[1,0.5;List of Languages (eg: /rules english)]")
	table.insert(size, "label[1,1;"..all_languages.."]")
	table.insert(size, "label[0.5,0;" ..rule_table[language].s1_header.. "]")
	--table.insert(size, "label[0.5,3.25;" ..rule_table[language].s1_l2.. "]")
	--table.insert(size, "label[0.5,3.75;" ..rule_table[language].s1_l3.. "]")
	table.insert(size, "button_exit[0.0,3.4;2,0.5;leng;English]")
	table.insert(size, "button_exit[2,3.4;2,0.5;lrus;Russian]")
	table.insert(size, "button_exit[4,3.4;2,0.5;ldeu;Deutsch]")
	table.insert(size, "button_exit[6,3.4;2,0.5;lfra;Francais]")
	table.insert(size, "button_exit[8,3.4;2,0.5;lesp;Espanol]")
	--table.insert(size, "button[7.5,3.4;2,0.5;yes;" ..rule_table[language].s1_b2.. "]")
	return table.concat(size)
end

local function make_formspec2(player, language)
	if not language then language = interact.default_language end
	local size = { "size[10,8]" }
	table.insert(size, "textarea[0.5,0.5;9.5,7.5;TOS;" ..rule_table[language].s3_header.. ";" ..rule_table[language].rules.. "]")
	table.insert(size, "button[5.5,7.4;2,0.5;decline;" ..rule_table[language].s3_b2.. "]")
	table.insert(size, "button_exit[7.5,7.4;2,0.5;accept;" ..rule_table[language].s3_b1.. "]")
	return table.concat(size)
end

local server_formspec = "size[10,4]" ..
	"label[0.5,0.5;Hey, you! Yes, you, the admin! What do you think you're doing]" ..
	"label[0.5,0.9;ignoring warnings in the terminal? You should watch it carefully!]" ..
	"label[0.5,1.5;Before you do anything else, open rules.lua in the interact mod]" ..
	"label[0.5,1.9;and put your rules there. Then, open config.lua, and look at the]" ..
	"label[0.5,2.3;settings. Configure them so that they match up with your rules.]" ..
	"label[0.5,2.7;Then, set interact.configured to true, and this message will go away]" ..
	"label[0.5,3.1;once you've restarted the server.]" ..
	"label[0.5,3.6;Thank you!]"

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "interact_welcome" then return end
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if fields.leng then
		language = "english"
	elseif fields.lrus then
		language = "russian"
	elseif fields.ldeu then
		language = "german"
	elseif fields.lfra then
		language = "francais"
	elseif fields.lesp then
		language = "espanol"
	end
	rule_language[name] = language
	minetest.after(1, function()
		minetest.show_formspec(name, "interact_rules", make_formspec2(player, language))
	end)
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "interact_rules" then return end
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if fields.accept then
		if minetest.check_player_privs(name, interact.priv) then
			minetest.chat_send_player(name, rule_table[language].interact_msg1)
			minetest.chat_send_player(name, rule_table[language].interact_msg2)
			local privs = minetest.get_player_privs(name)
			privs.interact = true
			minetest.set_player_privs(name, privs)
			minetest.log("action", "Granted " ..name.. " interact.")
			minetest.chat_send_all(name.. " passed the rules test, welcome him/her in the land of kingdoms!")
			rule_language[name] = nil
		end
	return
	elseif fields.decline then
		if interact.disagree_action == "kick" then
			minetest.kick_player(name, rule_table[language].disagree_msg)
		elseif interact.disagree_action == "ban" then
			minetest.ban_player(name)
		else
			minetest.chat_send_player(name, rule_table[language].disagree_msg)
		end
	return
	end
end)

minetest.register_chatcommand("rules",{
	params = "<language>",
	description = "Shows the server rules",
	privs = interact.priv,
	func = function (name,params)
	local player = minetest.get_player_by_name(name)
	local language = rule_language[name] or interact.default_language
	if params ~= "" and rule_table[params:lower()] then
		language = params:lower()
		rule_language[name] = language
	elseif params ~= "" then
		minetest.chat_send_player(name, "There is no translation for '"..params:lower().."', Opening rules in '"..language.."'")
	end
		if interact.screen1 ~= false then
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_welcome", make_formspec(player, language))
			end)
		elseif interact.screen2 ~= false then
			minetest.after(1, function()
				minetest.show_formspec(name, "interact_rules", make_formspec2(player, language))
			end)
		end
	end
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local language = rule_language[name] or interact.default_language
	if not minetest.get_player_privs(name).interact then
		if interact.screen1 ~= false then
			minetest.show_formspec(name, "interact_welcome", make_formspec(player, language))
		elseif interact.screen2 ~= false then
			minetest.show_formspec(name, "interact_rules", make_formspec2(player, language))
		end
	elseif minetest.get_player_privs(name).server and interact.configured == false then
		minetest.show_formspec(name, "interact_no_changes_made", server_formspec)
	end
end)

if not interact.configured then
	minetest.log("warning", "Mod \"Interact\" has not been configured! Please open config.lua in its folder and configure it. See the readme of the mod for more details.")
end
