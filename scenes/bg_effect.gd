extends ColorRect

@export var shader_material: ShaderMaterial

var hype:= 0.0

func _ready() -> void:
	shader_material.set_shader_parameter("hype", 0.0)

func _process(delta: float) -> void:
	hype = lerp(hype, 0.0, delta * 1.5)
	shader_material.set_shader_parameter("hype", clamp(hype, 0.0, 1.0))

func update_bg_fx(_hype: float) -> void:
	# Decay hype over time (feel free to adjust speed)
	print("trying to update")
	shader_material.set_shader_parameter("hype",_hype)
	hype = _hype

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_pressed():
		## Increase hype on any input
		#hype += 0.2
		#hype = min(hype, 1.0)
