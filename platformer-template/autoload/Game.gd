extends Node

signal coins_changed(count: int)
signal lives_changed(lives_left: int)
signal player_respawn(spawn_position: Vector2)
signal game_over()

var coins := 0
var max_lives := 3
var lives := max_lives
var spawn_position := Vector2.ZERO


func new_game() -> void:
	coins = 0
	lives = max_lives
	emit_signal("coins_changed", coins)
	emit_signal("lives_changed", lives)


func reset_for_level(spawn: Vector2) -> void:
	coins = 0
	spawn_position = spawn
	emit_signal("coins_changed", coins)


func set_spawn(pos: Vector2) -> void:
	spawn_position = pos


func add_coin(amount: int = 1) -> void:
	coins += amount
	emit_signal("coins_changed", coins)


func damage_player() -> void:
	if lives <= 0:
		return
	lives -= 1
	emit_signal("lives_changed", lives)
	if lives > 0:
		emit_signal("player_respawn", spawn_position)
	else:
		emit_signal("game_over")
