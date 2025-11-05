extends CharacterBody2D

# =============================================================
# Enemy.gd hallitsee vihollishahmon perusliikkumista.
#
# Tämä vihollinen kävelee tasolla edestakaisin ja:
#   • kääntyy, kun törmää seinään
#   • kääntyy, jos reuna tulee vastaan eikä maata ole edessä
#   • noudattaa painovoimaa (putoaa jos ei maata alla)
#
# RayCast2D-nodet tarkistavat:
#   WallCheck  → osuuko seinään edessä
#   LedgeCheck → onko edessä maata vai putoaako alas
#
# Tämä toimii esim:
#   • yksinkertaisena perusvihollisena (Goomba-tyyppinen)
#   • liikkuvana esteenä tasohyppelyssä
#
# Vinkki opiskelijoille:
#   Tätä voi laajentaa lisäämällä:
#     - pelaajan aiheuttama vahinko
#     - vihollisen kuoleminen hypystä
#     - animaatiot tai ääni
# =============================================================

# Perusasetuksia editorista muokattaviksi
@export var speed: float = 60.0 # Liikkumisnopeus
@export var gravity: float = 1400.0 # Painovoima

@export var wall_len: float = 12.0 # Kuinka kauas edestä etsitään seinää
@export var ledge_ahead: float = 8.0 # Kuinka kauas eteen etsitään pudotusta
@export var ledge_drop: float = 16.0 # Kuinka syvä pudotus tarkistetaan

# -1 = vasemmalle, +1 = oikealle
var direction: int = -1

# Haetaan node-viittaukset
@onready var sprite: Sprite2D = $Sprite2D
@onready var wall_check: RayCast2D = $WallCheck # Edessä oleva este
@onready var ledge_check: RayCast2D = $LedgeCheck # Reuna/putoaminen edessä


func _ready() -> void:
	# Varmistetaan, että raycastit toimivat
	wall_check.enabled = true
	ledge_check.enabled = true

	# Käännetään sprite oikeaan suuntaan
	sprite.flip_h = (direction < 0)

	_update_rays()


func _physics_process(delta: float) -> void:
	# Lisää painovoima, jos ei maassa
	if not is_on_floor():
		velocity.y += gravity * delta

	# Liikkuu aina samaan suuntaan kunnes kääntyy
	velocity.x = direction * speed

	# Jos seinä edessä → käänny
	# Jos ei maata edessä → käänny
	if wall_check.is_colliding() or not ledge_check.is_colliding():
		_flip()

	move_and_slide()


# Vaihtaa liikkeen suuntaa
func _flip() -> void:
	direction *= -1
	sprite.flip_h = (direction < 0)
	_update_rays()


# Päivitetään raycastien suunta uuden käännön jälkeen
func _update_rays() -> void:
	wall_check.target_position = Vector2(wall_len * direction, 0)
	ledge_check.target_position = Vector2(ledge_ahead * direction, ledge_drop)
