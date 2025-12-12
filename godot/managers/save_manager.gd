extends Node


func save_data(data : Variant, path : String) -> void:
	_save_to_file(JSON.stringify(data, "\t"), path)

func load_data(file_path : String) -> Variant:
	var content = _load_from_file(file_path)
	var json_parse = JSON.parse_string(content)
	return json_parse

func _save_to_file(content : String, path : String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)

func _load_from_file(file_path : String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	return content
