extends TextureButton
class_name CardView2D

var entity: CardEntity = null
var menu_key = false
var relevance_menu = null
var in_free = false

var is_s := false


func _ready() -> void:
	add_to_group(&"CardView2D")


func _exit_tree() -> void:
	remove_from_group(&"CardView2D")


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
		var cpi = battle.battle_data_bind_list.card_public_information[card.name]
		if (battle.host_player_id not in cpi) and ("PUBLIC" not in cpi):
			var ownership = GApiManager.card_api.get_ownership(card.name)
			var player = FindUtils.find_player(ownership)
			texture_normal = GResourceManager.get_image_resoure(player.use_card_back)
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


func _on_mouse_entered() -> void:
	if Utils.get_current_scene().get("event_manager") != null:
		Utils.get_current_scene().event_manager.emit("SHOW_CARD_INFO_IN_PANEL", {
			"params": entity
		})
	
	set_outline(true)
	
	if menu_key:
		is_s = true
		await get_tree().create_timer(0.25).timeout
		if is_s == false: return
		var gp = global_position
		#print("scale: ", scale)
		#print("pos1: ", gp)
		#gp.y -= size.y * scale.y #/ 3
		gp.y -= 10
		gp.x += size.x * scale.x / 2
		#print("pos2: ", gp)
		var pos = gp
		var n = preload("res://dev/neo_behavior_popup_menu.tscn").instantiate()
		get_tree().current_scene.add_child(n)
		await n.set_popup(pos, entity.behaviors, entity)
		if is_instance_valid(n):
			n.set_exp_mask(get_global_rect())
			n.set_process(true)


func _on_mouse_exited() -> void:
	set_outline(false)
	is_s = false
