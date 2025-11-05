extends Area2D

# =============================================================
# Hazard.gd määrittelee pelissä vaarallisen alueen tai esineen,
# kuten piikit, laavan tai ansan.
#
# Kun pelaaja tai vihollinen osuu tähän alueeseen:
#   • objektille kutsutaan sen take_damage() -funktio
#
# Tämä mahdollistaa yleiskäyttöisen vahinkojärjestelmän:
#   • mikä tahansa hahmo, jolla on take_damage() -metodi,
#     voi ottaa vahinkoa tästä hazardista.
#
# Esimerkkejä:
#   • lattian piikit, jotka satuttavat pelaajaa
#   • putoava kivi joka vahingoittaa vihollisia
#   • tulialue, laser, happokaivo jne.
#
# Vinkki jatkoon:
#   • Voit lisätä animaation, äänen tai efektin osuessa
#   • Voit lisätä @export-arvoja (esim. damage_amount)
# =============================================================

func _ready() -> void:
	# Kun jokin törmää hazardin alueeseen, kutsutaan _on_body_entered
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	# Vain objektit jotka ovat 2D-hahmoja (CharacterBody2D)
	# ja joilla on take_damage() -funktio voivat ottaa vahinkoa
	if body is CharacterBody2D and body.has_method("take_damage"):
		body.take_damage()
