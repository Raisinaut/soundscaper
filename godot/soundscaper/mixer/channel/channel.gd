class_name Channel
extends PanelContainer

@export var audio_stream : AudioStream

@onready var channel_label = %ChannelLabel
@onready var name_label = %NameLabel
@onready var volume_slider = %VolumeSlider
@onready var mute_button = %MuteButton
@onready var solo_button = %SoloButton
@onready var filter_control = %FilterControl
@onready var pitch_knob = %PitchKnob
@onready var pan_knob = %PanKnob
@onready var audio_player = $AudioLooper

var bus_name = ""


func _ready() -> void:
	# SETUP BUS
	AudioServer.add_bus()
	var bus_pos = AudioServer.bus_count - 1
	bus_name = str(get_channel_number())
	AudioServer.set_bus_name(bus_pos, bus_name)
	for effect in filter_control.get_effects():
		AudioServer.add_bus_effect(bus_pos, effect)
	audio_player.bus = bus_name
	
	# SYNC WITH EXPORTS
	audio_player.stream = audio_stream
	
	# UPDATE LABELS
	channel_label.text = "CH " + str(get_channel_number())
	update_name_label()
	
	# CONNECT SIGNALS
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	mute_button.toggled.connect(_on_mute_button_toggled)
	pitch_knob.turned.connect(_on_pitch_knob_turned)
	pan_knob.turned.connect(_on_pan_knob_turned)
	solo_button.toggled.connect(_on_solo_button_toggled)
	
	# PLAY AUDIO
	audio_player.play()

func set_name_label(text : String) -> void:
	name_label.text = text

func update_name_label() -> void:
	if audio_stream:
		name_label.text = get_audio_filename()
	else:
		name_label.text = "sound"

func get_audio_filename(trim_extension := true) -> String:
	#print(audio_stream)
	var file_path : String = audio_stream.resource_path
	var file_name : String = file_path.split("/")[-1]
	if trim_extension:
		file_name = file_name.split(".")[0]
	return file_name


# SIGNALS ----------------------------------------------------------------------
func _on_volume_slider_value_changed(value : float):
	AudioServer.set_bus_volume_db(get_bus_idx(), value)

func _on_mute_button_toggled(state : bool) -> void:
	AudioServer.set_bus_mute(get_bus_idx(), state)

func _on_solo_button_toggled(state : bool) -> void:
	AudioServer.set_bus_solo(get_bus_idx(), state)

func _on_pitch_knob_turned(turn_amount : float) -> void:
	var pitch_scale = pow(2, turn_amount)
	audio_player.pitch_scale = pitch_scale

func _on_pan_knob_turned(turn_amount : float) -> void:
	audio_player.set_pan(turn_amount)


# SETTERS ----------------------------------------------------------------------
#func set_audio_stream(value : AudioStream) -> void:
	#audio_stream = value
	#audio_player.stream = audio_stream
	#update_name_label()


# GETTERS ----------------------------------------------------------------------
func get_bus_idx() -> int:
	return AudioServer.get_bus_index(bus_name)

func get_channel_number() -> int:
	return get_bus_idx()


# CALCULATIONS -----------------------------------------------------------------
func calculate_pitch_scale(semitones : float) -> float:
	return pow(2, (semitones / 12.0))
