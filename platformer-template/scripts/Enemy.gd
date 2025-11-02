extends CharacterBody2D

@export var left_edge: float = -64.0
@export var right_edge: float = 64.0
@export var speed: float = 80.0

var _dir := 1


func _physics_process(delta: float) -> void:
	velocity.x = _dir * speed
	move_and_slide()

	# Flip at patrol edges (local)
	var local_x := position.x
	if local_x > right_edge:
		_dir = -1
	elif local_x < left_edge:
		_dir = 1


func _on_Area2D_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.has_method("take_damage"):
		# Simple stomp mechanic: if player is falling, kill enemy; else damage player.
		var p := body as CharacterBody2D
		if p.velocity.y > 0.0:
			queue_free()
			p.velocity.y = -min(280.0, abs(p.velocity.y)) # bounce
		else:
			body.take_damage()
