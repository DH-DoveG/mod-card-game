extends Animate


var context: String
var sound: String
@onready var animation = $UI/Animation/AnimationPlayer
@onready var animation_next_round_ap = $UI/Animation/NextRoundAP


func set_arg(arg: Dictionary) -> void:
	context = arg["context"]
	sound = arg["sound"]


func play_sound():
	pass
	#if sound:
		#GAudioManager.play_sound(sound)


func play() -> void:
	animation.play(&"show")
	animation_next_round_ap.text = context
	await animation.animation_finished
	
	emit_signal(&"finished")


func get_time() -> float:
	return 1.0 # 动画持续1s
