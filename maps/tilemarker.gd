class_name TileMarker

extends Node2D

const RAY_BUFFER_FRAMES : int = 3
# how long to wait before actually firing the exit
const EXIT_DEBOUNCE := 0.2

signal objective_triggered_on(marker: TileMarker, color_name: Globals.ColorNames)
signal objective_triggered_off(marker: TileMarker, color_name: Globals.ColorNames)

@onready var blink: Sprite2D = $Blink
@onready var overlay: Sprite2D = $Overlay
@onready var area_2d: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var is_objective: bool = false
@export var objective_color : Globals.ColorNames
var color: Color
var char_color: Color
var gameroot: Node
var map: Map

var completed: bool

var occupant: Character = null  # Which character is currently occupying this marker
var prev_occupant: Character = null
var _exit_timer: Timer = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	color = Globals.hl_colors[objective_color]
	set_objective(color)
	if is_objective:
		add_to_group("objectives")
		sprite.modulate = color
		sprite.visible = true
	else:
		sprite.visible = false
	overlay.visible = false
	blink.visible = false
	darken(0.0)
	Globals.level_completed.connect(on_level_completed)

func _physics_process(delta: float) -> void:
	#if completed:
		#blink.visible = true
	#else:
		#blink.visible = false
	
	if is_objective:
		map.check_win_condition()
		if overlay.visible:
			if overlay.material.get_shader_parameter("blink_color") == color:
				completed = true
				map.check_win_condition()
				#map.add_marker_to_list(self, objective_color)
			#
			if overlay.material.get_shader_parameter("blink_color") != color:
				completed = false
				##map.remove_marker_from_list(self, objective_color)
			##map.remove_marker_from_list(self, objective_color)
		
		if overlay.visible == false:
			completed = false
#
		#else:
			#if gameroot.current_char:
				#if gameroot.current_char.check_ray_colliding(self):
					#print("IM HEREEEE 22222")
					#return
			#completed = false
	
func on_marker_enter(character: Character) -> void:
	# if it's the same occupant, nothing to do
	if occupant == character:
		return
	# if someone else was in here, clear them immediately
	if occupant != null:
		_do_marker_exit(occupant)
	occupant = character
	_do_marker_enter(occupant)




func on_marker_exit(character: Character) -> void:
	# only fire exit for our occupant
	if occupant != character:
		return
	_do_marker_exit(occupant)
	occupant = null


func _do_marker_enter(character: Character) -> void:
	# your existing visual/shader logic
	set_shader_colors(character.character_color, character.hl_color)
	set_shader_intensity(1.0)
	overlay.visible = true

	#if is_objective and character.color_name == objective_color:
		#map.add_marker_to_list(self, objective_color)
		##emit_signal("objective_triggered_on", self, objective_color)
		#get_parent().check_win_condition()


func _do_marker_exit(character: Character) -> void:
	# your existing undo-visual logic
	set_shader_intensity(0.0)
	overlay.visible = false

	#if is_objective and character.color_name == objective_color:
		#map.remove_marker_from_list(self, objective_color)
		##emit_signal("objective_triggered_off", self, objective_color)
		#get_parent().check_win_condition()
	
func set_overlay_color(_color: Color) -> void:
	overlay.modulate = _color

func set_shader_intensity(intensity: float) -> void:
	overlay.material.set_shader_parameter("blink_intensity", intensity)

func set_shader_colors(albedo: Color, hl: Color) -> void:
	#overlay.material.set_shader_parameter("albedo_color", albedo)
	overlay.material.set_shader_parameter("blink_color", hl)

func play_blink_in() -> void:
	animation_player.play("blink")
	
func play_blink_out() -> void:
	animation_player.play("blink_out")

func darken(value: float) -> void:
	overlay.material.set_shader_parameter("multiply_intensity", value)

func set_objective(_color: Color) -> void:
	sprite.material.set_shader_parameter("albedo_color", _color)

func on_level_completed() -> void:
	set_shader_colors(Color.WHITE, Color.WHITE)

func is_correctly_activated() -> bool:
	return occupant != null and occupant.color_name == objective_color

func is_completed() -> bool:
	return completed
