extends Command
class_name ModRegisterCommand

## 注册命令
## 注册mod的资源

var _execute_result: Variant = null


func execute() -> void:
	# 样板代码
	if is_execute():
		return
	var result = {}

	# 检查参数
	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("path") and typeof(_args["path"]) != TYPE_STRING:
		return
	var path: String = _args["path"]
	var load_table = ModManager.do_mod_file(path)
	if load_table is LuaError:
		assert(false, "load register Error: " + load_table.message)
		return
	# 业务逻辑
	var register_metadata = load_table.invoke()
	
	assert(register_metadata is LuaTable, "ModRegisterCommand execute register_metadata not is LuaTable")

	result["cards"] = _execute_register_cards(register_metadata, _args["prefix"])
	result["values"] = _execute_register_values(register_metadata, _args["prefix"])
	result["images"] = _execute_register_images(register_metadata, _args["prefix"])
	result["musics"] = _execute_register_musics(register_metadata, _args["prefix"])
	result["sounds"] = _execute_register_sounds(register_metadata, _args["prefix"])
	result["decks"] = _execute_register_decks(register_metadata, _args["prefix"])
	result["players"] = _execute_register_players(register_metadata, _args["prefix"])
	result["packs"] = _execute_register_packs(register_metadata, _args["prefix"])
	result["start_rules"] = _execute_register_start_rules(register_metadata, _args["prefix"])
	result["player_entitys"] = _execute_register_player_entitys(register_metadata, _args["prefix"])
	result["behaviors"] = _execute_register_behaviors(register_metadata, _args["prefix"])
	result["deck_check_tools"] = _execute_register_deck_check_tools(register_metadata, _args["prefix"])
	result["agents"] = _execute_register_agents(register_metadata, _args["prefix"])

	_execute_result = result

	# 样板代码
	_execute_state = true


func undo() -> void:
	# 样板代码
	if not is_execute():
		return
	# 业务逻辑
	_undo_register_cards(_execute_result)
	_undo_register_images(_execute_result)
	_undo_register_musics(_execute_result)
	_undo_register_sounds(_execute_result)
	_undo_register_decks(_execute_result)
	_undo_register_players(_execute_result)
	_undo_register_packs(_execute_result)
	# 样板代码
	_execute_state = false


func _execute_register_agents(table: LuaTable, prefix: String) -> Dictionary:
	var agents = table["agents"].to_dictionary()
	for key in agents:
		var agent = "/".join([prefix, agents[key]])
		GResourceManager.agent_resource[key] = agent
	return agents


func _execute_register_deck_check_tools(table: LuaTable, prefix: String) -> Dictionary:
	var deck_check_tools = table["deck_check_tools"].to_dictionary()
	for key in deck_check_tools:
		var deck_check_tool = "/".join([prefix, deck_check_tools[key]])
		GResourceManager.deck_check_tool_resource[key] = deck_check_tool
	return deck_check_tools


func _execute_register_behaviors(table: LuaTable, prefix: String) -> Dictionary:
	var behaviors = table["behaviors"].to_dictionary()
	for key in behaviors:
		var behavior = "/".join([prefix, behaviors[key]])
		GResourceManager.behavior_resource[key] = behavior
	return {}


func _execute_register_values(table: LuaTable, prefix: String) -> Dictionary:
	var values = table["values"].to_dictionary()
	for key in values:
		var value = "/".join([prefix, values[key]])
		GResourceManager.value_resource[key] = value
	return {}


func _execute_register_cards(table: LuaTable, prefix: String) -> Dictionary:
	var cards = table["cards"].to_dictionary()
	for key in cards:
		var card = "/".join([prefix, cards[key]])
		GResourceManager.card_resource[key] = card
	return {}

func _execute_register_images(table: LuaTable, prefix: String) -> Dictionary:
	var images = table["images"].to_dictionary()
	var result = {}
	for key in images:
		var image: LuaTable = images[key]
		var path = "/".join([prefix, image.path])
		var tags = image.tags.to_array()
		GResourceManager.load_image_resoure(key, path, tags)
		result[key] = path
	return result

func _execute_register_musics(table: LuaTable, prefix: String) -> Dictionary:
	var musics = table["musics"].to_dictionary()
	var result = {}
	for key in musics:
		var music: LuaTable = musics[key]
		var path = "/".join([prefix, music.path])
		var tags = music.tags.to_array()
		GResourceManager.load_music_resoure(key, path, tags)
		result[key] = path
	return result

func _execute_register_sounds(table: LuaTable, prefix: String) -> Dictionary:
	var sounds = table["sounds"].to_dictionary()
	var result = {}
	for key in sounds:
		var sound: LuaTable = sounds[key]
		var path = "/".join([prefix, sound.path])
		var tags = sound.tags.to_array()
		GResourceManager.load_sound_resoure(key, path, tags)
		result[key] = path
	return result

func _execute_register_decks(table: LuaTable, prefix: String) -> Dictionary:
	var decks = table["decks"].to_dictionary()
	for key in decks:
		var deck = "/".join([prefix, decks[key]])
		GResourceManager.deck_resource[key] = deck
	return {}

func _execute_register_players(table: LuaTable, prefix: String) -> Dictionary:
	var players = table["players"].to_dictionary()
	for key in players:
		var player = players[key].to_dictionary()
		player.path = "/".join([prefix, player.path])
		GResourceManager.player_resource[key] = player
	return {}

func _execute_register_packs(table: LuaTable, prefix: String) -> Dictionary:
	var packs = table["packs"].to_dictionary()
	for key in packs:
		var pack = "/".join([prefix, packs[key]])
		GResourceManager.package_resource[key] = pack
	return {}


func _execute_register_start_rules(table: LuaTable, _prefix: String) -> Dictionary:
	var start_rules = table["start_rules"].to_array()
	GResourceManager.start_rule_resource.append_array(start_rules)
	return {}

func _execute_register_player_entitys(table: LuaTable, prefix: String) -> Dictionary:
	var player_entitys = table["player_entitys"].to_dictionary()
	for key in player_entitys:
		var player_entity = "/".join([prefix, player_entitys[key]])
		GResourceManager.player_entitys_resource[key] = player_entity
	return {}


func _undo_register_cards(table: LuaTable) -> Dictionary:
	var cards = table["cards"]
	for key in cards:
		GResourceManager.card_resource.erase(key)
	return {}

func _undo_register_images(table: LuaTable) -> Dictionary:
	var images = table["images"]
	for key in images:
		GResourceManager.unload_image_resoure(key)
	return {}

func _undo_register_musics(table: LuaTable) -> Dictionary:
	var musics = table["musics"]
	for key in musics:
		GResourceManager.unload_music_resoure(key)
	return {}

func _undo_register_sounds(table: LuaTable) -> Dictionary:
	var sounds = table["sounds"]
	for key in sounds:
		GResourceManager.unload_sound_resoure(key)
	return {}

func _undo_register_decks(table: LuaTable) -> Dictionary:
	var decks = table["decks"]
	for key in decks:
		GResourceManager.deck_resource.erase(key)
	return {}

func _undo_register_players(table: LuaTable) -> Dictionary:
	var players = table["players"]
	for key in players:
		GResourceManager.player_resource.erase(key)
	return {}

func _undo_register_packs(table: LuaTable) -> Dictionary:
	var packs = table["packs"]
	for key in packs:
		GResourceManager.package_resource.erase(key)
	return {}
