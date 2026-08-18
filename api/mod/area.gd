extends Object
class_name ModAreaApi


static func require(state: LuaState) -> void:
	var table = state.create_table()
	table.set("create", state.create_function(create))
	table.set("remove", state.create_function(remove))
	table.set("get_size", state.create_function(get_size))
	table.set("get_position", state.create_function(get_position))
	table.set("get_heap", state.create_function(get_heap))
	# table.set("set_heap", state.create_function(set_heap))
	table.set("set_owner", state.create_function(set_owner))
	table.set("set_color", state.create_function(set_color))
	table.set("get_height_level", state.create_function(get_height_level))
	table.set("set_height_level", state.create_function(set_height_level))
	table.set("find_condition", state.create_function(find_condition))
	table.set("get_all", state.create_function(get_all))
	# 实验API 2026-06-12
	#table.set("get_pos_paths", state.create_function(get_pos_paths))
	#table.set("get_pos_range", state.create_function(get_pos_range))
	#table.set("get_flood_paths", state.create_function(get_flood_paths))
	state.globals["package"]["loaded"]["std.api.area-api"] = table

#
#static func get_pos_paths(param: LuaTable) -> LuaTable:
	## 提取参数
	#var id = param["id"] if param["id"] != null else ""
	#var to_id = param["to_id"] if param["to_id"] != null else ""
	#var check_method = param["check_method"] if param["check_method"] != null else null
	#var mode = param["mode"] if param["mode"] != null else "CROSS" # CROSS or ADJOIN
	#if mode == "CROSS":
		#mode = Scene.AStarMode.CROSS
	#else:
		#mode = Scene.AStarMode.ADJOIN
#
	#var node = Utils.get_scene_tree()
	#if not node is Battle:
		#return ModManager.state.create_table({})
	#
	#var scene: Scene = node.scene
	#var astar = scene.build_astar(mode, func(area: Area):
		#if not check_method:
			#return true
		#return check_method.invoke(area.entity.meta)
	#)
#
	#var from_area = FindUtils.find_area(id)
	#var to_area = FindUtils.find_area(to_id)
#
	#var aid = scene._dec(Vector3(from_area.x, from_area.y, from_area.z))
	#var aid_to = scene._dec(Vector3(to_area.x, to_area.y, to_area.z))
#
	#var result = []
	#var paths = astar.get_id_path(aid, aid_to)
	#for path in paths:
		#var pos = scene._dec(path)
		#for area in scene.area_mount.get_children():
			#if area.x == pos.x and area.y == pos.y and area.z == pos.z:
				#result.append(area.name)
#
	#return ModManager.state.create_table(result)
#
#
#static func get_flood_paths(param: LuaTable) -> LuaTable:
	## 提取参数
	#var id = param["id"] if param["id"] != null else ""
	#var step = param["step"] if param["step"] != null else 1
	#var mode = param["mode"] if param["mode"] != null else "CROSS" # CROSS or ADJOIN
	#var check_method = param["check_method"] if param["check_method"] != null else null
#
	#if mode == "CROSS":
		#mode = Scene.AStarMode.CROSS
	#else:
		#mode = Scene.AStarMode.ADJOIN
#
	#var node = Utils.get_scene_tree()
	#if not node is Battle:
		#return ModManager.state.create_table({})
#
	#var scene: Scene = node.scene
	#var astar = scene.build_astar(mode, func(area: Area):
		#if not check_method:
			#return true
		#return check_method.invoke(area.entity.meta)
	#)
#
	#var from_area = FindUtils.find_area(id)
	#var aid = scene._dec(Vector3(from_area.x, from_area.y, from_area.z))
#
	#var ids = { aid: true }
	#for i in range(step):
		#for _id in ids:
			#var connections = astar.get_point_connections(_id)
			#for conn in connections:
				#ids[conn] = true
#
	#return LuaUtils.array_to_table(ids.keys())


static func get_all(param: LuaTable):
	var mode = param["mode"] if param["mode"] else "ID"
	# var all = Utils.get_scene_tree().get_nodes_in_group(&"area")
	var all = Utils.get_current_scene().areas.values()
	var result = []
	for area in all:
		if mode == "ID":
			result.append(area.name)
		elif mode == "ALL":
			result.append(area.meta)
	return LuaUtils.array_to_table(result)


static func get_height_level(param: LuaTable) -> int:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	# 执行业务逻辑
	var res = GApiManager.area_api.get_height_level(id)
	return res

static func set_height_level(param: LuaTable) -> void:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	var level = param["level"] if param["level"] != null else 3
	# 执行业务逻辑
	GApiManager.area_api.rpc("set_height_level", id, level)


static func get_position(param: LuaTable) -> LuaTable:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	# 执行业务逻辑
	var res = GApiManager.area_api.get_position(id)
	return ModManager.state.create_table(res)


