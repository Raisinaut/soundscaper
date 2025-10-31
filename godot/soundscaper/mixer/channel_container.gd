extends HBoxContainer

@export var channel_scene : PackedScene

@onready var new_channel = $NewChannel


func _ready() -> void:
	move_new_channel_to_end()
	new_channel.sound_added.connect(_on_new_channel_sound_added)


func _on_new_channel_sound_added(sound, filename : String) -> void:
	var inst : Channel = channel_scene.instantiate()
	inst.audio_stream = sound
	call_deferred("add_child", inst)
	await inst.ready
	inst.set_name_label(filename)
	move_new_channel_to_end()


func move_new_channel_to_end():
	move_child(new_channel, -1)
