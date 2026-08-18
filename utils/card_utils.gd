extends Object
class_name CardUtils



## [param] id: 卡片ID
## [param] meta: 卡片元数据
static func create(id: String, card_meta = null, _parent = null) -> CardEntity:
	var card: CardEntity = CardEntity.new()
	card.name = id
	#if parent is Node:
		#parent.add_child(card)
	#else:
		#var current_scene = Utils.get_current_scene()
		#current_scene.add_child(card)
	# card.entity.meta = card_meta
	card.set_entity(card_meta)
	return card

#
#static func card_build(card_id: StringName, _build_location: Area, ownership: Player) -> Card:
	#var card = load("res://core/card/card.tscn").instantiate()
#
	## 构建卡片后需要先就行一次初始化
	## 可能需要提供使用对象与使用名字的API
	#card.name = card_id
#
	#var tree = Engine.get_main_loop().current_scene
	#tree.add_child(card)
#
	##build_location.add_card_node(card)
#
	## 设置卡片持有者
	#card.ownership = ownership.name
#
	##card.global_position.x = build_location.global_position.x
	##card.global_position.z = build_location.global_position.z
#
	##build_location.update()
#
	#return card


## FIXME: 删除卡片
## @param card_id 卡片id
## @return 是否删除成功
# static func card_delete(card_id: StringName) -> bool:
# 	var card: Card = Utils.find_card(card_id)
# 	var location = Utils.find_area(card.location)
# 	if card == null:
# 		return false

# 	location.remove_card(card.name)
# 	card.queue_free()
# 	return true


## FIXME: 为卡片添加选中效果
## @param card_id 卡片id
## @return 选中效果节点
# static func card_hight(card_id: StringName) -> Node:
# 	var obj= load("res://components/cards/card_module_selected.tscn").instantiate()
# 	var card: Card = Utils.find_card(card_id)
# 	if card != null:
# 		card.add_child(obj)
# 	return obj


# FIXME: 为卡片添加属性
# static func card_translate_attribute(card_id: StringName, attribute) -> bool:
# 	var card: Card = Utils.find_card(card_id)
# 	if !card: return false

# 	#var module: StateEntry = card.get_state_manager().get_state("Attribute")
# 	var module = card.unit_node.get_attr_by_id("Attribute")

# 	if is_instance_valid(module) == false:
# 		return false
# 	module.add_state(attribute)
# 	return true

#
#static func card_translate_position(card: Card, destination_location: Area) -> bool:
	#card.global_position = destination_location.global_position
	#destination_location.add_card_node(card)
	#return true


## 为卡片添加旋转角度，可以开启动画
## @param card 卡片
## @param rotation 旋转角度
## @param animate 是否开启动画
## @return 返回是否添加成功
#static func card_translate_rotation(card: Card, rotation: Vector3, animate: bool = false) -> bool:
	#if animate:
		## 开启动画
		## card.rotation_degrees = rotation
		#pass
	#else:
		#card.rotation_degrees = rotation
	#return true
#
#
## FIXME: 为卡片添加图片
#static func translate_image(card: Card, front_image: Image, back_image: Image = null) -> bool:
	#if not is_instance_valid(card):
		#return false
	#var criterion = ImageUtils.make_card_criterion_card_uv(front_image, back_image)
	#var material: StandardMaterial3D = card.body.get_active_material(0)
	#material.albedo_texture = criterion
	#return true


## 为卡片添加行为
## @param card 卡片
## @param behavior 行为数据
## @return 是否添加成功
#static func card_add_behavior(card: CardEntity, behavior: LuaFunction) -> bool:
	## print(behavior)
	#var behavior_instance = load("res://core/behavior/behavior_lua.gd").new()
	#behavior_instance.data = behavior.invoke()
	## print(LuaUtils.table_to_dictionary(behavior_instance.data))
	## FIXME： 行为需要分配一个单独ID，并且需要维护一个表用于表示父级
	##behavior["user_id"] = card.name
	#Utils.get_node_entity(card).behavior_manager.add_behavior_to_group(behavior_instance.data["type"], behavior_instance)
	#return true


# 判断指定玩家是否可以检查卡片的信息
static func check_card_can_look_info(card: String, player: String) -> bool:
	# 1. 检查卡片是否是背面朝上的
	var front = GApiManager.card_api.get_front(card)
	# 如果是正面朝上的，我们就可以检查其信息
	if front:
		return true
	# 如果是背面朝上的，也有些情况下可以检查卡片信息
	else:
		# 1. 控制者是 player 并且存在于场上的
		var card_player_id = GApiManager.card_api.get_controller(card)
		var in_area = GApiManager.card_api.get_area(card)
		if card_player_id == player and in_area["area_id"] != null:
			return true
		#return true
	return false
