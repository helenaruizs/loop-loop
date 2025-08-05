extends Node


@onready var main_light: DirectionalLight2D = $DirectionalLight2D
@onready var animation_player: AnimationPlayer = $UI/AnimationPlayer
@onready var characters_root: Node2D = $Characters

@onready var timer: Timer = $Timer
@onready var fx_click: AudioStreamPlayer = $FX_Click
@onready var fx_click_2: AudioStreamPlayer = $FX_Click2
@onready var camera: Camera2D = $Camera2D
var music: AudioStreamPlayer

var characters: Array[Character]
var characters_number: int
@export var tempo: float = 0.5

@onready var spawn_points := []
@onready var audio: Node = $Audio

@onready var ui: UI = $UI
@onready var map: Map = $Map

var audio_tracks: Array[AudioStreamPlayer]

var current_char: Character = null
var current_color: Color
var current_index:= 0

var turn := 0

@export var max_time := 4
var current_time := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_tracks = audio.get_audio()
	music = audio_tracks[4]
	music.stop()
	for track: AudioStreamPlayer in audio_tracks:
		track.stop()
	for child in characters_root.get_children():
		if child is Node2D:
			spawn_points.append(child)
	characters_number = spawn_points.size()
	timer.start()
	timer.wait_time = tempo
	map.gameroot = self
	animation_player.speed_scale = animation_player.speed_scale / tempo
	#if characters.size() == 0:
		#push_error("Characters array is empty")
	#for char: Character in characters:
		#char.visible = false
		#char.character_color = Globals.colors[characters.find(char)]
		#char.hl_color = Globals.hl_colors[characters.find(char)]
		#char.set_shader_colors(char.character_color, char.hl_color)
		#char.set_tempo(tempo)
	#current_char = characters[0]
	current_color = Globals.bg_colors[0]
	#current_char.set_shader_intensity(1.0)
	#current_char.darken(0.0)
	change_light(current_color)

func _physics_process(delta: float) -> void:
	map.check_win_condition()
	if current_char:
		current_char.char_physics_process(delta)



func _restart_level() -> void:
	turn = 0
	current_time = 0
	var current_scene:= get_tree().current_scene
	get_tree().reload_current_scene()  # Godot 4.x only
	# For Godot 3.x, use:
	# get_tree().change_scene_to(current_scene)
	
func _on_timer_timeout() -> void:
	map.check_win_condition()
	current_time += 1
	if current_time != max_time:
		play_with_random_pitch(fx_click)
		#ui.bg.update_bg_fx(0.4)
	ui.update_timer_counter(current_time)
	if current_time == max_time:
		new_turn()
		current_time = 0

func spawn_character(idx: int) -> Character:
	var char_type: PackedScene = spawn_points[idx].get_char_scene()
	var char: Character = char_type.instantiate()
	characters_root.add_child(char)
	characters.append(char)
	init_character(char, idx)
	#current_char = char
	# Set position at spawn point if exists
	if idx < spawn_points.size():
		char.global_position = spawn_points[idx].global_position
	else:
		char.global_position = characters_root.global_position  # Fallback
	return char

func init_character(char: Character, index: int) -> void:
	#char.visible = false
	char.character_color = Globals.colors[index]
	char.hl_color = Globals.hl_colors[index]
	char.color_name = index
	char.set_shader_colors(char.character_color, char.hl_color)
	char.set_tempo(tempo)
	char.music = music
	char.map = map
	
func new_turn() -> void:
	turn += 1
	fx_click_2.play()
	ui.bg.update_bg_fx(1.0)
	
	if turn == 1:
		music.play()
		#audio_tracks[0].play()
	
	if turn <= characters_number:
		# Clean up previous char if any
		if current_char:
			current_char.tween_shader(1.0, 0.0)
			#current_char.animation_player.play("blink")
			current_char.animation_player.play("frozen")
			current_char.darken(0.4)

		# Spawn new char for this turn
		var char: Character = spawn_character(turn - 1)
		current_char = char
		current_index = turn - 1
		
		char.animation_player.play("blink")
		await char.animation_player.animation_finished
		char.animation_player.play("idle_bob")
		char.darken(0.0)
		print(char.is_jumping)
		print(current_char.velocity.y)
		current_char.extra_coyote = true
		current_color = Globals.bg_colors[current_index]
		char.tween_shader(0.0, 1.0)
		change_light(current_color)
		
		#audio_tracks[1].play()
		return  # Do not run cycling logic below!

	# From here on, just cycle
	if current_char:
		current_char.tween_shader(1.0, 0.0)
		#current_char.animation_player.play("blink")
		current_char.animation_player.play("frozen")
		current_char.darken(0.4)

	
	#audio_tracks[2].play()
	current_index = (current_index + 1) % characters.size()
	current_char = characters[current_index]
	current_char.animation_player.play("blink")
	await current_char.animation_player.animation_finished
	current_char.animation_player.play("idle_bob")
	current_char.darken(0.0)
	print(current_char.is_jumping)
	
	print(current_char.velocity.y)
	current_char.extra_coyote = true
	current_color = Globals.bg_colors[current_index]
	current_char.tween_shader(0.0, 1.0)
	change_light(current_color)



func tween_light() -> void:
	var tween: Tween = create_tween()
	var duration:= 0.3
	tween.tween_method(change_light, Color.WHITE, current_color, duration)

func change_light(_color: Color) -> void:
	main_light.color = _color

func play_with_random_pitch(track: AudioStreamPlayer) -> void:
	var rng: = RandomNumberGenerator.new()
	track.pitch_scale = rng.randf_range(0.99, 1.03)
	track.play()
