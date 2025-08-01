extends ColorRect

@export var shader_material: ShaderMaterial

var direction:= 0.0

#func _ready() -> void:
	#shader_material.set_shader_parameter("swirl_direction", 0.0)
#
#func _process(delta: float) -> void:
	#direction = lerp(direction, 0.0, delta * 1.5)
	#shader_material.set_shader_parameter("swirl_direction", clamp(direction, 0.0, 0.1))

func update_bg_fx(value: float) -> void:
	direction += value
	shader_material.set_shader_parameter("swirl_direction", direction)

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_pressed():
		## Increase hype on any input
		#hype += 0.2
		#hype = min(hype, 1.0)
