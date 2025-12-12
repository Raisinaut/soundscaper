extends HBoxContainer

@export var channel_scene : PackedScene

@onready var new_channel = $NewChannel


func _ready() -> void:
	move_new_channel_to_end()
	new_channel.sound_added.connect(_on_new_channel_sound_added)

func load_configuration(configuration):
	clear_channels()
	for i in configuration:
		var channel : Channel = create_channel()
		await channel.ready
		channel.load_state(i)

func _on_new_channel_sound_added(file_path : String) -> void:
	var channel : Channel = create_channel()
	channel.audio_file_path = file_path

func create_channel() -> Channel:
	var inst : Channel = channel_scene.instantiate()
	call_deferred("add_child", inst)
	inst.ready.connect(move_new_channel_to_end)
	return inst

func clear_channels() -> void:
	for i in get_used_channels():
		i.queue_free()

func move_new_channel_to_end():
	move_child(new_channel, -1)

func get_used_channels() -> Array[Channel]:
	var channels : Array[Channel] = []
	for i in get_children():
		if i is Channel:
			channels.append(i)
	return channels

func get_used_channel_data() -> Array:
	var all_data : Array = []
	for c : Channel in get_used_channels():
		all_data.append(c.get_data())
	return all_data
