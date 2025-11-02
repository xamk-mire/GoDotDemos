extends Node2D

@export var level_scene: PackedScene
@onready var player: Node2D = $Player
#@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	# Find spawn in the level and start the run timer.
	var level := $Level
	var spawn := level.get_node_or_null("SpawnPoint")
	var spawn_pos := Vector2.ZERO
	if spawn:
		spawn_pos = spawn.global_position
	player.global_position = spawn_pos
	Game.reset_for_level(spawn_pos)

	# Camera follow
	#camera.make_current()
	#camera.position = player.position
	#camera.set_process(true)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
