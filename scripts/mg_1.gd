extends Node

var box
var resource = preload("res://dialogue.dialogue")

func _ready() -> void:
	box = $box
	box.emptyBox.connect(change_level)
	var dialogue_line = await DialogueManager.show_dialogue_balloon(resource, 'level_1')

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
	var dialogue_line = await DialogueManager.show_dialogue_balloon(resource, 'level_1_end')
	await DialogueManager.dialogue_ended
	get_tree().change_scene_to_file("res://scenes/mg_2.tscn")
