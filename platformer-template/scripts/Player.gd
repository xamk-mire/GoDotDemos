extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_zone: Area2D = $InteractZone
@onready var hold_socket: Node2D = $HoldSocket

@export var speed := 220.0
@export var jump_force := 500.0
@export var gravity := 1000.0
@export var invuln_time := 0.8

# Carry / interact settings
@export var kick_strength := 360.0
@export var carry_disable_collisions := true # safer when holding
@export var ball_layer_when_free := 3 # your ball layer

@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1
@export var push_strength := 220.0

var carried_ball: RigidBody2D = null
var _saved_layer := 0
var _saved_mask := 0
var _saved_gravity := 1.0
var _facing := 1 # 1 = right, -1 = left

var _invuln := false


func _ready() -> void:
	Game.player_respawn.connect(_on_player_respawn)


func _physics_process(delta: float) -> void:
	# Horizontal
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed
	# Flip sprite
	if dir != 0:
		_facing = sign(dir)
		sprite.scale.x = _facing # flip sprite

		# Flip interact zone & hold socket
		interact_zone.position.x = abs(interact_zone.position.x) * _facing
		hold_socket.position.x = abs(hold_socket.position.x) * _facing

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Track coyote time and jump buffer
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

	if Input.is_action_just_pressed("interact"):
		_on_interact_pressed()

	_push_rigid_bodies()


func _on_interact_pressed() -> void:
	if carried_ball:
		# Kick / drop
		_kick_carried_ball()
	else:
		# Try to pick up
		var b := _find_nearby_ball()
		if b:
			_pickup_ball(b)


func _find_nearby_ball() -> RigidBody2D:
	for body in interact_zone.get_overlapping_bodies():
		if body is RigidBody2D and (body.is_in_group("ball") or body.has_method("apply_impulse")):
			return body
	return null


func _pickup_ball(ball: RigidBody2D) -> void:
	carried_ball = ball
	# Save current physics config to restore on drop
	_saved_layer = ball.collision_layer
	_saved_mask = ball.collision_mask
	_saved_gravity = ball.gravity_scale

	# Freeze physics and attach to player
	ball.sleeping = false
	ball.freeze = true
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.gravity_scale = 0.0

	# Disable ball collisions while carried (prevents jitter)
	if carry_disable_collisions:
		ball.set_deferred("collision_layer", 0)
		ball.set_deferred("collision_mask", 0)

	# Reparent so it "sticks" to the player
	var level := ball.get_parent()
	ball.set_deferred("global_position", hold_socket.global_position)
	await get_tree().process_frame
	ball.reparent(self)
	ball.position = hold_socket.position # local to player


func _kick_carried_ball() -> void:
	if not carried_ball:
		return

	# Detach and restore physics/collisions
	var ball := carried_ball
	carried_ball = null

	# Reparent to level (assumes Player is inside the Level node; adjust if needed)
	var level := get_parent()
	ball.reparent(level)
	ball.global_position = hold_socket.global_position

	# Restore collisions & gravity
	if carry_disable_collisions:
		ball.collision_layer = _saved_layer
		ball.collision_mask = _saved_mask
	ball.gravity_scale = _saved_gravity

	# Unfreeze and kick
	ball.freeze = false
	ball.sleeping = false

	var dir := Vector2(_facing, -0.2).normalized() # slight upward kick
	ball.apply_impulse(dir * kick_strength)

	# Optional: small cooldown so the player doesn't immediately re-catch it
	await get_tree().create_timer(0.12).timeout


func _push_rigid_bodies() -> void:
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var rb := col.get_collider()
		if rb is RigidBody2D:
			var dir := velocity
			if dir.length() < 1.0:
				dir = -col.get_normal() * 120.0 # gentle nudge if standing
			rb.apply_impulse(dir.normalized() * push_strength)
			rb.sleeping = false


func take_damage() -> void:
	if _invuln:
		return
	_invuln = true
	Game.damage_player()
	flash_invuln()


func flash_invuln() -> void:
	# simple blink; non-blocking
	var t := create_tween().set_loops(6)
	t.tween_property(sprite, "modulate:a", 0.2, 0.06).from(1.0)
	t.tween_property(sprite, "modulate:a", 1.0, 0.06)
	await get_tree().create_timer(invuln_time).timeout
	_invuln = false
	sprite.modulate = Color(1, 1, 1, 1)


func _on_player_respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
