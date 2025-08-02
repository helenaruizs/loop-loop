extends Control

@onready var scrim: ColorRect = $ColorRect
@onready var anim: AnimationPlayer = $AnimationPlayer

func _play_wipe_out() -> void:
	scrim.visible = true
	anim.play("wipe_out")
