extends Node2D

# =============================================================
# Level.gd toimii jokaisen tason perusrunkoskriptinä.
#
# Tämän skriptin tarkoitus on varmistaa, että kun taso ladataan:
#   • pelipuu ehtii päivittyä yhden frame-syklin ajan
#   • sen jälkeen Main.gd (tai muut järjestelmät) voivat
#     hakea tietoa tasosta turvallisesti
#
# Tämä on hyödyllistä, koska:
#   • jotkut node-polut tai kollisiot eivät ole heti valmiita
#   • kameran rajat, spawn-piste ja objektit voidaan lukea
#     vasta tämän varmistuksen jälkeen
#
# Tätä tiedostoa voidaan myöhemmin laajentaa:
#   • tason musiikin asetus
#   • tason skriptien alustaminen
#   • vihollisten resetointi
#   • keräilykohteiden tai checkpointtien palautus
#
# Esimerkki Main.gd-käytöstä:
#   Main.gd lataa tason → Level.gd odottaa 1 frame →
#   Main hakee SpawnPoint-noden → sijoittaa pelaajan sinne
# =============================================================

func _ready() -> void:
	# Odotetaan yksi frame, jotta kaikki nodet ehtivät
	# latautua ja rekisteröityä pelipuuhun ennen käyttöä
	await get_tree().process_frame
