class_name Character

extends CharacterBody2D

var music_bus_index := AudioServer.get_bus_index("Music") # Or whatever name you used
var filter_effect_phaser := AudioServer.get_bus_effect(music_bus_index, 1) as AudioEffectLowPassFilter
var filter_effect_reverb := AudioServer.get_bus_effect(music_bus_index, 2) as AudioEffectLowPassFilter
var filter_effect_lowpass := AudioServer.get_bus_effect(music_bus_index, 0) as AudioEffectLowPassFilter

# Tweak these values for your look:
const NORMAL_SCALE: Vector2 = Vector2(1, 1)
const JUMP_STRETCH: Vector2 = Vector2(0.89, 1.2)  # Tall and thin
const LAND_SQUASH: Vector2 = Vector2(1.4, 0.78)   # Short and wide
const TWEEN_TIME: float = 0.2

const WALK_SQUASH: Vector2 = Vector2(1.24, 0.78)   # Short and wide
const WALK_STRETCH: Vector2 = Vector2(0.95, 1.1)  # Tall and thin

var music: AudioStreamPlayer
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

var color_name: Globals.ColorNames
var hl_color: Color
var character_color: Color
# cache the rays and their last‐hit markers
var last_hits: Dictionary[RayCast2D, Area2D]= {}

# Keep track of which markers were hit last frame
var last_markers: Array[Node2D] = []

var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var is_current := false

var is_jumping := false

var marker_active_rays: Dictionary = {} # marker : count of rays touching

func _ready() -> void:
	sprite_fx.visible = false
	set_shader_intensity(1.0)
	# Initialize last_hits so each ray maps to a null “last collider”
	last_hits[ray_up]    = null
	last_hits[ray_right] = null
	last_hits[ray_down]  = null
	last_hits[ray_left]  = null
	Globals.level_completed.connect(on_level_completed)


#
#func _physics_process(delta: float) -> void:
	#var rays: Array = [ray_up, ray_right, ray_down, ray_left]
	#for ray: RayCast2D in rays:
		#var prev_marker: Area2D = last_hits[ray] as Area2D
		#var current_marker: Area2D = null
		#if ray.is_colliding():
			#current_marker = ray.get_collider() as Area2D
#
		## EXIT logic (ray left a marker)
		#if prev_marker != null and prev_marker != current_marker:
			#var parent: = prev_marker.get_parent()
			#marker_active_rays[prev_marker] = marker_active_rays.get(prev_marker, 1) - 1
			#print("Ray exit", prev_marker, "count:", marker_active_rays[prev_marker])
			#if marker_active_rays[prev_marker] <= 0:
				## Only fire off event if *no* rays are left touching this marker!
				#parent.on_marker_exit()
				#marker_active_rays.erase(prev_marker)
			#last_hits[ray] = null
#
		## ENTER logic (ray entered a new marker)
		#if current_marker != null and prev_marker != current_marker:
			#var parent: = current_marker.get_parent()
			#marker_active_rays[current_marker] = marker_active_rays.get(current_marker, 0) + 1
			#print("Ray enter", current_marker, "count:", marker_active_rays[current_marker])
			#if marker_active_rays[current_marker] == 1:
				## Only fire if *first* ray is touching this marker!
				#parent.on_marker_enter(self)
			#last_hits[ray] = current_marker

	

func _tween_scale(target: Vector2) -> void:
	sprite.scale = sprite.scale.lerp(target, 0.65)  # Immediate, or use Tween for smoother

	# Or for smoothness (Tween v4+ style)
	# var tw = create_tween()
	# tw.tween_property(visual, "scale", target, TWEEN_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
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

		# Detect jump start (leaving the floor)
	if not is_on_floor() and !is_jumping:
		is_jumping = true
		_tween_scale(JUMP_STRETCH)
