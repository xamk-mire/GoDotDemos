extends Area2D

var _activated := false


func _on_body_entered(body: Node) -> void:
	if not _activated and body.name == "Player":
		_activated = true
		Game.set_spawn(global_position)
		modulate = Color(0.6, 1.0, 0.6) # simple visual feedback
