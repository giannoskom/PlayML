extends Control

@onready var chart: Control = $paper/VBoxContainer/HBoxContainer/chart
@onready var pet: TextureRect = $paper/VBoxContainer/HBoxContainer/pet
@onready var notes: RichTextLabel = $paper/VBoxContainer/notes
var resource = load("res://dialogue.dialogue")



var results

func _ready() -> void:
	results = PipelineManager.pie_data.duplicate()
	display_report(results)
	DialogueManager.show_dialogue_balloon(resource, "report_remarks")

func display_report(results: Dictionary):
	chart.set_data(results["class_scores"])
	pet.texture = load(PipelineManager.pet_texture)
	var stats_text = generate_stats_text(results)
	var text_data = generate_report_text(results)
	var final_report = "\n\n\n\n\n\n\n\n\n[color=#222222]" + stats_text + "\n" + text_data["comments"] + "\n\n" + text_data["suggestions"]
	notes.text = final_report
	
func generate_report_text(results: Dictionary) -> Dictionary:
	var global_score = results["global_score"]
	var class_scores = results["class_scores"]
	var dominant = results["dominant_class"].to_upper()
	
	# Βρίσκουμε την πιο αδύναμη κλάση
	var weakest = ""
	var lowest_score = 101.0
	for c in class_scores.keys():
		if class_scores[c] < lowest_score:
			lowest_score = class_scores[c]
			weakest = c.to_upper()
			
	# Υπολογίζουμε τη διαφορά μεταξύ της καλύτερης και της χειρότερης κλάσης (για το Bias)
	var max_score = class_scores[results["dominant_class"]]
	var score_difference = max_score - lowest_score

	var comments = ""
	var suggestions = ""


	if global_score < 40.0:
		comments = "TRAINING FAILED. THE PROVIDED DATA WAS INSUFFICIENT, HEAVILY DAMAGED, OR COMPLETELY MISCLASSIFIED."
		suggestions = "START OVER. COLLECT ENOUGH CLEAN PHOTOS FOR EACH ANIMAL AND MAKE SURE TO PLACE THEM IN THE CORRECT BOXES!"
		

	elif lowest_score < 20.0:
		comments = "THE PET LEARNED SOME THINGS, BUT IT ALMOST COMPLETELY IGNORES THE " + weakest + " CLASS DUE TO LACK OF GOOD DATA."
		suggestions = "DON'T NEGLECT ANY CATEGORY! THE MODEL NEEDS CLEAN AND SUFFICIENT EXAMPLES FOR THE " + weakest + " CLASS TO UNDERSTAND IT."


	elif global_score >= 40.0 and global_score < 70.0 and score_difference <= 30.0:
		comments = "THE MODEL IS CONFUSED. IT SEEMS TOO MANY DIRTY PHOTOS OR INCORRECT EXAMPLES WERE USED DURING TRAINING."
		suggestions = "FOCUS ON DATA QUALITY. ALWAYS CLEAN THE PICTURES BEFORE FEEDING THEM TO THE SYSTEM TO IMPROVE ACCURACY."


	elif score_difference > 30.0:
		comments = "THE PET HAS BEEN TRAINED WELL, BUT ITS CONFIDENCE IN THE " + dominant + " CLASS IS DISPROPORTIONATELY HIGH. IT WILL LEAN TOWARDS " + dominant + " WHEN UNSURE."
		suggestions = "NEXT TIME, TRY COLLECTING AN EQUAL AMOUNT OF PHOTOS FOR ALL ANIMALS TO AVOID BIAS AND CREATE A BALANCED DIGITAL BRAIN."

	else:
		comments = "THE PET HAS BEEN TRAINED FLAWLESSLY! THE DATA WAS CLEAN, ACCURATE, AND PERFECTLY BALANCED ACROSS ALL CLASSES."
		suggestions = "KEEP IT UP! THE DIGITAL BRAIN CAN NOW CONFIDENTLY RECOGNIZE ANY ANIMAL WITHOUT ANY BIAS."

	return {
		"comments": "-[b] COMMENTS[/b]:\n- " + comments,
		"suggestions": "- [b]FUTURE SUGGESTIONS[/b]:\n- " + suggestions
	}
	
func generate_stats_text(results: Dictionary) -> String:
	var global_score = results["global_score"]
	var class_scores = results["class_scores"]
	
	var text = "• [b]GLOBAL SCORE[/b]: " + str(snapped(global_score, 0.1)) + "%\n"
	
	var eval_text = ""
	if global_score >= 80.0:
		eval_text = "SUCCESSFULLY RECOGNISES ALL CLASSES"
	elif global_score >= 40.0:
		eval_text = "RECOGNISES CLASSES BUT CAN BE EASILY CONFUSED"
	else:
		eval_text = "FAILS TO RECOGNISE MOST CLASSES"
		
	text += "• [b]PET EVALUATION[/b]: " + eval_text + "\n"
	
	var total_score = 0.0
	for val in class_scores.values():
		total_score += val
		
	var confidences = []
	for c_name in class_scores.keys():
		var conf = 0.0
		if total_score > 0:
			conf = (class_scores[c_name] / total_score) * 100.0
		confidences.append(c_name.to_upper() + "S (" + str(snapped(conf, 0.1)) + "%)")
	
	text += "• [b]CONFIDENCE PER CLASS[/b]: " + ", ".join(confidences) + ".\n\n"
	
	for c_name in class_scores.keys():
		var quality = class_scores[c_name]
		text += "• QUALITY OF " + c_name.to_upper() + " CLASS DATA: " + str(snapped(quality, 0.1)) + "%\n"
		
	return text
