class_name TileMarker

extends Node2D

@onready var overlay: Sprite2D = $Overlay
@onready var area_2d: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var is_objective: bool = false
@export var objective_color : Globals.ColorNames

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color: Color = Globals.hl_colors[objective_color]
	set_objective(color)
	if is_objective:
		sprite.modulate = color
		sprite.visible = true
	else:
		sprite.visible = false
	overlay.visible = false
	darken(0.0)

func on_marker_enter(character: Character) -> void:
	set_shader_colors(character.character_color, character.hl_color)
	set_shader_intensity(1.0)
	overlay.visible = true


func on_marker_exit() -> void:
	set_shader_intensity(0.0)
	#animation_player.play("step_off")
	overlay.visible = false

func set_overlay_color(_color: Color) -> void:
	overlay.modulate = _color

func set_shader_intensity(intensity: float) -> void:
	overlay.material.set_shader_parameter("blink_intensity", intensity)

func set_shader_colors(albedo: Color, hl: Color) -> void:
	overlay.material.set_shader_parameter("albedo_color", albedo)
	overlay.material.set_shader_parameter("blink_color", hl)


func darken(value: float) -> void:
	overlay.material.set_shader_parameter("multiply_intensity", value)

func set_objective(_color: Color) -> void:
	sprite.material.set_shader_parameter("albedo_color", _color)
