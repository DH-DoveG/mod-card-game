extends Node
class_name CoreViewApi

@rpc("any_peer", "call_remote", "reliable")
func card_move(_card_id: String, _area_id: String, _mode: String, _time: float) -> void:

	##var tp = FindUtils.find_area(area_id).get_top_position()

		#"object": FindUtils.find_card(card_id),
		#"start_position": FindUtils.find_card(card_id).global_position,

	await Utils.get_scene_tree().create_timer(0.1).timeout

@rpc("any_peer", "call_remote", "reliable")
func phase_show(content: String, sound) -> void:
	var animate = load("res://animate/animate_play_icon_phase.tscn").instantiate()
	Utils.get_current_scene().add_child(animate)
	animate.set_arg({
		"context": content,
		"sound": sound
	})
	animate.play()
	await animate.finished
	await Utils.get_scene_tree().create_timer(0.1).timeout

func card_effect_show(title: String, detail: String, form: String, image: String, sound: String) -> void:
	var animate = load("res://animate/animate_play_card_highlight.tscn").instantiate()
	Utils.get_current_scene().add_child(animate)
	animate.set_arg({
		"title": title,
		"detail": detail,
		"form": form,
		"image": image,
		"sound": sound
	})
	animate.play()
	await animate.finished
	await Utils.get_scene_tree().create_timer(0.1).timeout

@rpc("any_peer", "call_local", "reliable")
func info(text, pos) -> void:
	ToastUtils.info(text, pos)

@rpc("any_peer", "call_local", "reliable")
func warn(text, pos) -> void:
	ToastUtils.warn(text, pos)

@rpc("any_peer", "call_local", "reliable")
func error(text, pos) -> void:
	ToastUtils.error(text, pos)

@rpc("any_peer", "call_local", "reliable")
func success(text, pos) -> void:
	ToastUtils.success(text, pos)
