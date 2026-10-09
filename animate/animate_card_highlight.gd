extends Animate

## 卡牌高亮动画
## 将目标卡牌拉向镜头、旋转到正面并放大展示，随后弹出该卡的行为菜单，
## 菜单关闭后恢复到原始位置与姿态。播放结束后发出 finished 信号。

# 目标卡（CardView3D）与其镜头
var card_view: CardView3D = null
var camera: Camera3D = null

# 记录动画开始前的初始状态，用于结束后恢复
var origin_body_pos: Vector3
var origin_nciv_pos: Vector3
var origin_nciv_ration: Quaternion
var origin_basis: Basis

func set_arg(arg: Dictionary) -> void:
	card_view = arg["card"]
	camera = arg["camera"]

func play() -> void:
	if card_view == null or camera == null:
		finished.emit()
		return

	var body: MeshInstance3D = card_view.body
	var nciv = card_view.nciv
	var view: Node3D = card_view.view

	# 记录初始状态
	origin_body_pos = body.global_position
	origin_nciv_pos = nciv.global_position
	origin_nciv_ration = nciv.quaternion
	origin_basis = view.global_transform.basis

	# 高亮：先暂停信息面板自身处理并提高渲染优先级
	nciv.useev = false
	nciv.set_process(false)
	nciv.set_rander_priority(4)

	# 朝向镜头方向拉近
	var _dir: Vector3 = (camera.global_position - origin_body_pos).normalized()
	var bd: Vector3 = origin_body_pos + _dir * 0.75
	var nd: Vector3 = origin_nciv_pos + _dir * 0.75
	nciv.quaternion = Quaternion(0.707107, 0, 0, 0.707107) # 正面向上

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(view, "global_transform:basis", camera.global_transform.basis, 0.10)
	tween.tween_property(body, "global_position", bd, 0.20)
	tween.tween_property(nciv, "global_position", nd, 0.20)
	tween.tween_property(body, "scale", Vector3(120, 120, 120), 0.20)
	tween.tween_property(nciv, "scale", Vector3(1.2, 1.2, 1.2), 0.20)
	tween.tween_property(body, "rotation", Vector3(0, 0, 0), 0.21)
	nciv.change_x(false)
	await tween.finished

	await get_tree().create_timer(2).timeout

	# 恢复原状
	nciv.set_rander_priority(2)
	nciv.change_x(true)
	# 旋转角度恢复时可能偏转是因为欧拉角的轴锁问题
	var tween2: Tween = create_tween().set_parallel(true)
	tween2.tween_property(view, "global_transform:basis", origin_basis, 0.10)
	tween2.tween_property(body, "global_position", origin_body_pos, 0.20)
	tween2.tween_property(nciv, "global_position", origin_nciv_pos, 0.20)
	tween2.tween_property(body, "scale", Vector3(100, 100, 100), 0.20)
	tween2.tween_property(nciv, "scale", Vector3(1, 1, 1), 0.20)
	tween2.tween_property(body, "rotation", Vector3(0, 0, 0), 0.21)
	await tween2.finished
	nciv.quaternion = origin_nciv_ration
	nciv.set_process(true)
	nciv.useev = true

	finished.emit()

func play_sound():
	pass

func get_time() -> float:
	return 0.5 # 动画预计耗时
