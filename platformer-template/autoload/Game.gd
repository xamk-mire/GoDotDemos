extends Node

# Signaalit, joita muut pelin osat voivat kuunnella
signal coins_changed(count: int) # Lähetetään kun kolikkojen määrä muuttuu
signal lives_changed(lives_left: int) # Lähetetään kun elämämäärä muuttuu
signal player_respawn(spawn_position: Vector2) # Lähetetään kun pelaaja respawnataan
signal game_over() # Lähetetään kun pelaajan elämät loppuvat

# Pelin tila
var coins := 0 # Kerättyjen kolikoiden määrä
var max_lives := 3 # Maksimilives
var lives := max_lives # Nykyiset elämät
var spawn_position := Vector2.ZERO # Kohta johon pelaaja respawnataan


# Aloitetaan uusi peli (kaikki arvot alustetaan)
func new_game() -> void:
	coins = 0
	lives = max_lives
	emit_signal("coins_changed", coins)
	emit_signal("lives_changed", lives)


# Nollataan tasokohtaiset arvot (esim. kolikot)
# Asetetaan myös spawn-piste tasolle
func reset_for_level(spawn: Vector2) -> void:
	coins = 0
	spawn_position = spawn
	emit_signal("coins_changed", coins)


# Päivitetään spawn-piste (checkpointit käyttävät tätä)
func set_spawn(pos: Vector2) -> void:
	spawn_position = pos


# Lisätään kolikkoja ja ilmoitetaan HUD:lle
func add_coin(amount: int = 1) -> void:
	coins += amount
	emit_signal("coins_changed", coins)


# Pelaaja ottaa damagea
# Jos elämät loppuvat → game over, muuten respawn
func damage_player() -> void:
	if lives <= 0:
		return
	lives -= 1
	emit_signal("lives_changed", lives)

	# Jos elämiä jäljellä → respawn
	if lives > 0:
		emit_signal("player_respawn", spawn_position)
	else:
		# Ei elämiä = peli loppuu
		emit_signal("game_over")
