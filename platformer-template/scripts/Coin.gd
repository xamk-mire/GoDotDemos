extends Area2D

@export var value: int = 1


func _on_body_entered(body: Node) -> void:
	if body.name == "Player":
		Game.add_coin(value)
		queue_free()
