extends Node
class_name CoreAreaApi

func get_position(id: String) -> Dictionary:
	var area = FindUtils.find_area(id)
	if not area or area is not AreaEntity: return {"x": 1, "y": 1}
	return {"x": area.x, "y": area.y}

func get_size() -> Dictionary:
	var scene: Battle = Utils.get_current_scene()
	return {"x": scene.scene.max_x, "y": scene.scene.max_y}

func get_height_level(id: String) -> int:
	var area = FindUtils.find_area(id)
	if not area or area is not AreaEntity: return 0
	return area.get_height_level()

@rpc("any_peer", "call_local", "reliable")
func set_height_level(id: String, level: int) -> void:
	var area = FindUtils.find_area(id)
	if not area or area is not AreaEntity: return
	area.set_height_level(level)

# 静态方法也可以 rpc 调用，只要 CoreAreaApi 对应的调用实例在场景树里就行
# 不过我们需要却仍调用的是在场景树里的，所以最好还是用实例方法
@rpc("any_peer", "call_local", "reliable")
func create(x: int, y: int, z: int, _name: String, meta = null) -> AreaEntity:
	# print("CREATE AREA : ", GNetManager.uid)
	# print("CREATE AREA : x:", x, "y:", y)
	assert(Utils.is_battle_scene(), "create area in non-battle scene")
	var battle: Battle = Utils.get_current_scene()
	# var area = load("res://entity/area/battlefield_area.tscn").instantiate()
	var area = AreaEntity.new()
	area.name = _name
	area.x = x
	area.y = y
	area.z = z
	battle.areas[_name] = area
	var area_view := battle.scene.add_area(x, y, z)
	area_view.set_entity(area)
	if meta: area.meta = LuaUtils.dictionary_to_table(meta)
	# 在绑定表中初始化
	battle.battle_data_bind_list.area_bind_cards[_name] = PackedStringArray()
	battle.battle_data_bind_list.area_bind_players[_name] = PackedStringArray()
	return area

# 这里需要得到返回值，所以 call_remote 调用远程的删掉
# 本地再直接调用一次即可
@rpc("any_peer", "call_remote", "reliable")
func remove(id: String) -> Array:
	assert(Utils.is_battle_scene(), "remove area in non-battle scene")
	var area = FindUtils.find_area(id)
	if not area: return []
	# 从绑定表中移除
	var battle: Battle = Utils.get_current_scene()
	# 1. 将 heap 相应的卡片获取作为返回值返回（并且将 heap 中的 id 移除）
	#var heap: Dictionary = battle.battle_data_bind_list["heap"]
	var heap: Dictionary = battle.battle_data_bind_list.area_bind_cards
	var area_on_cards: Array = heap.get(id, [])
	heap.erase(id)
	# 2. 将区域从 area 中移除（移出注册）
	#var areas: Dictionary = battle.battle_data_bind_list["area"]
	var areas: Dictionary = battle.battle_data_bind_list.area_bind_players
	areas.erase(id)
	# 3. 释放区域节点
	area.queue_free()
	# 4. 返回卡片数组
	return area_on_cards

@rpc("any_peer", "call_local", "reliable")
func set_area_owner(id: String, owners: Array, mode: String) -> void:
	if not Utils.is_battle_scene(): return
	var battle: Battle = Utils.get_current_scene()
	# 获取绑定表
	#var areas = battle.battle_data_bind_list.area_bind_players
	#var areas = battle.battle_data_bind_list["area"]
	if battle.battle_data_bind_list.area_bind_players.get(id) == null:
		battle.battle_data_bind_list.area_bind_players[id] = PackedStringArray()
	var area_owners = battle.battle_data_bind_list.area_bind_players[id]
	# 设置模式
	match mode:
		"APPEND":
			for _owner in owners:
				if _owner not in area_owners:
					area_owners.append(_owner)
		"REPLACE":
			area_owners = PackedStringArray(owners)
		"REMOVE":
			for _owner in owners:
				area_owners.erase(_owner)

