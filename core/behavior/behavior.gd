extends RefCounted
class_name Behavior

# Lua 数据（仅 BehaviorLua 子类有值），供 BehaviorTrigger.get_resolved_chain_triggers 等统一访问
var data = null

class BehaviorTrigger extends RefCounted:
	var id: String = ""
	var origin: String = ""
	var code: String = ""
	var trigger: Dictionary = {}
	var params: Dictionary = {}
	var behavior_ref: Behavior = null

	var result: Dictionary = {}
	var is_cancelled: bool = false
	var chain_index: int = -1

	func setup(p_origin: String, p_code: String, p_behavior: Behavior) -> void:
		id = IDUtils.generate("BT_")
		origin = p_origin
		code = p_code
		behavior_ref = p_behavior
		trigger = {}
		params = {}
		result = {}
		is_cancelled = false
		chain_index = -1

	# func set_trigger(p_trigger_type: String, p_trigger_data: Dictionary = {}) -> void:
	# 	trigger = {
	# 		"type": p_trigger_type,
	# 	}
	# 	for k in p_trigger_data:
	# 		trigger[k] = p_trigger_data[k]

	func clear_trigger() -> void:
		trigger = {}

	func get_state() -> Dictionary:
		var entity: Entity = FindUtils.find_entity(origin)
		if entity == null: return {}
		return entity.get_behavior_state(code)

	func set_state(key: String, value) -> void:
		var entity: Entity = FindUtils.find_entity(origin)
		if entity == null: return
		entity.set_behavior_state(code, key, value)

	# ═══════════════════════════════════════════
	# Chain-Triggers 实例级覆盖
	# ═══════════════════════════════════════════

	func set_chain_triggers_override(triggers: Array) -> void:
		set_state("__chain_triggers_override", triggers.duplicate())

	func add_chain_trigger(trigger_name: String) -> void:
		var state = get_state()
		var add_list = state.get("__chain_triggers_add", [])
		if add_list is Array:
			if trigger_name not in add_list:
				add_list.append(trigger_name)
		else:
			add_list = [trigger_name]
		set_state("__chain_triggers_add", add_list)

	func remove_chain_trigger(trigger_name: String) -> void:
		var state = get_state()
		var remove_list = state.get("__chain_triggers_remove", [])
		if remove_list is Array:
			if trigger_name not in remove_list:
				remove_list.append(trigger_name)
		else:
			remove_list = [trigger_name]
		set_state("__chain_triggers_remove", remove_list)

	func clear_chain_triggers_overrides() -> void:
		var state = get_state()
		state.erase("__chain_triggers_override")
		state.erase("__chain_triggers_add")
		state.erase("__chain_triggers_remove")

	func get_resolved_chain_triggers() -> Array:
		var state = get_state()

		# 1. override 完全覆盖
		if state.has("__chain_triggers_override"):
			var override_val = state["__chain_triggers_override"]
			if override_val is Array:
				return override_val.duplicate()
			return override_val

		# 2. 从 Behavior 模板获取默认 chain_triggers
		var triggers: Array = []
		if behavior_ref != null and behavior_ref.data != null:
			var lua_data = behavior_ref.data
			if lua_data is LuaTable:
				var ct = lua_data.get("chain_triggers")
				if ct != null:
					triggers = LuaUtils.table_to_array(ct)

		# 3. 应用 add
		if state.has("__chain_triggers_add"):
			var add_list = state["__chain_triggers_add"]
			for t in add_list:
				if triggers.find(t) < 0:
					triggers.append(t)

		# 4. 应用 remove
		if state.has("__chain_triggers_remove"):
			var remove_list = state["__chain_triggers_remove"]
			for t in remove_list:
				var idx = triggers.find(t)
				if idx >= 0:
					triggers.remove_at(idx)

		return triggers

	func to_dict():
		var d = {
			"id": id,
			"origin": origin,
			"code": code,
			"trigger": trigger.duplicate(true),
			"params": params.duplicate(true),
			"is_cancelled": is_cancelled,
			"chain_index": chain_index,
		}
		return d

#var data
var template = ""

func get_info() -> Dictionary:
	return {
		"name": "",
		"type": "",
		"description": "",
		"code": ""
	}

# 初始化数据
func init_data(init):
	data = init

# 支付行为代价
func cost(_bt: BehaviorTrigger, _arg): pass

# 发动行为
func launch(_bt: BehaviorTrigger, _arg) -> void: pass

# 执行行为
func execute(_bt: BehaviorTrigger, _arg): pass

# 检查是否可支付代价
func check_cost(_bt: BehaviorTrigger, _arg) -> bool:
	await Utils.get_scene_tree().process_frame
	return true

# 检查是否可发动行为
func check_launch(_bt: BehaviorTrigger, _args) -> bool:
	await Utils.get_scene_tree().process_frame
	return true

# 事件的回调
func hook_callback(_bt: BehaviorTrigger, _name: String, _arg: Variant) -> Variant: return null
