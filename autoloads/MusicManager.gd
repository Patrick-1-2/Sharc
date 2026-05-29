extends Node

var music_player: AudioStreamPlayer

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.stream = preload("res://assets/YTDown_YouTube_1-hour-of-comfy-_-relaxing-songs-royalty_Media_TQvXEza4fPc_008_128k (online-audio-converter.com).ogg")
	music_player.autoplay = true
	music_player.bus = "Music"
	add_child(music_player)
	music_player.play()

func set_volume(value: float):
	music_player.volume_db = linear_to_db(value)
