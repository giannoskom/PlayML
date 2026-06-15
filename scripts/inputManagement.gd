extends Node



func _ready() -> void:
	var resource = preload("res://dialogue.dialogue")
	var dialogue_line = await DialogueManager.show_dialogue_balloon(resource, 'start')



func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		var screen_height = get_viewport().get_visible_rect().size.y

		if event.position.y < screen_height * 0.7:
			print("ΠΑΝΩ ΜΕΡΟΣ - gameplay tap")
			get_tree().change_scene_to_file("res://scenes/mg_1.tscn")
		else:
			print("ΚΑΤΩ ΜΕΡΟΣ - UI tap")
			get_tree().change_scene_to_file("res://scenes/mg_1.tscn")
