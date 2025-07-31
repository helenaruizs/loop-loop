class_name Character

extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed := 400.0
@export var jump_power := -500.0

var is_current := false

func _ready() -> void:
	set_shader_intensity(0.0)

func char_physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()


func tween_shader(intensity_start: float, intensity_end: float) -> void:
	var tween: Tween = create_tween()
	var duration:= 0.1
	tween.tween_method(set_shader_intensity, intensity_start, intensity_end, duration)

func set_shader_intensity(intensity: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", intensity)
	
