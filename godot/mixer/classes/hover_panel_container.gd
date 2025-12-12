class_name HoverPanelContainer
extends PanelContainer

var hover_detection : Button = null
var mouse_in_window : bool = false
var brightness_tween : Tween


func _ready() -> void:
	setup_hover_detection()

func _process(_delta: float) -> void:
	sync_color_with_hover()

func setup_hover_detection() -> void:
	hover_detection = Button.new()
	var style_box = StyleBoxEmpty.new()
	hover_detection.add_theme_stylebox_override("disabled", style_box)
	hover_detection.disabled = true
	hover_detection.mouse_filter = Button.MOUSE_FILTER_IGNORE
	call_deferred_thread_group("add_child", hover_detection)


# CHECKS -----------------------------------------------------------------------
# Tracks mouse focus
func _notification(what: int) -> void:
	match(what):
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false

## Checks if the mouse is hovering over the specified area
func is_hovered() -> bool:
	if not hover_detection:
		return false
	var hover_rect = Rect2(hover_detection.position, hover_detection.size)
	var mouse_pos = get_local_mouse_position()
	return hover_rect.has_point(mouse_pos)

## Darkens the root node when hover is active
func sync_color_with_hover():
	if is_hovered() and mouse_in_window:
		tween_brightness(1.1)
	else:
		tween_brightness(1.0)

func tween_brightness(brightness : float):
	var c = Color.BLACK.lightened(brightness)
	brightness_tween = create_tween()
	brightness_tween.tween_property(self, "self_modulate", c, 0.1)