# Detect landing (touching the floor after falling)
	elif is_on_floor() and is_jumping:
		is_jumping = false
		_tween_scale(LAND_SQUASH)
		await get_tree().create_timer(TWEEN_TIME).timeout
		_tween_scale(NORMAL_SCALE)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# — HORIZONTAL INPUT & SMOOTH MOVE —
	var input_dir: float = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if abs(input_dir) > 0.01:
		sprite.scale.x = 1.2
		sprite.scale.y = 0.9
		sprite.flip_h = input_dir < 0.0
		velocity.x = move_toward(velocity.x, input_dir * speed, acceleration * delta)
	else:
		sprite.scale.x = 1.0
		sprite.scale.y = 1.0
		velocity.x = move_toward(velocity.x, 0.0, deacceleration * delta)
	
	# --- SKEW EFFECT BASED ON DIRECTION ---
	var max_skew := 0.015 # Radians, tweak as desired
	var target_skew := max_skew * input_dir
	sprite.skew = lerp(sprite.skew, target_skew, 0.17)
	
	move_and_slide()
	
	
	var rays: Array = [ray_up, ray_right, ray_down, ray_left]
	for ray: RayCast2D in rays:
		var prev_marker: Area2D = last_hits[ray] as Area2D
		var current_marker: Area2D = null
		if ray.is_colliding():
			current_marker = ray.get_collider() as Area2D

		# EXIT logic (ray left a marker)
		if prev_marker != null and prev_marker != current_marker:
			var parent: = prev_marker.get_parent()
			marker_active_rays[prev_marker] = marker_active_rays.get(prev_marker, 1) - 1
			print("Ray exit", prev_marker, "count:", marker_active_rays[prev_marker])
			if marker_active_rays[prev_marker] <= 0:
				# Only fire off event if *no* rays are left touching this marker!
				parent.on_marker_exit()
				marker_active_rays.erase(prev_marker)
			last_hits[ray] = null

		# ENTER logic (ray entered a new marker)
		if current_marker != null and prev_marker != current_marker:
			var parent: = current_marker.get_parent()
			marker_active_rays[current_marker] = marker_active_rays.get(current_marker, 0) + 1
			print("Ray enter", current_marker, "count:", marker_active_rays[current_marker])
			if marker_active_rays[current_marker] == 1:
				# Only fire if *first* ray is touching this marker!
				parent.on_marker_enter(self)
			last_hits[ray] = current_marker
	
		# Normalized screen position
	var viewport_size := get_viewport().get_visible_rect().size
	var norm_x :float = clamp(position.x / viewport_size.x, 0, 1)
	var norm_y : float = clamp(position.y / viewport_size.y, 0, 1)

# Use a gentle subrange
	var min_room := 0.6
	var max_room := 0.8
	var room_size : float= lerp(min_room, max_room, norm_x)

	var min_depth := 0.4
	var max_depth := 0.8
	var depth : float= lerp(min_depth, max_depth, norm_y)

	var min_cutoff := 2000.0
	var max_cutoff := 4500.0
	var cutoff : float= lerp(min_cutoff, max_cutoff, norm_y)
# Apply to audio effect if it's valid
	#if filter_effect_phaser:
		#filter_effect_phaser.set("depth", depth)
	#if filter_effect_reverb:
		#filter_effect_reverb.set("room_size", room_size)
	#if filter_effect_lowpass:
		#filter_effect_lowpass.set("cutoff_hz", cutoff)
		
func tween_shader(intensity_start: float, intensity_end: float) -> void:
	var tween: Tween = create_tween()
	var duration:= 0.1
	tween.tween_method(set_shader_intensity, intensity_start, intensity_end, duration)

func set_shader_intensity(intensity: float) -> void:
	sprite.material.set_shader_parameter("blink_intensity", intensity)

func set_shader_colors(albedo: Color, hl: Color) -> void:
	sprite.material.set_shader_parameter("albedo_color", albedo)
	sprite.material.set_shader_parameter("blink_color", hl)

func set_tempo(tempo: float) -> void:
	animation_player.speed_scale = animation_player.speed_scale / tempo

func darken(value: float) -> void:
	sprite.material.set_shader_parameter("multiply_intensity", value)

func on_level_completed() -> void:
	set_shader_colors(Color.WHITE, Color.WHITE)
