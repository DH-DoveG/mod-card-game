extends Object
class_name ModResourceApi


static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("play_sound", state.create_function(play_sound))
	table.set("play_music", state.create_function(play_music))
	table.set("pause_music", state.create_function(pause_music))
	table.set("resume_music", state.create_function(resume_music))
	table.set("set_page_music", state.create_function(set_page_music))
	table.set("change_entity_image", state.create_function(change_entity_image))
	table.set("change_player_card_back", state.create_function(change_player_card_back))
	table.set("set_index_title", state.create_function(set_index_title))
	table.set("set_page_background", state.create_function(set_page_background))
	state.globals["package"]["loaded"]["std.api.resource-api"] = table


static func play_sound(param: LuaTable) -> void:
	var id = param["id"] if param["id"] else ""
	GApiManager.resource_api.rpc("play_sound", id)


static func play_music(param: LuaTable) -> void:
	var id = param["id"] if param["id"] else ""
	GApiManager.resource_api.rpc("play_music", id)


static func pause_music(_param) -> void:
	pass


static func resume_music(_param) -> void:
	pass


static func set_page_music(_param) -> void:
	pass


static func change_entity_image(_param) -> void:
	pass


static func change_player_card_back(_param) -> void:
	pass


static func set_index_title(param: LuaTable) -> String:
	var old = ConfigManager.page_index_title
	ConfigManager.page_index_title = param.title
	return old


static func set_page_background(param: LuaTable) -> String:
	var old = ConfigManager.page_config.get(param.page, "")
	ConfigManager.page_config[param.page] = param.resource_id
	return old
