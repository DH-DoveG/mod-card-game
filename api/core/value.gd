extends Node
class_name CoreValueApi

func create(code: String, nick: String, _value: float, _max_value: float = 1024, _min_value: float = -1024, config = null) -> Value:
	var valueObj = Value.new()
	valueObj.code = code
	valueObj.value = _value
	valueObj.nick = nick
	valueObj.max_value = _max_value
	valueObj.min_value = _min_value
	valueObj.config = config
	return valueObj

func get_values_dict(entity_id: String):
	var result = {}

	var entity: Entity = null
	if entity_id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(entity_id)
	elif entity_id.begins_with("CARD_"):
		entity = FindUtils.find_card(entity_id)
	elif entity_id.begins_with("AREA_"):
		entity = FindUtils.find_area(entity_id)
	else:
		return

	for k in entity.values.keys():
		result[k] = entity.values[k].value
	return result

@rpc("any_peer", "call_local", "reliable")
func append(entity_id: String, v: Dictionary) -> void:
	var entity: Entity = null
	if entity_id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(entity_id)
	elif entity_id.begins_with("CARD_"):
		entity = FindUtils.find_card(entity_id)
	elif entity_id.begins_with("AREA_"):
		entity = FindUtils.find_area(entity_id)
	else:
		return

	var template = ModManager.do_mod_file(GResourceManager.value_resource[v["template"]])
	var override = v["override"]

	assert(template, "Value Template: is null.")
	if template is LuaError:
		assert(false, template.message)
	assert(template is LuaFunction, "Value Template: is function")
	template = template.invoke()
	if template is LuaError:
		assert(false, template.message)

	var value: Dictionary = LuaUtils.table_to_dictionary(template)

	for k in override:
		value[k] = override[k]

	#先从注册数据中获取 value 的模板
	var __code = value["code"] if value.has("code") else null
	var __name = value["name"] if value.has("name") else __code
	var __max = value["max"] if value.has("max") else 256
	var __min = value["min"] if value.has("min") else -256
	var __value = value["value"] if value.has("value") else 0
	var __config = value["config"] if value.has("config") else null
	assert(__code, "Value code is null")
	var vobj = create(
		__code,
		__name,
		__value,
		__max,
		__min,
		__config
	)

	entity.values[__code] = vobj

	_update_value_show()

@rpc("any_peer", "call_local", "reliable")
func remove(entity_id: String, code: String) -> void:
	var entity: Entity = null
	if entity_id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(entity_id)
	elif entity_id.begins_with("CARD_"):
		entity = FindUtils.find_card(entity_id)
	elif entity_id.begins_with("AREA_"):
		entity = FindUtils.find_area(entity_id)
	else:
		return
	if code in entity.values:
		entity.values.erase(code)

	_update_value_show()

@rpc("any_peer", "call_local", "reliable")
func increase(entity_id: String, code: String, value: Variant) -> void:
	var entity: Entity = null
	var type = ""
	if entity_id.begins_with("PLAYER_"):
		type = "PLAYER"
		entity = FindUtils.find_player(entity_id)
	elif entity_id.begins_with("CARD_"):
		type = "CARD"
		entity = FindUtils.find_card(entity_id)
	elif entity_id.begins_with("AREA_"):
		type = "AREA"
		entity = FindUtils.find_area(entity_id)
	else:
		return

	if code in entity.values:
		entity.values[code].value += value
		entity.values[code].value = clamp(entity.values[code].value, entity.values[code].min_value, entity.values[code].max_value)
	if type == "PLAYER":
		Utils.get_current_scene().get_node("UI/PlayerPanel").update()

	_update_value_show()

@rpc("any_peer", "call_local", "reliable")
func reset(entity_id: String, code: String, value: Variant) -> void:
	var update = ""
	var entity: Entity = null
	if entity_id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(entity_id)
		update = "PLAYER"
	elif entity_id.begins_with("CARD_"):
		entity = FindUtils.find_card(entity_id)
		update = "CARD"
	elif entity_id.begins_with("AREA_"):
		entity = FindUtils.find_area(entity_id)
	else:
		return
	if code in entity.values:
		entity.values[code].value = value
		entity.values[code].value = clamp(entity.values[code].value, entity.values[code].min_value, entity.values[code].max_value)
	if update == "PLAYER":

		Utils.get_current_scene().get_node("UI/PlayerPanel").update()
	elif update == "CARD":
		# FIXME

		pass
	_update_value_show()

@rpc("any_peer", "call_local", "reliable")
func remove_modifier(modifier_id: String) -> void:
	var modifiers = get_tree().get_nodes_in_group(&"modifier")
	for modifier in modifiers:

		if modifier.name == modifier_id:
			modifier.queue_free()
			break
	_update_value_show()

@rpc("any_peer", "call_local", "reliable")
func append_modifier(entity_id: String, modifier: Dictionary) -> void:
	var entity: Entity = null
	if entity_id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(entity_id)
	elif entity_id.begins_with("CARD_"):
		entity = FindUtils.find_card(entity_id)
	elif entity_id.begins_with("AREA_"):
		entity = FindUtils.find_area(entity_id)
	else:
		return
	var m = Modifier.new()
	m.name = modifier["id"]
	m.id = modifier["id"]
	m.code = modifier["code"]
	m.value = modifier["value"]
	m.op = modifier["op"]
	m.custom = modifier["custom"]
	if m.code in entity.values:
		var v: Value = entity.values[m.code]
		v.modifiers.append(m)
	_update_value_show()

func get_modifier(entity_id: String, code: String) -> Array:
	var entity: Entity = null
	if entity_id.begins_with("PLAYER_"):
		entity = FindUtils.find_player(entity_id)
	elif entity_id.begins_with("CARD_"):
		entity = FindUtils.find_card(entity_id)
	elif entity_id.begins_with("AREA_"):
		entity = FindUtils.find_area(entity_id)
	else:
		return []
	if code in entity.values:
		return entity.values[code].get_modifiers()
	return []

func _update_value_show() -> void:
	# TODO

	Utils.get_current_scene().get_node("UI/PlayerPanel").update()
