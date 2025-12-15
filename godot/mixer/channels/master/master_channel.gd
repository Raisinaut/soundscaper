extends HoverPanelContainer

@onready var channel_label = %ChannelLabel
@onready var name_label = %NameLabel
@onready var volume_slider = %VolumeSlider

var bus_name = "Master"


func _ready() -> void:
	super()
	# CONNECT SIGNALS
	volume_slider.value_changed.connect(_on_volume_slider_value_changed)


# SIGNALS ----------------------------------------------------------------------
func _on_volume_slider_value_changed(value : float):
	AudioServer.set_bus_volume_db(get_bus_idx(), value)


# GETTERS ----------------------------------------------------------------------
func get_bus_idx() -> int:
	return AudioServer.get_bus_index(bus_name)


# CALCULATIONS -----------------------------------------------------------------
func calculate_pitch_scale(semitones : float) -> float:
	return pow(2, (semitones / 12.0))
