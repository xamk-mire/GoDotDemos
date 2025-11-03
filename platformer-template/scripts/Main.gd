extends Node2D

const LEVEL_PATH := "res://levels/Level01.tscn"
var level_scene: PackedScene = load(LEVEL_PATH)

@onready var player: CharacterBody2D = $Player
var current_level: Node = null
var _loading: bool = false


func _ready() -> void:
	Game.new_game()

	# connect once
	if not Game.game_over.is_connected(_on_game_over):
		Game.game_over.connect(_on_game_over)

	_load_level()
	print_tree_pretty()


func _load_level() -> void:
	if _loading:
		return
	_loading = true

	for n in get_children():
		if n.name == "Level" or n.is_in_group("level_root"):
			n.queue_free()
	await get_tree().process_frame

	if level_scene == null:
		push_error("Main.gd: 'level_scene' not assigned")
		_loading = false
		return

	current_level = level_scene.instantiate()
	current_level.name = "Level"
	current_level.add_to_group("level_root")
	add_child(current_level)
	await get_tree().process_frame

	var spawn := current_level.get_node_or_null("SpawnPoint") as Node2D
	var pos: Vector2 = spawn.global_position if spawn != null else Vector2.ZERO
	$Player.global_position = pos
	Game.reset_for_level(pos)

	_loading = false


func _on_game_over() -> void:
	var hud := get_node_or_null("HUD")
	if hud and hud.has_method("show_message"):
		hud.show_message("Game Over! Restarting...")

	await get_tree().create_timer(1.0).timeout
	Game.new_game()
	_load_level()
