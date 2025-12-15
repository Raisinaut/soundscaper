class_name Channel
extends HoverPanelContainer

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
var audio_file_path : String = "" : set = set_audio_file_path
var audio_stream : AudioStream : set = set_audio_stream


func _ready() -> void:
	super()
	connect_signals()
	setup_bus()
	update_channel_label()

func connect_signals() -> void:
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	mute_button.toggled.connect(_on_mute_button_toggled)
	pitch_knob.turned.connect(_on_pitch_knob_turned)
	pan_knob.turned.connect(_on_pan_knob_turned)
	solo_button.toggled.connect(_on_solo_button_toggled)

func setup_bus() -> void:
	AudioServer.add_bus()
	var bus_pos = AudioServer.bus_count - 1
	bus_name = generate_bus_name()
	AudioServer.set_bus_name(bus_pos, bus_name)
	for effect in filter_control.get_effects():
		AudioServer.add_bus_effect(bus_pos, effect)
	audio_player.bus = bus_name

func update_channel_label() -> void:
	channel_label.text = "CH " + str(get_channel_number())

func update_name_label() -> void:
	if audio_file_path:
		name_label.text = get_filename(audio_file_path)
	else:
		name_label.text = "sound"

func get_audio_filename(trim_extension := true) -> String:
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
func set_audio_stream(value : AudioStream) -> void:
	audio_stream = value
	if not $AudioLooper.is_node_ready():
		await $AudioLooper.ready
	$AudioLooper.stream = audio_stream
	$AudioLooper.play()
	# Name label default overridden by load_state
	%NameLabel.text = get_filename(audio_file_path)

func set_audio_file_path(value : String) -> void:
	audio_file_path = value
	audio_stream = load_audio(audio_file_path)


# GETTERS ----------------------------------------------------------------------
func get_bus_idx() -> int:
	return AudioServer.get_bus_index(bus_name)

func get_channel_number() -> int:
	return get_bus_idx()


# UTILITY ----------------------------------------------------------------------
func calculate_pitch_scale(semitones : float) -> float:
	return pow(2, (semitones / 12.0))

func generate_bus_name() -> String:
	return str(get_instance_id())

## Retrieves a string before any extension and after the last /
func get_filename(file_path : String, trim_extension := true) -> String:
	var file_name : String = file_path.split("/")[-1]
	if trim_extension:
		file_name = file_name.split(".")[0]
	return file_name


# DATA MANAGEMENT --------------------------------------------------------------
func get_data() -> Dictionary:
	var data = {
		"audio_file_path" = audio_file_path,
		"name_label" = name_label.text,
		"volume" = volume_slider.get_value(),
		"mute" = mute_button.button_pressed,
		"solo" = solo_button.button_pressed,
		"filter_lowpass" = filter_control.low_pass_knob.get_turn_position(),
		"filter_highpass" = filter_control.high_pass_knob.get_turn_position(),
		"pitch" = pitch_knob.get_turn_position(),
		"pan" = pan_knob.get_turn_position()
	}
	return data

func load_state(data : Dictionary) -> void:
	audio_file_path = data["audio_file_path"]
	name_label.text = data["name_label"] # override default name
	volume_slider.set_value(data["volume"])
	mute_button.button_pressed = data["mute"]
	solo_button.button_pressed = data["solo"]
	filter_control.low_pass_knob.turn_to(data["filter_lowpass"])
	filter_control.high_pass_knob.turn_to(data["filter_highpass"])
	pitch_knob.turn_to(data["pitch"])
	pan_knob.turn_to(data["pan"])

## Loads audio as its corresponding AudioStream type.
func load_audio(path : String):
	var audio = null
	var extension = path.split(".")[-1]
	match extension:
		"wav":
			audio = AudioStreamWAV.load_from_file(path)
		"ogg":
			audio = AudioStreamOggVorbis.load_from_file(path)
		"mp3":
			audio = AudioStreamMP3.load_from_file(path)
	return audio
