extends RigidBody2D

@export var max_speed: float = 380.0
@export var kick_strength: float = 260.0


func _ready() -> void:
	sleeping = false # wake on start


func kick(from_position: Vector2, bonus: float = 1.0) -> void:
	var dir := (global_position - from_position).normalized()
	apply_impulse(dir * (kick_strength * bonus))


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Clamp velocity so it doesn't get uncontrollable
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
