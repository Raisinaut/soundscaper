class_name AutoScrollContainer
extends ScrollContainer

var scroll_tween : Tween = null


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)


# ACTIONS ----------------------------------------------------------------------
func animate_full_scroll():
	var max_scroll = get_actual_max_scroll()
	var duration = max_scroll * 0.025
	scroll_tween = create_tween()
	scroll_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	scroll_tween.tween_property(self, "scroll_horizontal", max_scroll, duration / 2)
	scroll_tween.tween_property(self, "scroll_horizontal", 0, duration / 2)


# SIGNALS ----------------------------------------------------------------------
func _on_mouse_entered():
	if not is_scrolling():
		animate_full_scroll()


# CHECKS -----------------------------------------------------------------------
func is_scrolling() -> bool:
	return scroll_tween and scroll_tween.is_running()


# CALCULCATIONS ----------------------------------------------------------------
## Tests for the actual maximum value which theoritically accounts for the grabber.
func get_actual_max_scroll() -> int:
	var s_max : int = 0
	var original : int = scroll_horizontal
	scroll_horizontal = int(get_h_scroll_bar().max_value)
	s_max = scroll_horizontal
	scroll_horizontal = original
	return s_max
