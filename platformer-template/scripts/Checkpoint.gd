extends Area2D

# =============================================================
# Checkpoint.gd ohjaa pelin checkpoint-toimintaa.
#
# Checkpoint on piste tasossa, johon pelaaja respawnataan
# (eli ilmestyy uudelleen), jos pelaaja kuolee.
#
# Kun pelaaja koskettaa checkpoint-aluetta ensimmäistä kertaa:
#   • checkpoint aktivoituu
#   • pelin uusi spawn-piste tallennetaan
#   • checkpointin väri muuttuu merkiksi aktivoitumisesta
#
# Tätä käytetään mm.:
#   • pitkissä tasoissa, jotta pelaaja ei aloita aina alusta
#   • tallentamaan edistys tasossa kuolemien välillä
# =============================================================

# Tieto siitä, onko checkpoint jo aktivoitu.
# (Aktivoitu checkpoint ei aktivoidu uudelleen)
var _activated := false


# Tämä funktio kutsutaan automaattisesti, kun jokin törmää checkpointiin
func _on_body_entered(body: Node) -> void:
	# Tarkistetaan, että checkpoint ei ole vielä käytetty
	# ja että siihen osui pelaaja
	if not _activated and body.name == "Player":
		# Merkitään checkpoint käytetyksi
		_activated = true

		# Kerrotaan Game-järjestelmälle uusi respawn-piste
		Game.set_spawn(global_position)

		# Vaihdetaan ulkonäköä (esim. vihertäväksi),
		# jotta pelaaja näkee checkpointin aktivoituneen
		modulate = Color(0.6, 1.0, 0.6)
