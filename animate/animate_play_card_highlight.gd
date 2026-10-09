extends Animate

@onready var animation = $UI/AnimationPlayer

var title: String
var detail: String
var form: String
var image_id: String
var sound_id: String
var card_id: String

func set_arg(arg: Dictionary) -> void:
	card_id = arg["card"]
	title = arg["title"]
	detail = arg["detail"]
	form = arg["form"]
	image_id = arg["image"]
	sound_id = arg["sound"]

func play() -> void:
	var ce: CardEntity = FindUtils.find_card(card_id)
	var controller_id = GApiManager.card_api.get_controller(ce.name)
	var controller: Player = FindUtils.find_player(controller_id)
	
	animation.play(&"show")
	$UI/Animation/Card.texture = GResourceManager.get_image_resoure(image_id)
	$UI/Animation/Name.text = ce.card_name
	$UI/Animation/Title.text = title
	$UI/Animation/Detail.text = detail
	$UI/Animation/Form.text = "位  置：%s\n控制者：%s" % [form, controller.player_name]
	await animation.animation_finished
	emit_signal(&"finished")

func play_sound():

	pass

func get_time() -> float:
	return 1.0 # 动画持续1s
