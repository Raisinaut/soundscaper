class_name AudioLooper
extends Node2D

@export var stream : AudioStream : set = set_stream
@export var fade_duration : float = 3.0

@onready var track_a = $TrackA
@onready var track_b = $TrackB

var pitch_scale : float = 1.0 : set = set_pitch_scale
var bus : String = "" : set = set_bus
var pan : float = 0.0 : set = set_pan

enum MODES {LOOP, SHUFFLE}
var mode = MODES.LOOP : set = set_mode

# SHUFFLE
var shuffle_timer : SceneTreeTimer
var interval_time : float = 0.5 : set = set_interval_time
var occurence_per_interval : int = 1 : set = set_occurence_per_interval
var interval_variation : float = 0.1

# LOOP
var fade_timer : SceneTreeTimer
var fade_in_tween : Tween
var fade_out_tween : Tween
var last_played_track : AudioStreamPlayer2D = null


func _ready() -> void:
	track_a.finished.connect(_on_track_finished)
	track_b.finished.connect(_on_track_finished)

func play() -> void:
	stop_all_tracks() # ensure neither track is playing in case the mode changed
	match(mode):
		MODES.LOOP:
			if shuffle_timer: 
				shuffle_timer.timeout.disconnect(_on_shuffle_timer_timeout)
			play_loop()
		MODES.SHUFFLE:
			if fade_timer: 
				fade_timer.timeout.disconnect(_on_fade_timer_timeout)
			play_shuffle()

func play_loop(track : AudioStreamPlayer2D = track_a):
	track.play()
	last_played_track = track
	start_fade_timer()

func play_shuffle() -> void:
	track_a.play()
	last_played_track = track_a
	start_shuffle_timer()

func stop_all_tracks() -> void:
	track_a.stop()
	track_b.stop()

func start_shuffle_timer() -> void:
	var duration = interval_time / occurence_per_interval
	var variation = randf_range(-interval_variation, interval_variation)
	duration = max(duration + variation, 0)
	shuffle_timer = get_tree().create_timer(duration)
	shuffle_timer.timeout.connect(_on_shuffle_timer_timeout)

func start_fade_timer() -> void:
	var playback_position = last_played_track.get_playback_position()
	var transition_position = stream.get_length() - fade_duration - playback_position
	fade_timer = get_tree().create_timer(transition_position)
	fade_timer.timeout.connect(_on_fade_timer_timeout)


# SETTERS ----------------------------------------------------------------------
func set_mode(value : MODES) -> void:
	mode = value
	play()

## Retrigger shuffle play when times are modified in that mode
func set_interval_time(value : float) -> void:
	interval_time = value
	if mode == MODES.SHUFFLE:
		play()

## Retrigger shuffle play when times are modified in that mode
func set_occurence_per_interval(value : int) -> void:
	occurence_per_interval = value
	if mode == MODES.SHUFFLE:
		play()

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
	if mode != MODES.SHUFFLE:
		return
	if last_played_track == track_a:
		fade_out_track(track_a)
		play_loop(track_b)
		fade_in_track(track_b)
	else:
		fade_out_track(track_b)
		play_loop(track_a)
		fade_in_track(track_a)

func _on_track_finished() -> void:
	if not (track_a.playing and track_b.playing):
		track_a.play()

func _on_shuffle_timer_timeout() -> void:
	play_shuffle()


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
