class_name TileMarker

extends Node2D

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color= Globals.hl_colors[objective_color]
	set_objective(color)
	if is_objective:
		sprite.modulate = color
		sprite.visible = true
	else:
		sprite.visible = false
	overlay.visible = false
	blink.visible = false
	darken(0.0)
	Globals.level_completed.connect(on_level_completed)

func on_marker_enter(character: Character) -> void:
	set_shader_colors(character.character_color, character.hl_color)
	set_shader_intensity(1.0)
	overlay.visible = true
	if is_objective and character.color_name == objective_color:
		emit_signal("objective_triggered_on", self, objective_color)
	get_parent().check_win_condition()

func on_marker_exit() -> void:
	set_shader_intensity(0.0)
	#animation_player.play("step_off")
	overlay.visible = false
	if is_objective:
		emit_signal("objective_triggered_off", self, objective_color)

func set_overlay_color(_color: Color) -> void:
	overlay.modulate = _color

func set_shader_intensity(intensity: float) -> void:
	overlay.material.set_shader_parameter("blink_intensity", intensity)

func set_shader_colors(albedo: Color, hl: Color) -> void:
	overlay.material.set_shader_parameter("albedo_color", albedo)
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
