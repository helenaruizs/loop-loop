class_name Character

extends CharacterBody2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

@onready var feet: Area2D = $Feet
@onready var sprite_fx: Sprite2D = $SpriteFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var speed := 600.0
@export var acceleration: float = 4000.0         # How fast you reach max speed
@export var deacceleration: float = 3500.0       # How fast you stop
@export var gravity: float = 4500.0
@export var coyote_time: float = 0.18            # seconds grace after leaving ground
@export var jump_buffer_duration: float = 0.14   
@export var jump_power := -1100.0

var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var is_current := false

func _ready() -> void:
	sprite_fx.visible = false
	set_shader_intensity(0.0)


func char_physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
	
	# — COYOTE TIME —
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	

	# — JUMP BUFFER —
	if Input.is_action_just_pressed("jump"):
		jump_buffer = jump_buffer_duration
	else:
		jump_buffer = max(jump_buffer - delta, 0.0)

# — PERFORM JUMP IF WITHIN EITHER WINDOW —
	if jump_buffer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_power
		jump_buffer = 0.0
		coyote_timer = 0.0

# — VARIABLE JUMP HEIGHT (SNAPPY CUT) —
	if velocity.y < 0.0 and Input.is_action_just_released("jump"):
		velocity.y *= 0.45  # adjust multiplier for more/less cut

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# — HORIZONTAL INPUT & SMOOTH MOVE —
	var input_dir: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if abs(input_dir) > 0.01:
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deacceleration * delta)

	move_and_slide()


func tween_shader(intensity_start: float, intensity_end: float) -> void:
	var tween: Tween = create_tween()
	var duration:= 0.1
	tween.tween_method(set_shader_intensity, intensity_start, intensity_end, duration)

func set_shader_intensity(intensity: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", intensity)
	
