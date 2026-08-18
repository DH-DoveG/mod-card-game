extends Line
class_name ArrowLine


@onready var arrow = $Path/PathFollow3D/Arrow
@onready var path_animation = $Path/PathFollow3D/AnimationPlayer

@export var type = ArrowType.ATTACK:
	set(v):
		type = v
		call_deferred("change_type")


enum ArrowType {
	ATTACK,
	MOVE,
	EFFECT
}

# Straight
# Curve
enum LineType {
	STRAIGHT,
	CURVE
}


func set_path(start: Vector3, target: Vector3, lt: LineType = LineType.CURVE) -> void:
	match lt:
		LineType.CURVE:
			var curve = Curve3D.new()
			curve.add_point(start, Vector3.ZERO, Vector3(0, start.y + 0.3, 0))
			curve.add_point(target, Vector3.ZERO, Vector3.ZERO)
			$Path.curve = curve
		
		# 直线，但是整体提升0.125m
		LineType.STRAIGHT:
			var straight = Curve3D.new()
			start.y += 0.125
			target.y += 0.125
			straight.add_point(start, Vector3.ZERO, Vector3.ZERO)
			straight.add_point(target, Vector3.ZERO, Vector3.ZERO)
			$Path.curve = straight


func change_type() -> void:
	#match type:
		#ArrowType.ATTACK:
			#$Path/PathFollow3D/Arrow.texture = load("res://assets/images/arrow/ArrowRed.png")
			#($Path/PathFollow3D/GPUParticles3D.process_material as ParticleProcessMaterial).color = Color8(255, 0, 0, 255)
		#ArrowType.MOVE:
			#$Path/PathFollow3D/Arrow.texture = load("res://assets/images/arrow/ArrowBlue.png")
			#($Path/PathFollow3D/GPUParticles3D.process_material as ParticleProcessMaterial).color = Color8(0, 0, 255, 255)
		#ArrowType.EFFECT:
			#$Path/PathFollow3D/Arrow.texture = load("res://assets/images/arrow/ArrowGreen.png")
			#($Path/PathFollow3D/GPUParticles3D.process_material as ParticleProcessMaterial).color = Color8(0, 255, 0, 255)
	pass
