extends Node

var box

func _ready() -> void:
	box = $box
	box.emptyBox.connect(change_level)
	
func _input(event):

	if event is InputEventKey and event.pressed:
		

		if event.keycode == KEY_1:
			DialogueManager.show_dialogue_balloon(load("res://dialogue.dialogue"), "cleanup_intro")

		elif event.keycode == KEY_2:
			DialogueManager.show_dialogue_balloon(load("res://dialogue.dialogue"), "cleanup_warning")
			
		elif event.keycode == KEY_3:
			DialogueManager.show_dialogue_balloon(load("res://dialogue.dialogue"), "cleanup_success")

func _on_save_pic_area_entered(area: Area2D) -> void:
	if area.is_in_group('pic_area'):
		var picture = area.get_parent()
		picture.is_in_save_zone = true



func _on_save_pic_area_exited(area: Area2D) -> void:
	if area.is_in_group('pic_area'):
		var picture = area.get_parent()
		picture.is_in_save_zone = false


func _on_negative_area_area_entered(area: Area2D) -> void:
	if area.is_in_group('pic_area'):
		var picture = area.get_parent()
		picture.is_in_neg_machine = true


func _on_negative_area_area_exited(area: Area2D) -> void:
	if area.is_in_group('pic_area'):
		var picture = area.get_parent()
		picture.is_in_neg_machine = false



func _on_trash_area_area_entered(area: Area2D) -> void:
	if area.is_in_group('pic_area'):
		var picture = area.get_parent()
		picture.is_in_trashcan = true


func _on_trash_area_area_exited(area: Area2D) -> void:
	if area.is_in_group('pic_area'):
		var picture = area.get_parent()
		picture.is_in_trashcan = false
		
func change_level():
	get_tree().change_scene_to_file("res://scenes/mg_2.tscn")
