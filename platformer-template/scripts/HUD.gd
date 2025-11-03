extends CanvasLayer

@onready var coins_label: Label = $"Panel/MarginContainer/CoinsContainer/CoinsLabel"
@onready var info_label: Label = $"Panel/MarginContainer/InfoContainer/InfoLabel"
@onready var lives_label: Label = $"Panel/MarginContainer/LivesContainer/LivesLabel"


func _ready() -> void:
	Game.coins_changed.connect(_on_coins_changed)
	Game.lives_changed.connect(_on_lives_changed)


func _on_coins_changed(count: int) -> void:
	coins_label.text = "Coins: %d" % count


func _on_lives_changed(lives_left: int) -> void:
	lives_label.text = "Lives: %d" % lives_left


func show_message(text: String) -> void:
	info_label.text = text
