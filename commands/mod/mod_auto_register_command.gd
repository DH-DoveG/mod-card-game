extends Command
class_name ModAutoRegisterCommand

var _execute_result: Variant = null

func _do_execute() -> void:
	var result = {}

	if typeof(_args) != TYPE_DICTIONARY:
		return
	if not _args.has("path") and typeof(_args["path"]) != TYPE_STRING:
		return
	var path: String = _args["path"]
	var load_table = ModManager.do_mod_file(path)
	if load_table is LuaError:
		assert(false, "load register Error: " + load_table.message)
		return

	var register_metadata = load_table.invoke()
	assert(register_metadata is LuaTable, "ModAutoRegisterCommand execute register_metadata not is LuaTable")

	if not register_metadata["auto_enabled"]:
		_execute_result = result
		return

	result["auto_cards"] = _auto_register_cards(register_metadata, _args["prefix"])
	result["auto_behaviors"] = _auto_register_behaviors(register_metadata, _args["prefix"])
	result["auto_images"] = _auto_register_images(register_metadata, _args["prefix"])

	_execute_result = result

func _do_undo() -> void:
	_undo_auto_register_cards(_execute_result)
	_undo_auto_register_behaviors(_execute_result)
	_undo_auto_register_images(_execute_result)

func _auto_register_cards(table: LuaTable, prefix: String) -> Dictionary:
	var auto_card_dir: String = table["auto_card_dir"]
	if auto_card_dir == "":
		return {}

	var full_dir = "/".join([prefix, auto_card_dir])
	var dir = DirAccess.open(full_dir)
	if not dir:
		return {}

	var result = {}
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".lua"):
			var key = file_name.trim_suffix(".lua")
			var value = "/".join([full_dir, file_name])
			GResourceManager.card_resource[key] = value
			result[key] = value
		file_name = dir.get_next()

	return result

func _auto_register_behaviors(table: LuaTable, prefix: String) -> Dictionary:
	var auto_behavior_dir: String = table["auto_behavior_dir"]
	if auto_behavior_dir == "":
		return {}

	var full_dir = "/".join([prefix, auto_behavior_dir])
	var dir = DirAccess.open(full_dir)
	if not dir:
		return {}

	var result = {}
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".lua"):
			var key = file_name.trim_suffix(".lua")
			var value = "/".join([full_dir, file_name])
			GResourceManager.behavior_resource[key] = value
			result[key] = value
		file_name = dir.get_next()

	return result

func _auto_register_images(table: LuaTable, prefix: String) -> Dictionary:
	var auto_image_config = table["auto_image_config"]
	if auto_image_config == null or typeof(auto_image_config) != TYPE_OBJECT:
		return {}

	var configs = LuaUtils.table_to_array(auto_image_config)
	var result = {}

	for config in configs:
		if config == null or typeof(config) != TYPE_OBJECT:
			continue
		var auto_image_dir: String = config["dir"]
		if auto_image_dir == "":
			continue
		var tags: PackedStringArray = config["tags"].to_array()
		var full_dir = "/".join([prefix, auto_image_dir])
		var dir = DirAccess.open(full_dir)
		if not dir:
			continue

		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var key = file_name.get_basename()
				var value = "/".join([full_dir, file_name])
				GResourceManager.load_image_resoure(key, value, tags)
				result[key] = value
			file_name = dir.get_next()

	return result

func _undo_auto_register_cards(table: Dictionary) -> void:
	var cards: Dictionary = table.get("auto_cards", {})
	for key in cards:
		GResourceManager.card_resource.erase(key)

func _undo_auto_register_behaviors(table: Dictionary) -> void:
	var behaviors: Dictionary = table.get("auto_behaviors", {})
	for key in behaviors:
		GResourceManager.behavior_resource.erase(key)

func _undo_auto_register_images(table: Dictionary) -> void:
	var images: Dictionary = table.get("auto_images", {})
	for key in images:
		GResourceManager.unload_image_resoure(key)