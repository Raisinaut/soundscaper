extends HBoxContainer

@export var audio_looper : AudioLooper

@onready var crossfade_button = $CrossfadeButton
@onready var shuffle_button = $ShuffleButton


func _ready() -> void:
	add_buttons_to_new_group()
	crossfade_button.pressed.connect(_on_crossfade_button_pressed)
	shuffle_button.pressed.connect(_on_shuffle_button_pressed)
	crossfade_button.set_button_pressed(true)

func add_buttons_to_new_group() -> void:
	var group = ButtonGroup.new()
	for i in get_children():
		i.button_group = group

func _on_crossfade_button_pressed() -> void:
	audio_looper.mode = AudioLooper.MODES.LOOP

func _on_shuffle_button_pressed() -> void:
	audio_looper.mode = AudioLooper.MODES.SHUFFLE
