extends Behavior
class_name BehaviorLua
#
#func _ready() -> void:
	#super()

func init_data(init):
	data = init
	#name = data["id"]

func get_info() -> Dictionary:
	if data is not LuaTable:
		return super()
	var table: LuaTable = data as LuaTable
	return {
		"name": table.get("name", ""),
		"type": table.get("type", ""),
		"description": table.get("description", "")
	}

# 支付行为代价
func cost():
	var cost_value = data.get("cost")
	if cost_value is not LuaFunction:
		return
	var cost_func: LuaFunction = cost_value
	cost_func.invoke(data)

# 发动行为
func launch(arg) -> void:
	var _table = LuaUtils.dictionary_to_table(arg)
	await ModManager.run_lua_function(data.get("launch"), _table, data)

# 执行行为
func execute(arg):
	var execute_value = data.get("execute")
	if execute_value is not LuaFunction:
		return
	var execute_func: LuaFunction = execute_value
	execute_func.invoke(data, arg)

# 检查是否可支付代价
func check_cost() -> bool:
	if await super() == false:
		return false
	var _table = ModManager.state.create_table({})
	# print("check_cost")
	return await ModManager.run_lua_function(data.get("check_cost"), _table, data)

# 检查是否可发动行为
func check_launch(args = {}) -> bool: 
	var _table = args
	if _table is not LuaTable:
		_table = ModManager.state.create_table(args)
	# print("check_launch")
	return await ModManager.run_lua_function(data.get("check_launch"), _table, data)

func hook_callback(arg: Variant) -> Variant:
	var callback_value = data.get("hook_callback")
	if callback_value is not LuaFunction:
		return null
	var callback_func: LuaFunction = callback_value
	return callback_func.invoke(data, arg)
