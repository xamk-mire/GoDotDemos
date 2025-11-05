extends CanvasLayer

# =============================================================
# HUD.gd vastaa pelin käyttöliittymän näyttämisestä.
#
# HUD (Heads-Up Display) näyttää pelaajalle tärkeää tietoa:
#   • kolikkojen määrä
#   • elämien määrä
#   • viestit (esim. "Level Complete!")
#
# Tämä skripti kuuntelee Game.gd:n signaaleja ja päivittää
# tekstit automaattisesti, kun pelitila muuttuu.
#
# CanvasLayer varmistaa, että HUD pysyy kameran päällä,
# eikä liiku taso-objektien mukana.
# =============================================================

# Haetaan UI-elementit kohtauksen puusta
@onready var coins_label: Label = $"Panel/MarginContainer/CoinsContainer/CoinsLabel"
@onready var info_label: Label = $"Panel/MarginContainer/InfoContainer/InfoLabel"
@onready var lives_label: Label = $"Panel/MarginContainer/LivesContainer/LivesLabel"


func _ready() -> void:
	# Yhdistetään Game-signaalit HUDin päivitysfunktioihin
	Game.coins_changed.connect(_on_coins_changed)
	Game.lives_changed.connect(_on_lives_changed)


# Päivittää kolikkotekstin, kun Game.gd lähettää coins_changed-signaalin
func _on_coins_changed(count: int) -> void:
	coins_label.text = "Coins: %d" % count


# Päivittää elämämäärän, kun Game.gd lähettää lives_changed-signaalin
func _on_lives_changed(lives_left: int) -> void:
	lives_label.text = "Lives: %d" % lives_left


# Näyttää HUD:iin informatiivisen viestin (esim. tason läpäisy)
func show_message(text: String) -> void:
	info_label.text = text
