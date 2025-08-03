extends Control
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Title screen ready!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	Globals.start_game.emit()

#
#func _on_timer_timeout() -> void:
	#audio_stream_player.bus.
	#
	#var min_cutoff := 2000.0
	#var max_cutoff := 4500.0
	#var cutoff : float= lerp(min_cutoff, max_cutoff, norm_y)
## Apply to audio effect if it's valid
	##if filter_effect_phaser:
		##filter_effect_phaser.set("depth", depth)


func _on_quit_pressed() -> void:
	Globals.quit_game.emit()
