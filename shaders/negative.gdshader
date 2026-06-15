shader_type canvas_item;

void fragment() {
	// Διαβάζουμε το χρώμα του κάθε pixel της φωτογραφίας
	vec4 current_color = texture(TEXTURE, UV);
	
	// Αφαιρούμε το χρώμα από το 1.0 (το λευκό) για να βρούμε το αντίθετό του (Αρνητικό)
	current_color.rgb = vec3(1.0) - current_color.rgb;
	
	// Το εφαρμόζουμε στην οθόνη
	COLOR = current_color;
}