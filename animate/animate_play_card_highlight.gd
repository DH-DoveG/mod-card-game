extends Animate


@onready var animation = $UI/Animation/AnimationPlayer


var title: String
var detail: String
var form: String
var image_id: String
var sound_id: String


func set_arg(arg: Dictionary) -> void:
	title = arg["title"]
	detail = arg["detail"]
	form = arg["form"]
	image_id = arg["image"]
	sound_id = arg["sound"]


func play() -> void:
	animation.play(&"show")
	$UI/Animation/Card.texture = GResourceManager.get_image_resoure(image_id)
	$UI/Animation/Title.text = title
	$UI/Animation/Detail.text = detail
	$UI/Animation/Form.text = form
	await animation.animation_finished
	emit_signal(&"finished")


func play_sound():
	# GAudioManager.play_sound(sound_id)
	pass


func get_time() -> float:
	return 1.0 # 动画持续1s
