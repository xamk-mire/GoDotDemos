extends Area2D

# =============================================================
# Goal.gd määrittelee tason maalin.
#
# Kun pelaaja osuu tähän pisteeseen:
#   • Näytetään viesti HUD:ssa (esim. "Level Complete!")
#   • (Vaihtoehto) Voidaan ladata seuraava taso pienen viiveen jälkeen
#
# Tätä käytetään:
#   • Tason lopetukseen
#   • Siirtymiseen seuraavalle tasolle
#   • Antamaan palaute pelaajalle onnistumisesta
#
# Huom: Tämä skripti olettaa, että HUD löytyy polusta "Main/HUD".
# Kehittyneempi tapa on lähettää signaali Main.gd:lle,
# mutta tämä toimii aloittelijaprojektissa hyvin.
# =============================================================

func _ready() -> void:
	# Yhdistetään body_entered -signaali tähän funktioon,
	# kun pelaaja saapuu maaliin
	connect("body_entered", Callable(self, "_on_body_entered"))


func _on_body_entered(body: Node) -> void:
	# Tarkistetaan että maaliin osui pelaaja
	if body.name == "Player":
		# Etsitään HUD node pelipuusta ja näytetään viesti
		var hud = get_tree().root.get_node("Main/HUD")
		hud.show_message("Level Complete!")

		# 🎮 HUOM! Varsinainen tason vaihto voidaan tehdä näin:
		# await get_tree().create_timer(1).timeout
		# get_tree().change_scene_to_file("res://levels/Level02.tscn")