static func create(param: LuaTable) -> void:
	# print("create")
	# 提取参数
	var name = param["data"]["entity"]["id"]
	var meta = param["data"]
	var x = param["x"] if param["x"] != null else 1 # 默认值 1
	var y = param["y"] if param["y"] != null else 1 # 默认值 1
	var z = param["z"] if param["z"] != null else 3
	# 校准参数（因为Lua下标从1开始，为符合Lua习惯，那边传入的是1）
	# 但是因为 GDS 下标是从 0 开始，所以这里需要校准
	x -= 1
	y -= 1
	# 执行业务逻辑
	GApiManager.area_api.rpc("create", x, y, z, name, LuaUtils.table_to_dictionary(meta))


static func get_size() -> LuaTable:
	return ModManager.state.create_table(GApiManager.area_api.get_size())


static func set_owner(param: LuaTable) -> void:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	var owners = param["owners"].to_array() if param["owners"] != null else []
	var mode = param["mode"] if param["mode"] != null else "APPEND"
	# 执行业务逻辑
	# print("set_owner=", id, " --- ", owners, " --- ", mode)
	GApiManager.area_api.rpc("set_area_owner", id, owners, mode)


static func set_color(param: LuaTable) -> void:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	var color = param["color"] if param["color"] != null else ""
	# 校准参数（因为按传入的是 RGB 或者 RRGGBB 格式，所以需要添加透明度）
	match color.length():
		4: # 匹配这种： #000
			color = color + "5" # 默认值 55
		7: # 匹配这种： #000000
			color += "55" # 默认值 55
	color = color.to_upper() # 转换为大写
	if color.length() != 5 and color.length() != 9:
		color = "#9995"
	# 执行业务逻辑
	GApiManager.area_api.rpc("set_color", id, color)


static func remove(param: LuaTable) -> LuaTable:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	# 执行业务逻辑
	var area_on_cards = GApiManager.area_api.remove(id)
	GApiManager.area_api.rpc("remove", id)
	# 转换返回值
	var table = LuaUtils.array_to_table(area_on_cards)
	return table


static func get_heap(param: LuaTable) -> LuaTable:
	# 提取参数
	var id = param["id"] if param["id"] != null else ""
	var start_index = param["start_index"] if param["start_index"] != null else 1
	var end_index = param["end_index"] if param["end_index"] != null else -1
	var mode = param["mode"] if param["mode"] != null else "ID"
	# 校准参数（因为Lua下标从1开始, 而外部从1开始（Lua）
	# 值得注意：因为 slice 不包含截止项，所以 end_index 不用 -1
	start_index -= 1
	# 执行业务逻辑
	var heap = GApiManager.area_api.get_heap(id, start_index, end_index)
	if mode == "ALL":
		var result = []
		for c in heap:
			var card = FindUtils.find_card(c)
			if card:
				# result.append(card.entity.meta)
				result.append(card.meta)
		return LuaUtils.array_to_table(result)
	var table = LuaUtils.array_to_table(heap)
	return table


# static func set_heap(param) -> LuaTable:
# 	# 提取参数
# 	var id = param["id"]
# 	var start_index = param["start_index"] if param["start_index"] != null else 1
# 	var end_index = param["end_index"] if param["end_index"] != null else null
# 	var ids = param["ids"] if param["ids"] != null else []
# 	var mode = param["mode"] if param["mode"] != null else "APPEND"
# 	# 校准参数（因为Lua下标从1开始, 而外部从1开始（Lua）
# 	# 值得注意：因为 slice 不包含截止项，所以 end_index 不用 -1
# 	start_index -= 1
# 	# 执行业务逻辑
# 	var heap = GApiManager.area_api.set_heap(id, start_index, end_index, ids, mode)
# 	# 转换返回值
# 	var table = LuaUtils.array_to_table(heap)
# 	return table


static func find_condition(param: LuaTable) -> LuaTable:
	# 提取参数
	var values = param["values"].to_array() if param["values"] != null else []
	var tags = param["tags"].to_array() if param["tags"] != null else []
	var areas = param["areas"].to_array() if param["areas"] != null else []
	var kinds = param["kinds"].to_array() if param["kinds"] != null else []
	var owners = param["owners"].to_array() if param["owners"] != null else []
	var positions = param["positions"].to_array() if param["positions"] != null else []
	var mode = param["mode"] if param["mode"] != null else "ID"
	# 校准参数
	var arg = {}
	if values.size(): arg["values"] = values
	if tags.size(): arg["tags"] = tags
	if areas.size(): arg["areas"] = areas
	if kinds.size(): arg["kinds"] = kinds
	if owners.size(): arg["owners"] = owners
	if positions.size(): arg["positions"] = positions
	# 执行业务逻辑
	var result = GApiManager.area_api.find_condition(arg, mode)
	# 转换返回值
	var table = LuaUtils.array_to_table(result)
	return table
