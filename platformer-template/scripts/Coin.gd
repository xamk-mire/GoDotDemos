extends Area2D

# =============================================================
# Coin.gd hallitsee kerättävää kolikkoa pelissä.
#
# Kun pelaaja koskettaa kolikkoa:
#   • kolikon arvo lisätään Game-järjestelmään (esim. 1 kolikko)
#   • kolikko poistetaan pelistä
#
# Kolikoita voidaan käyttää esimerkiksi:
#   • pistelaskuun
#   • avaamaan ovia / portteja kun tarpeeksi kerätty
#   • bonus- tai keräilykohteina tasoissa
#
# Tämä tiedosto olettaa, että Game.gd on autoloadina,
# jotta Game.add_coin() toimii.
# =============================================================

# Kuinka monta kolikkoa tämä objekti antaa pelaajalle
@export var value: int = 1


# Tämä funktio kutsutaan, kun jokin törmää kolikon hitboxiin
func _on_body_entered(body: Node) -> void:
	# Varmistetaan, että vain Player voi kerätä kolikon
	if body.name == "Player":
		# Lisätään kolikon arvo pelin kokonaiskolikkomäärään
		Game.add_coin(value)

		# Poistetaan kolikko pelistä
		queue_free()
