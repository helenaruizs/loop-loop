extends Node

@onready var track_1: AudioStreamPlayer = $Track1
@onready var track_2: AudioStreamPlayer = $Track2
@onready var track_3: AudioStreamPlayer = $Track3
@onready var track_4: AudioStreamPlayer = $Track4
@onready var music: AudioStreamPlayer = $Music


func get_audio() -> Array[AudioStreamPlayer]:
	return [track_1, track_2, track_3, track_4, music]
