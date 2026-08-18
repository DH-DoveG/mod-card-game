extends Page

# 这个类有几大固定资源分类要显示

# 关于图片资源
# CARD_FRONT 卡图
# CARD_BACK 卡背
# BACKGROUND 背景
# AVATAR 头像（玩家）
# STANDING_SIGN 立牌（玩家）
# CARD_STANDING_SIGN 卡片立牌
# OTHER 其他
# 点击图像资源会放大，并且标注ID

# 关于音频资源
# 音效和音频并不是通过 tag 区分的，他们是不同的资源类目
# SOUND_EFFECTS 音效
# MUSICS 音乐
# 点击音频资源会播放，并且标注ID

@onready var tab_container = $TabContainer
@onready var image_option = $TabContainer/Image/VBox/CR/HBox/Option
@onready var image_grid = $TabContainer/Image/VBox/Scroll/GC
@onready var image_count = $TabContainer/Image/VBox/CR/Count

@onready var big_show_mask = $BigShowMask
@onready var big_show_image = $BigShowMask/Image
@onready var big_show_id = $BigShowMask/ID

var image_types = []
var sound_types = []


func _init() -> void:
	page_id = "RESOURCE_SHOW_PAGE"


func _ready() -> void:
	super()

	tab_container.set_tab_title(0, "   图 像   ")
	tab_container.set_tab_title(1, "   音 频   ")
	tab_container.set_tab_title(2, "   卡 片   ")
	
	var ks = []
	for k1 in GResourceManager.image_resource:
		for k2 in k1.tags:
			if k2 not in ks:
				ks.append(k2)
	for k in ks:
		image_option.add_item(k)
	
	_on_image_option_item_selected(0)
	_build_card_view()


# func _exit_tree() -> void:
# 	for ce in GCardEntityMount.get_children():
# 		if ce.name in ids:
# 			ce.queue_free()

var ids = []
var card_data_library = []
func _build_card_view():
	for ckey in GResourceManager.card_resource:
		var id = IDUtils.generate("__ResourceShowCardDataLibrary__")
		#var ce: CardEntity = GApiManager.card_api.create_entity(id, ckey)
		var card_meta = ModManager.do_mod_file(GResourceManager.card_resource[ckey]).invoke()
		card_meta["entity"]["id"] = id
		# var ce = preload("res://entity/card_entity/card_entity.tscn").instantiate()
		var ce = CardEntity.new()
		Utils.get_current_scene().add_child(ce)
		ce.name = id
		ce.image = card_meta["image"]
		ce.standing_sign = card_meta["standing_sign"]
		ce.card_name = card_meta["name"]
		ce.meta = card_meta
		
		add_child(ce)
		ids.append(id)
		card_data_library.append(ce)

	for card in card_data_library:
		var cv: CardView2D = load("res://components/card_view_2d/card_view_2d.tscn").instantiate()
		cv.set_card(card, false)
		cv.set_menu(false)
		$TabContainer/Card/Scroll/GC.add_child(cv)
		#cv.custom_minimum_size = Vector2i(187, 262)
		#cv.custom_maximum_size = Vector2i(187, 262)
		cv.custom_minimum_size = Vector2i(200, 280)
		cv.custom_maximum_size = Vector2i(200, 280)
		cv.pressed.connect(func():
			# 展开一个单独的卡片展示页面
			print("单独展示卡片详细内容：", card)
			pass
		)
	IDUtils.clear("CARD_")


func _on_image_option_item_selected(index: int) -> void:
	var _text: String = image_option.get_item_text(index)
	
	var item_size = Vector2.ZERO
	var item_columns = 5
	
	match _text:
		"OTHER": item_columns = 6;item_size = Vector2(224, 224)
		"CARD_BACK": item_columns = 11;item_size = Vector2(130, 182)
		"CARD_FRONT": item_columns = 11;item_size = Vector2(130, 182)
		"STANDING_SIGN": item_columns = 11;item_size = Vector2(130, 182)
		"CARD_STANDING_SIGN": item_columns = 6;item_size = Vector2(224, 224)
		"AVATAR": item_columns = 6;item_size = Vector2(224, 224)
		"BACKGROUND": item_columns = 3;item_size = Vector2(480, 270)
	image_grid.columns = item_columns
	
	for item in image_grid.get_children():
		item.queue_free()
	
	var count = 0
	for k1 in GResourceManager.image_resource:
		var k1res = GResourceManager.get_image_resoure(k1.id)
		if _text in k1.tags:
			var img = TextureButton.new()
			image_grid.add_child(img)
			img.ignore_texture_size = true
			img.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
			img.texture_normal = k1res
			img.custom_minimum_size = item_size
			img.size = item_size
			img.pressed.connect(func():
				show_big_image(k1res, k1.id)
			)
			count += 1
	image_count.text = "标签类别图像资源数量：" + str(count)


func show_big_image(img, id) -> void:
	big_show_mask.show()
	big_show_image.texture = img
	big_show_id.text = id


func _on_close_pressed() -> void:
	if big_show_mask.visible:
		big_show_mask.hide()
		return
	AsyncScene.new(
		"res://pages/index.tscn",
		AsyncScene.LoadingOperation.ReplaceImmediate,
		self
	) \
	.with_parameters({}) \
	.with_transition(AsyncScene.TransitionType.Iris, 1.0, Color("#323235")) \
	.start()


func _on_tab_container_tab_changed(_tab: int) -> void:
	pass
