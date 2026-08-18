@tool
extends TextureButton
@export_color_no_alpha var bg_color = Color("#9e9e9e"):
	set(v):
		bg_color = v
		$Background.color = bg_color
@export var content = "":
	set(v):
		content = v
		$Text.text = content
@export var icon = null:
	set(v):
		icon = v
		if is_inside_tree():
			$Icon.texture = icon
@export var outline = false:
	set(v):
		outline = v
		$Outline.visible = v
@export var left = true:
	set(v):
		left = v
		if not is_inside_tree():
			return
		if left:
			if get_node("Icon") and get_node("Text"):
				$Outline.position.x = 0
				$Icon.position.x = 16
				$Text.position.x = 80
				$Text.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			pass
		else:
			if get_node("Icon") and get_node("Text"):
				$Outline.position.x = 200
				$Icon.position.x = 152
				$Text.position.x = 8
				$Text.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_RIGHT
			pass


func _ready() -> void:
	if icon != null:
		icon = icon
	left = left
