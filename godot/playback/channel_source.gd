class_name ChannelSource
extends AudioStreamPlayer2D

@onready var max_x_position = get_viewport_rect().size.x

var pan : float = 0.0 : set = set_pan


func _ready() -> void:
	max_distance = max_x_position
	panning_strength = 3.0
	position.x = max_x_position / 2

func set_pan(amount):
	pan = amount
	position.x = remap(pan, -1, 1, 0, max_x_position)
