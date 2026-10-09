@tool
class_name CardHandLayout
extends Control

## ==== Signals ====

## Emitted when a card is hovered.
signal card_hovered(card: Control, index: int)
## Emitted when a card is no longer hovered.
signal card_unhovered()
## Emitted when a card is selected (clicked).
signal card_selected(card: Control, index: int)
## Emitted when the current selection is cleared.
signal card_deselected()

## ==== Layout Properties ====

## The total width for card arrangement.
@export var layout_width: float = 800.0:
	set(v):
		layout_width = v
		_apply_if_ready()

## Padding from left/right edges of the layout.
@export var edge_padding: float = 0.0:
	set(v):
		edge_padding = v
		_apply_if_ready()

## Spacing between cards when they fit within [member layout_width].
@export var card_spacing: float = 8.0:
	set(v):
		card_spacing = v
		_apply_if_ready()

## Minimum ratio of card width exposed when cards overlap
## (0.0 = fully hidden, 1.0 = fully visible).
@export var min_expose_ratio: float = 0.18:
	set(v):
		min_expose_ratio = v
		_apply_if_ready()

## ==== Hover Properties ====

## Whether hover effects are enabled.
@export var enable_hover: bool = true:
	set(v):
		enable_hover = v
		if not v:
			_hovered_index = -1
		_apply_if_ready()

## How much a hovered card rises along its own local up direction (pixels).
@export var hover_raise: float = 15.0:
	set(v):
		hover_raise = v
		_apply_if_ready()

## Scale factor applied to a hovered card.
@export var hover_scale: Vector2 = Vector2(1.05, 1.05):
	set(v):
		hover_scale = v
		_apply_if_ready()

## ==== Select Properties ====

## Whether click-to-select is enabled.
@export var enable_select: bool = true:
	set(v):
		enable_select = v
		if not v:
			_selected_index = -1
		_apply_if_ready()

## Scale factor applied to a selected (clicked) card.
@export var select_scale: Vector2 = Vector2(1.2, 1.2):
	set(v):
		select_scale = v
		_apply_if_ready()

## How much a selected card rises upward (pixels).
@export var select_raise: float = 18.0:
	set(v):
		select_raise = v
		_apply_if_ready()

## ==== Animation Properties ====

## Duration of layout transition animations (seconds).
@export var animation_time: float = 0.12:
	set(v):
		animation_time = v

## Ease type for animations.
@export var animation_ease: Tween.EaseType = Tween.EASE_OUT:
	set(v):
		animation_ease = v

## Transition type for animations.
@export var animation_trans: Tween.TransitionType = Tween.TRANS_QUAD:
	set(v):
		animation_trans = v

## ==== Internal State ====

var _hovered_index: int = -1
var _selected_index: int = -1
var _card_nodes: Array[Control] = []
var _tween: Tween

# ============================================================
# Lifecycle
# ============================================================

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	child_order_changed.connect(_on_children_changed)
	_refresh_cards()

func _notification(what: int) -> void:
	if what == NOTIFICATION_ENTER_TREE:
		_refresh_cards.call_deferred()

# ============================================================
# Public API
# ============================================================

## Deselect the currently selected card (if any).
func deselect_all() -> void:
	if _selected_index != -1:
		_selected_index = -1
		card_deselected.emit()
		_apply_if_ready()

## Get the currently selected card, or null if none.
func get_selected_card() -> Control:
	if _selected_index >= 0 and _selected_index < _card_nodes.size():
		return _card_nodes[_selected_index]
	return null

## Get the currently hovered card, or null if none.
func get_hovered_card() -> Control:
	if _hovered_index >= 0 and _hovered_index < _card_nodes.size():
		return _card_nodes[_hovered_index]
	return null

## Remove all cards.
func clear_cards() -> void:
	for card in _card_nodes:
		_disconnect_card_signals(card)
		card.queue_free()
	_card_nodes.clear()
	_hovered_index = -1
	_selected_index = -1
	_apply_if_ready()

# ============================================================
# Internal: Card Management
# ============================================================

func _refresh_cards() -> void:
	var old_count = _card_nodes.size()
	_card_nodes.clear()
	for child in get_children():
		if child is Control:
			_card_nodes.append(child as Control)
			if old_count == 0 or _card_nodes.size() > old_count:
				_connect_card_signals(child as Control)

	if _card_nodes.size() != old_count and _selected_index != -1:
		_selected_index = -1
		card_deselected.emit()

	_apply_if_ready()

func _connect_card_signals(card: Control) -> void:
	if not card.mouse_entered.is_connected(_on_card_mouse_entered.bind(card)):
		card.mouse_entered.connect(_on_card_mouse_entered.bind(card))
	if not card.mouse_exited.is_connected(_on_card_mouse_exited.bind(card)):
		card.mouse_exited.connect(_on_card_mouse_exited.bind(card))
	if not card.gui_input.is_connected(_on_card_gui_input.bind(card)):
		card.gui_input.connect(_on_card_gui_input.bind(card))

