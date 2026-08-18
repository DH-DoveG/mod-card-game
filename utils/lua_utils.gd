extends Object
class_name LuaUtils

## 递归的将 LuaTable 转换为 Dictionary
static func table_to_dictionary(table: LuaTable, state: LuaState = null) -> Dictionary:
	if state == null:
		state = ModManager.state
	if table == null:
		return {}
	var dictionary: Dictionary = table.to_dictionary()
	for i in dictionary:
		if dictionary[i] is LuaTable:
			var cal = table_to_dictionary(dictionary[i], state)
			dictionary[i] = cal
	return dictionary


## 递归的将 Dictionary 转换为 LuaTable
static func dictionary_to_table(dictionary: Dictionary, state: LuaState = null) -> LuaTable:
	if state == null:
		state = ModManager.state
	if dictionary == null:
		return state.create_table({})
	var table = state.create_table({})
	for key in dictionary:
		var value = dictionary[key]
		if value is Callable:
			table.set(key, state.create_function(value))
		elif value is Dictionary:
			table.set(key, dictionary_to_table(value, state))
		elif value is Array:
			table.set(key, array_to_table(value, state))
		else:
			table.set(key, value)
	return table


## 递归的将 Array 转换为 LuaTable
static func array_to_table(array: Array, state: LuaState = null) -> LuaTable:
	if state == null:
		state = ModManager.state
	if array == null:
		return state.create_table({})
	var table = state.create_table({})
	for i in range(array.size()):
		var value = array[i]
		if value is Callable:
			table.set(i + 1, state.create_function(value)) # Lua 数组索引从 1 开始
		elif value is Dictionary:
			table.set(i + 1, dictionary_to_table(value, state))
		elif value is Array:
			table.set(i + 1, array_to_table(value, state))
		else:
			table.set(i + 1, value)
	return table
