extends StaticBody3D
class_name CardView3D


@onready var body: MeshInstance3D = $Body
#@onready var collision: CollisionShape3D = $Area3D/CS3D
var entity: CardEntity = null
#@onready var card_info_show = $CardInfoShow
#@onready var behavior_pop = $CanvasLayer/BehaviorPopupMenu


func _ready() -> void:
	add_to_group(&"CardView3D")


func _exit_tree() -> void:
	remove_from_group(&"CardView3D")


var in_free := false
func animate_free():
	in_free = true
	$CS3D.disabled = true
	queue_free()


func set_entity(data: CardEntity):
	#if entity != null and entity.is_connected("card_changed", _on_card_changed):
		#entity.disconnect("card_changed", _on_card_changed)
	name = data.name
	entity = data
	#entity.card_changed.connect(_on_card_changed)
	#_on_card_changed("card_name", entity)
	#_on_card_changed("standing_sign", entity)
	#FIXME: 设置后需要重新应用，也就是应该仅对 entity 赋值，在赋值完成后再赋值给 card
	var player = FindUtils.find_player(GApiManager.card_api.get_ownership(entity.name))
	#player.use_card_back
	var front = GResourceManager.get_image_resoure(data.image)
	var back = GResourceManager.get_image_resoure(player.use_card_back)
	var uv = ImageUtils.make_card_criterion_card_uv(front.get_image(), back.get_image())
	var s: StandardMaterial3D = body.get_active_material(0)
	s.albedo_texture = uv

#
#func _on_card_changed(_item: String, _ce: CardEntity):
	##if _item == "card_name":
		##var v = _ce.card_name
		##var cs = []
		##var index = 0
		##while true:
			##if v.length() - index < 9:
				##cs.append(v.substr(index))
				##break
			##cs.append(v.substr(index, 9))
			##index += 9
		##card_info_show.card_name.text = "\n".join(cs)
	##if _item == "standing_sign":
		##var v = _ce.standing_sign
		##if v.is_empty(): return
		##card_info_show.card_image.texture = GResourceManager.get_image_resoure(v)
	#pass

#
#func _ready() -> void:
	#body.get_active_material(0).resource_local_to_scene = true
	#add_to_group("card")


# func card_hide():
# 	hide()
# 	#collision.disabled = true


# func card_show():
# 	show()
# 	#collision.disabled = false


func set_outline_visible(_visible: bool) -> void:
	var shader: StandardMaterial3D = body.get_active_material(0).next_pass
	shader.grow = _visible


func set_outline_color(color: Color) -> void:
	var shader: StandardMaterial3D = body.get_active_material(0).next_pass
	shader.albedo_color = color

#
#func trigger_behavior_menu() -> void:
	#var battle: Battle = Utils.get_current_scene()
	#var pos = battle.scene.camera.unproject_position(global_position)
	##var __ = await entity.behavior_manager.show_menu(pos)
	##var __ = await entity.behavior_manager.show_menu(pos)
	#pos += battle.get_node("SVC").position
	##behavior_pop.show_menu(pos, entity.behavior_manager.behaviors, entity)
	#var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
	#battle.add_child(menu)
	#menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
	#menu.popup_hide.connect(func():
		#menu.queue_free()
	#)

#
#func show_in_panel() -> void:
	#var scene = get_tree().current_scene
	#if scene is Battle:
		## 1. 检查这张卡的持有者是否是主机玩家的（除非这张卡的 abs(x) 是 0）
		#var battle: Battle = scene
		#var controller = battle.battle_data_bind_list.player_bind_cards_of_controller
		#var show_key = false
		#var in_battle = false
		#
		#if (int(abs(rotation_degrees.x)) == 0 and int(abs(rotation_degrees.z)) == 0) or \
		   #(int(abs(rotation_degrees.x)) == 180 and int(abs(rotation_degrees.z)) == 180):
		##if is_front:
			#show_key = true
			#if show_key:
				#Utils.get_current_scene().event_manager.emit("SHOW_CARD_INFO_IN_PANEL", {
					#"params": entity
				#})
		#else:
			## 如果卡是否在场上
			#for area in battle.battle_data_bind_list.area_bind_cards:
				#if name in battle.battle_data_bind_list.area_bind_cards[area]:
					#in_battle = true
			## 卡的持有者是不是主机玩家
			#for c in controller:
				#if name in controller[c] and c == scene.host_player_id:
					#show_key = true
					#break
			## 卡片在场上，并且卡的持有者是主机玩家，玩家才可以在卡片处于盖放的状态下查看
			#if show_key and in_battle:
				#Utils.get_current_scene().event_manager.emit("SHOW_CARD_INFO_IN_PANEL", {
					#"params": entity
				#})


#func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#if event.is_action_pressed("click_card"):
		#var scene = get_tree().current_scene
		#if scene is not Battle:
			#return
		## var pos = camera.unproject_position(global_position)
		##GCommandManager.execute(
			##ShowCardHeapListCommand.new(),
			##{
				##"card": name,
				##"pos": pos
			##}
		##)

#
#func _on_area_3d_mouse_exited() -> void:
	#mouse_exited.emit()
#
#
#func _on_area_3d_mouse_entered() -> void:
	#show_in_panel()
	#mouse_entered.emit()

#
#func _on_static_body_3d_input_event(camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	#if event.is_action_pressed("click"):
		#var battle: Battle = Utils.get_current_scene()
		#var pos = camera.unproject_position(global_position)
		#pos += battle.get_node("SVC").position
		#var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
		#battle.add_child(menu)
		#menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
		#menu.popup_hide.connect(func():
			#menu.queue_free()
		#)

#
#
#func _on_static_body_3d_mouse_entered() -> void:
	#show_in_panel()
#
#
#func _on_static_body_3d_mouse_exited() -> void:
	#show_in_panel()
