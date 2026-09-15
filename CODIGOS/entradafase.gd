extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer


func _ready():
	video.finished.connect(_video_terminou)
	video.play()


func _video_terminou():
	get_tree().change_scene_to_file(
		"res://CENAS/infofase.tscn"
	)
