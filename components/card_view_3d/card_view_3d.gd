extends StaticBody3D
class_name CardView3D


@onready var body: MeshInstance3D = $Body
var entity: CardEntity = null


func _ready() -> void:
	add_to_group(&"CardView3D")


func _exit_tree() -> void:
	remove_from_group(&"CardView3D")


var in_free := false
func animate_free():
	in_free = true
	$CS3D.disabled = true
	queue_free()


func hightlight():
	pass


func normallight():
	pass


func trigger():
	var scene = get_tree().current_scene
	var pos = scene.scene.camera.unproject_position(global_position)
	if scene is Battle:
		# 1. 检查这张卡的持有者是否是主机玩家的（除非这张卡的 abs(x) 是 0）
		var battle: Battle = scene
		var controller = battle.battle_data_bind_list.player_bind_cards_of_controller
		var show_key = false
		var in_battle = false
		
		if (int(abs(rotation_degrees.x)) == 0 and int(abs(rotation_degrees.z)) == 0) or \
		   (int(abs(rotation_degrees.x)) == 180 and int(abs(rotation_degrees.z)) == 180):
			pass
		#if is_front:
			var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
			battle.add_child(menu)
			menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
			menu.popup_hide.connect(func():
				menu.queue_free()
			)
		else:
			# 如果卡是否在场上
			for area in battle.battle_data_bind_list.area_bind_cards:
				if entity.name in battle.battle_data_bind_list.area_bind_cards[area]:
					in_battle = true
			# 卡的持有者是不是主机玩家
			for c in controller:
				if entity.name in controller[c] and c == scene.host_player_id:
					show_key = true
					break
			# 卡片在场上，并且卡的持有者是主机玩家，玩家才可以在卡片处于盖放的状态下查看
			if show_key and in_battle:
				var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
				battle.add_child(menu)
				menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
				menu.popup_hide.connect(func():
					menu.queue_free()
				)
	pass


func set_entity(data: CardEntity):
	name = data.name
	entity = data
	var player = FindUtils.find_player(GApiManager.card_api.get_ownership(entity.name))
	var front = GResourceManager.get_image_resoure(data.image)
	var back = GResourceManager.get_image_resoure(player.use_card_back)
	var uv = ImageUtils.make_card_criterion_card_uv(front.get_image(), back.get_image())
	var s: StandardMaterial3D = body.get_active_material(0)
	s.albedo_texture = uv


func set_outline_visible(_visible: bool) -> void:
	var shader: StandardMaterial3D = body.get_active_material(0).next_pass
	shader.grow = _visible


func set_outline_color(color: Color) -> void:
	var shader: StandardMaterial3D = body.get_active_material(0).next_pass
	shader.albedo_color = color
