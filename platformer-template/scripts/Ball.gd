extends RigidBody2D

# =============================================================
# Ball.gd ohjaa pelissä olevaa palloa, jota pelaaja voi potkaista ja työntää.
#
# Se käyttää Godotin fysiikkajärjestelmää (RigidBody2D), joten se käyttäytyy luonnollisesti:
#   • vierii painovoiman alla
#   • törmää maahan ja seinin
#   • voi saada voiman (impulssin) pelaajalta potkusta
#   • nopeus rajoitetaan, ettei pallo karkaa liian nopeaksi
#
# Tätä voidaan käyttää esimerkiksi:
#   • jalkapallona
#   • kannettavana tai työnnettävänä laatikkona
#   • puzzle-esineenä (paino nappien päälle)
# =============================================================

# Suurin sallittu liikkumisnopeus pallolle
@export var max_speed: float = 380.0

# Peruspotkun voimakkuus (voi saada bonus-kerrointa)
@export var kick_strength: float = 260.0


func _ready() -> void:
	# Estetään Godotia "nukuttamasta" palloa, jotta se reagoi aina potkuihin
	sleeping = false


# Potku-funktio, jota pelaaja kutsuu osuessaan palloon
func kick(from_position: Vector2, bonus: float = 1.0) -> void:
	# Lasketaan suunta pallosta pelaajaan päin (potkun suunta)
	var dir := (global_position - from_position).normalized()

	# Annetaan pallolle impulssi (potku)
	apply_impulse(dir * (kick_strength * bonus))


# Fysiikkapäivitys — rajoitetaan pallon maksiminopeus
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
