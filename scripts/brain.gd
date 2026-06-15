extends Node

# --- 1. SUPERVISED LEARNING DATA ---
# Αποθηκεύει πόσες σωστές/λάθος εκπαιδεύσεις έγιναν για κάθε κατηγορία
var supervised_memory = {
	"dog": {"weight": 0.0, "examples": 0},
	"cat": {"weight": 0.0, "examples": 0},
	"bird": {"weight": 0.0, "examples": 0}
}

# Ο συντελεστής ποιότητας από το Level 1 (0.0 έως 1.0)
var data_quality = 1.0 

# --- 2. REINFORCEMENT LEARNING DATA ---
# Ένα Dictionary που αντιστοιχίζει συντεταγμένες (Vector2) με "αξία" (float)
# π.χ. {Vector2(1,2): 0.5}
var policy_map = {}

# --- 3. FUNCTIONS ΓΙΑ SUPERVISED (Levels 1-3) ---

# Συνάρτηση που "εκπαιδεύει" το Pet
func train(label: String, quality_score: float):
	if supervised_memory.has(label):
		supervised_memory[label].examples += 1
		# Το βάρος αυξάνεται ανάλογα με το πόσο καλά καθαρίστηκε η εικόνα
		supervised_memory[label].weight += quality_score
		print("Brain: Trained ", label, " with quality ", quality_score)

# Συνάρτηση "Πρόβλεψης" (Inference) για το Level 3
func predict(image_label: String) -> Dictionary:
	var confidence = 0.0
	if supervised_memory.has(image_label):
		var mem = supervised_memory[image_label]
		if mem.examples > 0:
			# Απλός τύπος: Μέσος όρος ποιότητας / max_possible
			confidence = clamp(mem.weight / mem.examples, 0.1, 1.0)
	
	# Προσθέτουμε λίγο "θόρυβο" αν το data_quality είναι χαμηλό
	confidence *= (0.5 + (data_quality * 0.5))
	
	return {"label": image_label, "confidence": confidence}

# --- 4. FUNCTIONS ΓΙΑ REINFORCEMENT (Level 4) ---

func update_policy(pos: Vector2, reward: float):
	if not policy_map.has(pos):
		policy_map[pos] = 0.0
	
	# Learning Rate (σταθερό για το simulation)
	var lr = 0.2
	policy_map[pos] += lr * (reward - policy_map[pos])

func get_best_move(current_pos: Vector2, neighbors: Array) -> Vector2:
	var best_pos = neighbors.pick_random() # Default τυχαία κίνηση
	var max_val = -999.0
	
	for n in neighbors:
		var val = policy_map.get(n, 0.0)
		if val > max_val:
			max_val = val
			best_pos = n
	return best_pos
