extends Node
class_name CoreResourceApi


@rpc("any_peer", "call_local", "reliable")
func play_sound(_id: String) -> void:
	#GAudioManager.play_sound(id)
	pass


@rpc("any_peer", "call_local", "reliable")
func play_music(_id: String) -> void:
	#GAudioManager.play_music(id)
	pass
