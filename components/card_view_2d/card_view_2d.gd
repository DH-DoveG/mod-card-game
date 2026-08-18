extends TextureButton
class_name CardView2D

var entity: CardEntity = null
var menu_key = false

var relevance_menu = null


func _ready() -> void:
	add_to_group(&"CardView2D")


func _exit_tree() -> void:
	remove_from_group(&"CardView2D")




var in_free = false

func animate_free():
	in_free = true
	disabled = true
	$RR.hide()
	var sm: ShaderMaterial = ShaderMaterial.new()
	sm.shader = load("res://assets/shader/canvas_item/溶解.gdshader")
	sm.set_shader_parameter("direction", 90.0)
	sm.set_shader_parameter("burnColor", Color("000"))
	sm.set_shader_parameter("noiseForce", 0.45)
	sm.set_shader_parameter("borderWidth", 0.15)
	sm.set_shader_parameter("noiseTexture", load("res://assets/noise_texture_2d.res"))
	# use tweens to animate the progress value
	material = sm
	var tween = get_tree().create_tween()
	tween.tween_method(func(value):
		material.set_shader_parameter("progress", value)
	, -1.5, 1.5, 0.3)
	tween.finished.connect(func():
		if is_instance_valid(self):
			queue_free()
	)



func set_card(card: CardEntity, is_check_see = true) -> void:
	name = card.name
	var img = GResourceManager.get_image_resoure(card.image)
	texture_normal = img
	entity = card

	# 获取卡片的持有者
	# is_check_see 用来检查 host_player 是否有查看权限
	if is_check_see:
		var battle: Battle = Utils.get_current_scene()
		if card.name not in battle.battle_data_bind_list.card_public_information[battle.host_player_id]:
			var ownership = GApiManager.card_api.get_ownership(card.name)
			var player = FindUtils.find_player(ownership)
			texture_normal = GResourceManager.get_image_resoure(player.use_card_back)
			# texture_normal = GResourceManager.get_image_resoure(card.image)
			return
	texture_normal = GResourceManager.get_image_resoure(card.image)


func check_menu():
	var battle: Battle = Utils.get_current_scene()
	if entity.name in battle.battle_data_bind_list.card_public_information[battle.host_player_id]:
		var ownership = GApiManager.card_api.get_ownership(entity.name)
		if battle.host_player_id == ownership:
			set_menu(true)
			return
	set_menu(false)


func set_menu(k: bool):
	menu_key = k


func set_outline(k: bool):
	$RR.visible = k


func _on_pressed() -> void:
	#print("pressed 1")
	if menu_key:
		#print("pressed 2")
		var gp = global_position
		gp.y += 60
		gp.x += 120
		#$BehaviorPopupMenu.show_menu(gp, data.behavior_manager.behaviors, data)
		#data.entity.behavior_manager.show_menu(gp)
		var battle: Battle = Utils.get_current_scene()
		var pos = gp
		#var __ = await entity.behavior_manager.show_menu(pos)
		#var __ = await entity.behavior_manager.show_menu(pos)
		#pos += battle.get_node("SVC").position
		#behavior_pop.show_menu(pos, entity.behavior_manager.behaviors, entity)
		var menu: PopupMenu = preload("res://components/behavior_popup_menu/behavior_popup_menu.tscn").instantiate()
		battle.add_child(menu)
		menu.show_menu(pos, entity.behavior_manager.behaviors, entity)
		menu.popup_hide.connect(func():
			menu.queue_free()
		)
		relevance_menu = menu


func _on_mouse_entered() -> void:
	#if data and Utils.get_current_scene() is Battle:
		#var c = FindUtils.find_card(data.name)
		#c.show_in_panel()
	pass
