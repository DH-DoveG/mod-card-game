extends Object
class_name CardUtils

static func create(id: String, card_meta = null, _parent = null) -> CardEntity:
	var card: CardEntity = CardEntity.new()
	card.name = id

	card.set_entity(card_meta)
	return card

	##build_location.add_card_node(card)

	##card.global_position.x = build_location.global_position.x
	##card.global_position.z = build_location.global_position.z

# FIXME: 为卡片添加属性

# 	#var module: StateEntry = card.get_state_manager().get_state("Attribute")

		## card.rotation_degrees = rotation

	## print(LuaUtils.table_to_dictionary(behavior_instance.data))
	## FIXME： 行为需要分配一个单独ID，并且需要维护一个表用于表示父级
	##behavior["user_id"] = card.name

# 判断指定玩家是否可以检查卡片的信息
static func check_card_can_look_info(card: String, player: String) -> bool:

	var front = GApiManager.card_api.get_front(card)
	# 如果是正面朝上的，我们就可以检查其信息
	if front:
		return true
	# 如果是背面朝上的，也有些情况下可以检查卡片信息
	else:

		var card_player_id = GApiManager.card_api.get_controller(card)
		var in_area = GApiManager.card_api.get_area(card)
		if card_player_id == player and in_area["area_id"] != null:
			return true
	return false
