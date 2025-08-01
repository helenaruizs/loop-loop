class_name TileMarker

extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.visible = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	animation_player.play("step_on")
	sprite.visible = true


func _on_area_2d_area_exited(area: Area2D) -> void:
	animation_player.play("step_off")
	sprite.visible = false