@rpc("any_peer", "call_local", "reliable")
func set_color(id: String, color: Variant) -> void:
	var area = FindUtils.find_area(id)
	if not area: return
	color = Color(color)
	#area.set_color(color)

# @rpc("any_peer", "call_local", "reliable")
func get_heap(id: String, start_index: int = 0, end_index: int = -1) -> Array:
	if not Utils.is_battle_scene(): assert(false, "get_heap in non-battle scene")
	var battle: Battle = Utils.get_current_scene()
	# 获取绑定表
	#var heap: Dictionary = battle.battle_data_bind_list["heap"]
	var heap: Dictionary = battle.battle_data_bind_list.area_bind_cards
	# 获取区域的卡片数组
	if not heap.has(id):
		heap[id] = []
	var area_on_cards: Array = heap.get(id, [])
	# 校验参数
	if end_index == -1:
		end_index = area_on_cards.size()
	else:
		end_index = clampi(end_index, 0, area_on_cards.size())
	start_index = clampi(start_index, 0, area_on_cards.size())
	if start_index >= end_index:
		var swap = start_index
		start_index = end_index
		end_index = swap
	# 业务
	if area_on_cards.is_empty(): return area_on_cards
	var heap_on_cards: Array = area_on_cards.slice(start_index, end_index)
	return heap_on_cards

# @rpc("any_peer", "call_local", "reliable")
# func set_heap(id: String, start_index: int = 0, end_index: int = -1, ids: Array = [], mode: String = "APPEND") -> Array:
# 	if not Utils.is_battle_scene(): assert(false, "set_heap in non-battle scene")
# 	var battle: Battle = Utils.get_current_scene()
# 	# 获取绑定表
# 	#var heap: Dictionary = battle.battle_data_bind_list["heap"]
# 	var heap: Dictionary = battle.battle_data_bind_list.area_bind_cards
# 	# 获取区域的卡片数组
# 	if not heap.has(id):
# 		heap[id] = []
# 	var area_on_cards: Array = heap.get(id, null)
# 	assert(area_on_cards != null, "set_heap id not found")
# 	# 校验参数
# 	if end_index == -1:
# 		end_index = area_on_cards.size()
# 	else:
# 		end_index = clampi(end_index, 0, area_on_cards.size())
# 	start_index = clampi(start_index, 0, area_on_cards.size())
# 	if start_index >= end_index:
# 		var swap = start_index
# 		start_index = end_index
# 		end_index = swap
# 	# 业务
# 	if area_on_cards.is_empty():
# 		heap[id] = ids
# 		return []
# 	match mode:
# 		"INSERT":
# 			for cid in ids:
# 				if cid not in area_on_cards:
# 					area_on_cards.insert(start_index, cid)
# 			# 没有对返回值的特殊处理
# 		"REPLACE":
# 			# 替换 start_index 与 end_index 之间的卡，需要返回被替换的卡片
# 			var heap_on_cards: Array = []
# 			for i in range(start_index, end_index):
# 				heap_on_cards.append(area_on_cards[i])
# 				area_on_cards[i] = ids[i - start_index]
# 			return heap_on_cards # 返回被替换的值
# 		"SWAP":
# 			var heap_on_cards: Array = area_on_cards
# 			heap[id] = ids
# 			return heap_on_cards # 返回被交换的值
# 		"APPEND":
# 			for cid in ids:
# 				if cid not in area_on_cards:
# 					area_on_cards.append(cid)
# 			# 没有对返回值的特殊处理
# 	return area_on_cards

# @rpc("any_peer", "call_local", "reliable")
func find_condition(arg: Dictionary, mode: String = "ID") -> Array:
	var areas = FindUtils.find_condition_areas(arg)
	
	var result = []
	for area in areas:
		if mode == "ID":
			result.append(str(area.name))
		elif mode == "ALL":
			result.append(area.meta)
	
	return result
