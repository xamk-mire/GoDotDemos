extends CanvasLayer

@onready var coins_label: Label = $"MarginContainer/HBoxContainer/CoinsLabel"
@onready var info_label: Label = $"MarginContainer/HBoxContainer/InfoLabel"


func _ready() -> void:
	coins_label.text = "Coins: 0"
	info_label.text = ""
	Game.coins_changed.connect(_on_coins_changed)
	Game.player_died.connect(_on_player_died)
	Game.level_completed.connect(_on_level_completed)


func _on_coins_changed(count: int) -> void:
	coins_label.text = "Coins: %d" % count


func _on_player_died(lives_left: int) -> void:
	info_label.text = "Ouch! Lives: %d" % lives_left


func _on_level_completed(time_sec: float) -> void:
	info_label.text = "Level complete! Time: %.2f s" % time_sec
