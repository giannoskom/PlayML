extends Node

var processed_dataset : Array = []

func _ready():
	SignalManager.correct_box.connect(sorted_picture)
func save_photo_to_pipeline(texture_path: String, animal_type: String, is_negative: bool, dirty_percentage: float, dust_positions: Array):
	
	var data_entry = {
		"texture": texture_path,
		"type": animal_type,
		"is_negative": is_negative,
		"dirty_percentage": dirty_percentage,
		"dust_positions": dust_positions
	}
	
	processed_dataset.append(data_entry)
	print("Νέα εγγραφή στο pipeline! ", animal_type, " Συνολικές φωτογραφίες: ", processed_dataset.size())
	print(dirty_percentage, "% dirty")
	print(dust_positions.size())

func get_dataset() -> Array:
	return processed_dataset

func clear_dataset():
	processed_dataset.clear()

func sorted_picture(box_ref, texture_path, type):
	var is_correct = box_ref == type
	
	for entry in processed_dataset:
		if entry["texture"] == texture_path:
			entry["assigned_box"] = box_ref
			entry["is_label_correct"] = is_correct
			break
