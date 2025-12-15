extends HBoxContainer

@export var channel_scene : PackedScene

@onready var new_channel = $NewChannel
@onready var channel_container = $ChannelContainer


func _ready() -> void:
	new_channel.sound_added.connect(_on_new_channel_sound_added)
	channel_container.child_order_changed.connect(_on_channel_container_child_order_changed)

func load_configuration(configuration):
	clear_channels()
	for i in configuration:
		var channel : Channel = create_channel()
		await channel.ready
		channel.load_state(i)

func _on_new_channel_sound_added(file_path : String) -> void:
	var channel : Channel = create_channel()
	channel.audio_file_path = file_path

func _on_channel_container_child_order_changed() -> void:
	var channel_count : int = channel_container.get_child_count()
	channel_container.visible = channel_count > 0

func create_channel() -> Channel:
	var inst : Channel = channel_scene.instantiate()
	channel_container.call_deferred("add_child", inst)
	return inst

func clear_channels() -> void:
	for i in channel_container.get_children():
		i.queue_free()

func get_used_channel_data() -> Array:
	var all_data : Array = []
	for c : Channel in channel_container.get_children():
		all_data.append(c.get_data())
	return all_data
