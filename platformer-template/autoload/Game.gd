extends Node

signal coins_changed(count: int)
signal player_died(lives_left: int)
signal level_completed(time_sec: float)

var coins: int = 0
var lives: int = 3
var spawn_position: Vector2 = Vector2.ZERO
var level_time: float = 0.0
var timer_running := false


func _process(delta: float) -> void:
	if timer_running:
		level_time += delta


func reset_for_level(spawn: Vector2) -> void:
	coins = 0
	level_time = 0.0
	spawn_position = spawn
	timer_running = true
	emit_signal("coins_changed", coins)


func add_coin(amount: int = 1) -> void:
	coins += amount
	emit_signal("coins_changed", coins)


func set_spawn(pos: Vector2) -> void:
	spawn_position = pos


func on_player_death() -> void:
	lives -= 1
	emit_signal("player_died", lives)


func complete_level() -> void:
	timer_running = false
	emit_signal("level_completed", level_time)
