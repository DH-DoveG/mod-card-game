@tool
extends Control


#
#func _on_sidebar_folded(status: bool) -> void:
	#var t = get_tree().create_tween().set_parallel(true)
	#if status:
		#t.tween_property($SVC/SV, "size:x", 1920, 0.25)
		#t.tween_property($SVC, "size:x", 1920, 0.25)
		#t.tween_property($SVC, "position:x", 0, 0.25)
		#t.tween_property($UI/PlayerHandView, "position:x", 880, 0.25)
		#t.tween_property($UI/Round, "position:x", 768, 0.25)
	#else:
		#t.tween_property($SVC/SV, "size:x", 1344, 0.25)
		#t.tween_property($SVC, "size:x", 1344, 0.25)
		#t.tween_property($SVC, "position:x", 576, 0.25)
		#t.tween_property($UI/PlayerHandView, "position:x", 1200, 0.25)
		#t.tween_property($UI/Round, "position:x", 1050, 0.25)



@export var fold = true:
	set(v):
		fold = v
		if not get_tree(): return
		if fold:
			var t = get_tree().create_tween().set_parallel(true)
			for i in $Tab/VBox.get_children():
				t.tween_property(i, "offset_transform_position:x", 0, 0.25)
			t.tween_property($Content, "position:x", -576, 0.25)
			t.tween_property($Tab, "position:x", 0, 0.25)
		else:
			var t = get_tree().create_tween().set_parallel(true)
			t.tween_property($Content, "position:x", 0, 0.25)
			t.tween_property($Tab, "position:x", 576, 0.25)
		folded.emit(fold)


var focus_item = null


signal folded(status: bool)


func _ready() -> void:
	for i in $Tab/VBox.get_children():
		i.mouse_entered.connect(func():
			if focus_item == i: return
			var t = get_tree().create_tween()
			t.tween_property(i, "offset_transform_position:x", 128, 0.15)
		)
		i.mouse_exited.connect(func():
			if focus_item == i: return
			var t = get_tree().create_tween()
			t.tween_property(i, "offset_transform_position:x", 0, 0.15)
		)
		i.pressed.connect(func():
			# 切换
			if focus_item != i:
				var old = focus_item
				
				if old:
					var node = $Content.get_child(0)
					if node:
						node.queue_free()
				
				fold = false
				i.outline = true
				focus_item = i
				
				match i.content:
					"卡堆列表": 
						var scs = preload("res://components/sidebar/card_stack/sidebar_card_stack.tscn").instantiate()
						$Content.add_child(scs)
						pass
					"对局信息": pass
				
				if old:
					old.outline = false
					old.mouse_exited.emit()
			# 二次点击自己
			else:
				fold = true
				i.outline = false
				i.mouse_exited.emit()
				focus_item = null
				var node = $Content.get_child(0)
				if node:
					node.queue_free()
		)
