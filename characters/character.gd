class_name Character

extends CharacterBody2D

@onready var ray_down: RayCast2D = $RayDown
@onready var ray_up: RayCast2D = $RayUp
@onready var ray_right: RayCast2D = $RayRight
@onready var ray_left: RayCast2D = $RayLeft

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

var character_color: Color
# cache the rays and their last‐hit markers
var last_hits: Dictionary[RayCast2D, Area2D]= {}

# Keep track of which markers were hit last frame
var last_markers: Array[Node2D] = []

var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var is_current := false

var marker_active_rays: Dictionary = {} # marker : count of rays touching

func _ready() -> void:
	sprite_fx.visible = false
	set_shader_intensity(0.0)
	# Initialize last_hits so each ray maps to a null “last collider”
	last_hits[ray_up]    = null
	last_hits[ray_right] = null
	last_hits[ray_down]  = null
	last_hits[ray_left]  = null



func _physics_process(delta: float) -> void:
	for ray: RayCast2D in [ray_up, ray_right, ray_down, ray_left]:
		var prev_marker: Area2D = last_hits[ray] as Area2D
		var current_marker: Area2D = null

		if ray.is_colliding():
			current_marker = ray.get_collider() as Area2D

		# EXIT logic
		if prev_marker != null and prev_marker != current_marker:
			var parent: = prev_marker.get_parent()
			marker_active_rays[prev_marker] = marker_active_rays.get(prev_marker, 1) - 1
			if marker_active_rays[prev_marker] <= 0:
				parent.on_marker_exit()
				marker_active_rays.erase(prev_marker)
			last_hits[ray] = null

		# ENTER logic
		if current_marker != null and prev_marker != current_marker:
			var parent: = current_marker.get_parent()
			marker_active_rays[current_marker] = marker_active_rays.get(current_marker, 0) + 1
			if marker_active_rays[current_marker] == 1:
				parent.on_marker_enter(character_color)
			last_hits[ray] = current_marker
		#var prev := last_hits[ray]
		#var curr: Area2D = null
		#if ray.is_colliding():
			#curr = ray.get_collider() as Area2D
#
		## Exited?
		#if prev and prev != curr and prev.get_parent().has_method("on_marker_exit"):
			#prev.get_parent().on_marker_exit()
#
		## Entered?
		#if curr and curr != prev and curr.get_parent().has_method("on_marker_enter"):
			#curr.get_parent().on_marker_enter()
#
		## Store for next frame
		#last_hits[ray] = curr

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

func set_shader_albedo(color: Color) -> void:
	sprite.material.set_shader_parameter("albedo_color", color)
