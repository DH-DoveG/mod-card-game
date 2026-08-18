extends Node
class_name CoreValueApi


func create(code: String, nick: String, _value: float, _max_value: float = 1024, _min_value: float = -1024, config = null) -> Value:
	var valueObj = Value.new()
	#valueObj.name = code
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

	for k in entity.value_manager.keys():
		result[k] = entity.value_manager[k].value
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
	#entity.value_mount.add_child(vobj)
	entity.value_manager[__code] = vobj
	 #if update == "PLAYER":
	 	#var p = FindUtils.find_player(entity_id)
	 	#for node: PlayerAvatar in Utils.get_current_scene().get_node("UI/PlayerPanel").get_children():
	 		#if node.use_player == p:
	 			#node.update()
	 #elif update == "CARD":
	 	#var c = FindUtils.find_card(entity_id)
	 	#c.card_info_show.update_value()
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
	if code in entity.value_manager:
		entity.value_manager.erase(code)
	# if update == "PLAYER":
	# 	var p = FindUtils.find_player(entity_id)
	# 	for node: PlayerAvatar in Utils.get_current_scene().get_node("UI/PlayerPanel").get_children():
	# 		if node.use_player == p:
	# 			node.update()
	# elif update == "CARD":
	# 	FindUtils.find_card(entity_id).card_info_show.update_value()
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
	
	if code in entity.value_manager:
		entity.value_manager[code].value += value
		entity.value_manager[code].value = clamp(entity.value_manager[code].value, entity.value_manager[code].min_value, entity.value_manager[code].max_value)
	if type == "PLAYER":
		Utils.get_current_scene().get_node("UI/PlayerPanel").update()
		#var p = FindUtils.find_player(entity_id)
		#var nodes = Utils.get_current_scene().get_node("UI/PlayerPanel").get_children()
		#for node: PlayerAvatar in nodes:
			#if node.use_player == p:
				#node.update()
				#break
	# elif update == "CARD":
	# 	FindUtils.find_card(entity_id).card_info_show.update_value()
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
	if code in entity.value_manager:
		entity.value_manager[code].value = value
		entity.value_manager[code].value = clamp(entity.value_manager[code].value, entity.value_manager[code].min_value, entity.value_manager[code].max_value)
	if update == "PLAYER":
		#var p = FindUtils.find_player(entity_id)
		#Utils.get_current_scene().get_node("UI/PlayerPanel").update(p)
		Utils.get_current_scene().get_node("UI/PlayerPanel").update()
	elif update == "CARD":
		# FIXME
		#FindUtils.find_card(entity_id).card_info_show.update_value()
		pass
	_update_value_show()


@rpc("any_peer", "call_local", "reliable")
func remove_modifier(modifier_id: String) -> void:
	var modifiers = get_tree().get_nodes_in_group(&"modifier")
	for modifier in modifiers:
		# print("Modifier: ", modifier)
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
	if m.code in entity.value_manager:
		var v: Value = entity.value_manager[m.code]
		#v.add_child(m)
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
	if code in entity.value_manager:
		return entity.value_manager[code].get_modifiers()
	return []


func _update_value_show() -> void:
	# TODO
	#for p in get_tree().get_nodes_in_group(&"player"):
		#Utils.get_current_scene().get_node("UI/PlayerPanel").update(p)
	#for c in get_tree().get_nodes_in_group(&"card"):
		#c.card_info_show.update_value()
	Utils.get_current_scene().get_node("UI/PlayerPanel").update()
