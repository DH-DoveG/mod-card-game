extends Behavior
class_name BehaviorLua

func _run_function(fun: String, arg):
	return await ModManager.run_lua_function(data[fun], arg, "ARRAY")

func init_data(init):
	data = init

func get_info() -> Dictionary:
	if data is not LuaTable:
		return super()
	var table: LuaTable = data as LuaTable
	return {
		"name": table.get("name", ""),
		"type": table.get("type", ""),
		"description": table.get("description", ""),
		"code": table.get("code", "")
	}

# 支付行为代价
func cost(bt: BehaviorTrigger, arg):
	var _table = LuaUtils.array_to_table([data, bt.to_dict(), arg])
	await _run_function("cost", _table)

# 发动行为
func launch(bt: BehaviorTrigger, arg) -> void:
	var _table = LuaUtils.array_to_table([data, bt.to_dict(), arg])
	await _run_function("launch", _table)

# 执行行为
func execute(bt: BehaviorTrigger, arg):
	var _table = LuaUtils.array_to_table([data, bt.to_dict(), arg])
	await _run_function("execute", _table)

# 检查是否可支付代价
func check_cost(bt: BehaviorTrigger, arg) -> bool:
	var _table = LuaUtils.array_to_table([data, bt.to_dict(), arg])
	return await _run_function("check_cost", _table)

# 检查是否可发动行为
func check_launch(bt: BehaviorTrigger, arg) -> bool:
	var _table = LuaUtils.array_to_table([data, bt.to_dict(), arg])
	return await _run_function("check_launch", _table)

func hook_callback(bt: BehaviorTrigger, name: String, arg: Variant) -> Variant:
	var _table = LuaUtils.array_to_table([data, bt.to_dict(), name, arg])
	return await _run_function("hook_callback", _table)
