@tool
extends Control

const CARD_IMAGE = preload("res://dev/assets/sn-0007.png")
const CARD_SIZE = Vector2(130, 182)

var _hand: CardHandLayout
var _count_label: Label
var _card_count: int = 0

func _ready() -> void:
	_setup_ui()

func _setup_ui() -> void:
	# ---- 顶部控制栏 ----
	var top_bar := HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_theme_constant_override("separation", 12)
	add_child(top_bar)

	var btn_add1 := _make_button("+1", _on_add.bind(1))
	var btn_add5 := _make_button("+5", _on_add.bind(5))
	_count_label = Label.new()
	_count_label.name = "CountLabel"
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.add_theme_font_size_override("font_size", 20)
	_update_count_label()
	var btn_rem1 := _make_button("-1", _on_remove.bind(1))
	var btn_rem5 := _make_button("-5", _on_remove.bind(5))
	var btn_clear := _make_button("Clear", _on_clear)
	var btn_exit := _make_button("Exit", _on_exit)

	top_bar.add_child(btn_add1)
	top_bar.add_child(btn_add5)
	top_bar.add_child(_count_label)
	top_bar.add_child(btn_rem1)
	top_bar.add_child(btn_rem5)
	top_bar.add_child(btn_clear)
	top_bar.add_child(btn_exit)

	# ---- 分隔线 ----
	var sep := HSeparator.new()
	sep.name = "Separator"
	add_child(sep)

	# ---- 手牌布局 ----
	_hand = CardHandLayout.new()
	_hand.name = "Hand"
	_hand.layout_width = 1000.0
	_hand.card_spacing = 10.0
	_hand.min_expose_ratio = 0.16
	_hand.hover_raise = 20.0
	_hand.hover_scale = Vector2(1.08, 1.08)
	_hand.select_scale = Vector2(1.25, 1.25)
	_hand.select_raise = 22.0
	_hand.animation_time = 0.12

	# 连接信号
	_hand.card_hovered.connect(_on_card_hovered)
	_hand.card_unhovered.connect(_on_card_unhovered)
	_hand.card_selected.connect(_on_card_selected)
	_hand.card_deselected.connect(_on_card_deselected)

	add_child(_hand)

	# ---- 预填充一些卡片用于初始预览 ----
	if Engine.is_editor_hint():
		# 编辑器中显示 5 张预览卡片
		_on_add(5)
	else:
		_on_add(7)

	# ---- 延迟执行布局（待子节点就绪) ----
	call_deferred(&"_notify_layout")

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		call_deferred(&"_notify_layout")

func _notify_layout() -> void:
	if not is_inside_tree() or not is_node_ready():
		return

	var tb = get_node_or_null("TopBar") as HBoxContainer
	var sep = get_node_or_null("Separator") as HSeparator
	if not tb or not _hand:
		return

	var tb_h = tb.size.y if tb.size.y > 0 else 50.0
	var sep_h := 4.0

	tb.position = Vector2(0, 10)
	tb.size.x = size.x

	if sep:
		sep.position = Vector2(20, tb_h + 16)
		sep.size.x = size.x - 40

	_hand.position = Vector2(0, tb_h + sep_h + 30)
	_hand.size = Vector2(size.x, CARD_SIZE.y + 60)
	_hand.layout_width = size.x - 80

# ============================================================
# Card Management
# ============================================================

func _make_card() -> TextureButton:
	#var card := TextureButton.new()
	#card.texture_normal = CARD_IMAGE
	##card.expand_mode = TextureButton.EXPAND_IGNORE_SIZE
	#card.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_COVERED
	#card.custom_minimum_size = CARD_SIZE
	#card.size = CARD_SIZE
	#card.name = "Card_%d" % _card_count
	var card = $TextureButton.duplicate()
	card.show()
	return card

func _add_card() -> void:
	var card := _make_card()
	_hand.add_child(card)
	_card_count += 1
	_update_count_label()
	 # FIXME: TextureButton 的点击事件没有触发！
	card.pressed.connect(func():
		print("123")
	)

func _remove_card() -> bool:
	if _card_count <= 0:
		return false
	var children = _hand.get_children()
	for i in range(children.size() - 1, -1, -1):
		var child := children[i] as Control
		if child:
			_hand.remove_child(child)
			child.queue_free()
			_card_count -= 1
			_update_count_label()
			return true
	return false

func _update_count_label() -> void:
	if _count_label:
		_count_label.text = "Cards: %d" % _card_count

# ============================================================
# Button Callbacks
# ============================================================

func _on_add(count: int) -> void:
	for _i in count:
		_add_card()

func _on_remove(count: int) -> void:
	for _i in count:
		if not _remove_card():
			break

func _on_clear() -> void:
	_hand.clear_cards()
	_card_count = 0
	_update_count_label()

func _on_exit() -> void:
	if not Engine.is_editor_hint():
		get_tree().quit()

# ============================================================
# Signal Callbacks
# ============================================================

func _on_card_hovered(card: Control, index: int) -> void:
	print("Hovered  card [%d]: %s" % [index, card.name])

func _on_card_unhovered() -> void:
	print("Unhovered")

func _on_card_selected(card: Control, index: int) -> void:
	print("Selected card [%d]: %s" % [index, card.name])

func _on_card_deselected() -> void:
	print("Deselected")

# ============================================================
# Helpers
# ============================================================

func _make_button(text: String, callback: Callable) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(65, 36)
	btn.pressed.connect(callback)
	return btn


func _on_texture_button_pressed() -> void:
	print(1) # 
	pass # Replace with function body.
