class_name TileMarker

extends Node2D

@onready var overlay: Sprite2D = $Overlay
@onready var area_2d: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.visible = false


func on_marker_enter(_color: Color) -> void:
	set_overlay_color(_color)
	overlay.visible = true
	animation_player.play("step_on")
	sprite.visible = true


func on_marker_exit() -> void:
	animation_player.play("step_off")
	overlay.visible = false
	sprite.visible = false

func set_overlay_color(_color: Color) -> void:
	overlay.modulate = _color