func _disconnect_card_signals(card: Control) -> void:
	if card.mouse_entered.is_connected(_on_card_mouse_entered.bind(card)):
		card.mouse_entered.disconnect(_on_card_mouse_entered.bind(card))
	if card.mouse_exited.is_connected(_on_card_mouse_exited.bind(card)):
		card.mouse_exited.disconnect(_on_card_mouse_exited.bind(card))
	if card.gui_input.is_connected(_on_card_gui_input.bind(card)):
		card.gui_input.disconnect(_on_card_gui_input.bind(card))

func _on_children_changed() -> void:
	_refresh_cards()

func _apply_if_ready() -> void:
	if is_inside_tree() and is_node_ready():
		_apply_layout()

# ============================================================
# Internal: Event Handlers
# ============================================================

func _on_card_mouse_entered(card: Control) -> void:
	if not enable_hover:
		return
	var idx = _card_nodes.find(card)
	if idx == -1:
		return
	if idx == _selected_index:
		return
	if idx != _hovered_index:
		_hovered_index = idx
		card_hovered.emit(card, idx)
		_apply_if_ready()

func _on_card_mouse_exited(card: Control) -> void:
	var idx = _card_nodes.find(card)
	if idx == _selected_index:
		return
	if idx == _hovered_index:
		_hovered_index = -1
		card_unhovered.emit()
		_apply_if_ready()

func _on_card_gui_input(event: InputEvent, card: Control) -> void:
	if not enable_select:
		return
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var idx = _card_nodes.find(card)
			if idx == -1:
				return
			if _selected_index == idx:
				return
			else:
				# Select: raise + scale + max z_index, then freeze
				_selected_index = idx
				card.z_index = 2
				var target_pos := card.position - Vector2(0, select_raise)
				if animation_time > 0.0 and is_inside_tree() and not Engine.is_editor_hint():
					var t := create_tween()
					t.set_parallel(true)
					t.tween_property(card, "position", target_pos, animation_time) \
						.set_ease(animation_ease).set_trans(animation_trans)
					t.tween_property(card, "scale", select_scale, animation_time) \
						.set_ease(animation_ease).set_trans(animation_trans)
				else:
					card.position = target_pos
					card.scale = select_scale
				card_selected.emit(card, idx)
			_apply_if_ready()

func _input(event: InputEvent) -> void:
	if _selected_index == -1 and _hovered_index == -1:
		return
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			# Check if the click landed on any card
			var on_card := false
			for c in _card_nodes:
				if is_instance_valid(c) and c.get_global_rect().has_point(get_global_mouse_position()):
					on_card = true
					break
			if on_card:
				return

			# Clicked empty space — deselect and unhover
			if _selected_index != -1:
				_selected_index = -1
				card_deselected.emit()
			if _hovered_index != -1:
				_hovered_index = -1
				card_unhovered.emit()
			_apply_if_ready()

# ============================================================
# Layout Engine
# ============================================================

func _apply_layout() -> void:
	var n = _card_nodes.size()
	if n == 0:
		return

	var card_w: float = _card_nodes[0].size.x
	var card_h: float = _card_nodes[0].size.y
	var avail_w = layout_width - 2.0 * edge_padding

	var step_x: float
	var start_x: float

	if n == 1:
		start_x = (layout_width - card_w) / 2.0
		step_x = 0.0
	else:
		var full_w = n * card_w + (n - 1) * card_spacing
		if full_w <= avail_w:
			start_x = (layout_width - full_w) / 2.0
			step_x = card_w + card_spacing
		else:
			step_x = (avail_w - card_w) / float(n - 1)
			var min_step = card_w * min_expose_ratio
			step_x = max(step_x, min_step)
			var total_w = card_w + (n - 1) * step_x
			start_x = (layout_width - total_w) / 2.0

	var do_anim = animation_time > 0.0 and is_inside_tree() and not Engine.is_editor_hint()

	if _tween and _tween.is_valid() and _tween.is_running():
		_tween.kill()
	_tween = null

	if do_anim:
		_tween = create_tween()
		_tween.set_parallel(true)

	for i in n:
		var card = _card_nodes[i]
		if not is_instance_valid(card):
			continue

		# Selected card: fully frozen
		if i == _selected_index:
			continue

		var pos = Vector2(start_x + i * step_x, (size.y - card_h) / 2.0)
		var scl = Vector2.ONE
		var z := 0

		if i == _hovered_index:
			scl = hover_scale
			z = 1
			pos.y -= hover_raise

		if do_anim:
			_tween.tween_property(card, "position", pos, animation_time) \
				.set_ease(animation_ease).set_trans(animation_trans)
			_tween.tween_property(card, "scale", scl, animation_time) \
				.set_ease(animation_ease).set_trans(animation_trans)
		else:
			card.position = pos
			card.scale = scl

		card.z_index = z
