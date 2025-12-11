extends Node2D

@export var stream : AudioStream : set = set_stream
@export var fade_duration : float = 3.0

@onready var track_a = $TrackA
@onready var track_b = $TrackB

var pitch_scale : float = 1.0 : set = set_pitch_scale
var bus : String = "" : set = set_bus
var pan : float = 0.0 : set = set_pan

var fade_timer : SceneTreeTimer
var fade_in_tween : Tween
var fade_out_tween : Tween
var last_played_track : AudioStreamPlayer2D = null


func _ready() -> void:
	track_a.finished.connect(_on_track_finished)
	track_b.finished.connect(_on_track_finished)

func play(track : AudioStreamPlayer2D = track_a):
	track.play()
	last_played_track = track
	start_fade_timer()

func start_fade_timer():
	var playback_position = last_played_track.get_playback_position()
	var transition_position = stream.get_length() - fade_duration - playback_position
	fade_timer = get_tree().create_timer(transition_position)
	fade_timer.timeout.connect(_on_fade_timer_timeout)

# SETTERS ----------------------------------------------------------------------
func set_stream(value : AudioStream) -> void:
	stream = value
	track_a.stream = stream
	track_b.stream = stream
	# limit fade length to half stream length
	fade_duration = min(fade_duration, stream.get_length() * 0.5)

func set_pitch_scale(value) -> void:
	pitch_scale = value
	track_a.pitch_scale = pitch_scale
	track_b.pitch_scale = pitch_scale

func set_bus(value : String) -> void:
	bus = value
	track_a.bus = bus
	track_b.bus = bus

func set_pan(value : float) -> void:
	pan = value
	track_a.pan = pan
	track_b.pan = pan


# SIGNALS ----------------------------------------------------------------------
## When one track reaches the fade out time, play the other.
func _on_fade_timer_timeout() -> void:
	if last_played_track == track_a:
		fade_out_track(track_a)
		play(track_b)
		fade_in_track(track_b)
	else:
		fade_out_track(track_b)
		play(track_a)
		fade_in_track(track_a)

func _on_track_finished() -> void:
	if not (track_a.playing and track_b.playing):
		track_a.play()


# TRANSITIONS ------------------------------------------------------------------
func fade_out_track(track):
	fade_out_tween = create_tween()
	fade_out_tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CIRC)
	fade_out_tween.tween_property(track, "volume_db", -35, fade_duration)

func fade_in_track(track):
	track.volume_db = -35
	fade_in_tween = create_tween()
	fade_in_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	fade_in_tween.tween_property(track, "volume_db", 0.0, fade_duration)
