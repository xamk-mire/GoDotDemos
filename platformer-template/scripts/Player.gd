extends CharacterBody2D

# =============================================================
# Player.gd hallitsee kaikkea pelaajan toiminnallisuutta:
#
# ✔ liikkuminen ja hyppy
# ✔ painovoima
# ✔ suunnan vaihto ja spriten kääntö
# ✔ esineiden nosto, kantaminen ja potkiminen (esim. pallo)
# ✔ muiden fysiikkaobjektien työntäminen
# ✔ vahingon ottaminen ja väliaikainen haavoittumattomuus
# ✔ respawn-pisteestä palaaminen
#
# Tämä skripti toimii pelin pääohjattavana hahmona.
#
# Opiskelija oppii:
#   • CharacterBody2D-fysiikka
#   • input-käsittely
#   • collision layer & mask manipulointi
#   • signaalien käyttö (respawn)
#   • nodejen kääntö, reparentointi ja fyysinen interaktio
# =============================================================

# -------- Node-viittaukset --------
@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_zone: Area2D = $InteractZone
@onready var hold_socket: Node2D = $HoldSocket

# -------- Pelaajan perusasetukset --------
@export var speed := 220.0
@export var jump_force := 400.0
@export var gravity := 1000.0
@export var invuln_time := 0.8

# -------- Esineiden kantaminen / potkiminen --------
@export var kick_strength := 360.0
@export var carry_disable_collisions := true # Poista törmäykset kannettaessa (turvallisempi)
@export var ball_layer_when_free := 3 # Pallon layer kun ei kanneta

# -------- Liikeavustimet --------
@export var coyote_time: float = 0.1 # Sallii hypyn hetken putoamisen jälkeen
@export var jump_buffer_time: float = 0.1 # Sallii hypyn pienen ennakoinnin
@export var push_strength := 220.0 # Fysiikkaobjektien työntö

# -------- Sisäiset tilamuuttujat --------
var carried_ball: RigidBody2D = null
var _saved_layer := 0
var _saved_mask := 0
var _saved_gravity := 1.0
var _facing := 1 # 1 = oikea, -1 = vasen
var _invuln := false


func _ready() -> void:
	# Kuunnellaan Game-autoloadin respawn-signaalia
	Game.player_respawn.connect(_on_player_respawn)


func _physics_process(delta: float) -> void:
	# -------- Liike (vasen/oikea) --------
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * speed

	# Suunnan vaihto ja spriten kääntö
	if dir != 0:
		_facing = sign(dir)
		sprite.scale.x = _facing

		# Käännetään myös interaktioalue ja kantopaikka
		interact_zone.position.x = abs(interact_zone.position.x) * _facing
		hold_socket.position.x = abs(hold_socket.position.x) * _facing

	# -------- Painovoima --------
	if not is_on_floor():
		velocity.y += gravity * delta

	# -------- Hyppy --------
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

	move_and_slide()

	# -------- Interaktio (syöte) --------
	if Input.is_action_just_pressed("interact"):
		_on_interact_pressed()

	# -------- Fysiikkaobjektien työntäminen --------
	_push_rigid_bodies()


# =============================================================
# Interaktio / kantaminen / potkiminen
# =============================================================
func _on_interact_pressed() -> void:
	if carried_ball:
		# Potkaise tai pudota pallo
		_kick_carried_ball()
	else:
		# Etsi kantokelpoinen objekti
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

	# Tallenna törmäys- & fysiikka-asetukset palautusta varten
	_saved_layer = ball.collision_layer
	_saved_mask = ball.collision_mask
	_saved_gravity = ball.gravity_scale

	# "Nollataan" pallo ja kiinnitetään pelaajaan
	ball.sleeping = false
	ball.freeze = true
	ball.linear_velocity = Vector2.ZERO
	ball.gravity_scale = 0.0

	# Poista törmäys kannettaessa (jitterin esto)
	if carry_disable_collisions:
		ball.set_deferred("collision_layer", 0)
		ball.set_deferred("collision_mask", 0)

	# Siirrä pallo pelaajan lapseksi
	ball.set_deferred("global_position", hold_socket.global_position)
	await get_tree().process_frame
	ball.reparent(self)
	ball.position = hold_socket.position


func _kick_carried_ball() -> void:
	if not carried_ball:
		return

	var ball := carried_ball
	carried_ball = null

	# Palauta tasoon
	var level := get_parent()
	ball.reparent(level)
	ball.global_position = hold_socket.global_position

	# Palauta fysiikka
	if carry_disable_collisions:
		ball.collision_layer = _saved_layer
		ball.collision_mask = _saved_mask
	ball.gravity_scale = _saved_gravity

	ball.freeze = false
	ball.sleeping = false

	# Potkaisusuunta pieni kulma ylöspäin
	var dir := Vector2(_facing, -0.2).normalized()
	ball.apply_impulse(dir * kick_strength)

	await get_tree().create_timer(0.12).timeout


# =============================================================
# Fysiikkaobjektien työntäminen
# =============================================================
func _push_rigid_bodies() -> void:
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		var rb := col.get_collider()
		if rb is RigidBody2D:
			var dir := velocity
			if dir.length() < 1.0:
				dir = -col.get_normal() * 120.0
			rb.apply_impulse(dir.normalized() * push_strength)
			rb.sleeping = false


# =============================================================
# Vahinko ja väliaikainen haavoittumattomuus
# =============================================================
func take_damage() -> void:
	if _invuln:
		return
	_invuln = true
	Game.damage_player()
	flash_invuln()


func flash_invuln() -> void:
	# Pieni välähdysanimaatio
	var t := create_tween().set_loops(6)
	t.tween_property(sprite, "modulate:a", 0.2, 0.06).from(1.0)
	t.tween_property(sprite, "modulate:a", 1.0, 0.06)
	await get_tree().create_timer(invuln_time).timeout
	_invuln = false
	sprite.modulate = Color(1, 1, 1, 1)


# =============================================================
# Respawn
# =============================================================
func _on_player_respawn(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
