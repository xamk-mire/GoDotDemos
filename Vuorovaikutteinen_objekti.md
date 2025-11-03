# 0) Alkuvaatimukset ennen aloitusta

- **Godot 4.5**
- Pelaaja on **CharacterBody2D**, jolla on **InteractZone (Area2D)** _tai_ suora törmäys.
- Kerrokset/maskit:
  - Ground = layer **1**
  - Player = layer **2** (mask **1 | 3**)
  - Interaktiiviset objektit = layer **3** (mask **1 | 2**)
- Käytä **Group**-ryhmiä: `"player"`, `"interactable"`.

---

# 1) Perus scene: Interactable.tscn

**Rakenne A (Area-käyttö, nappi, vipu, poiminta):**

```
Interactable (Area2D)
├─ Sprite2D
└─ CollisionShape2D
```

**Rakenne B (fysiikkapohjainen – työnnettävä/heitettävä):**

```
Interactable (RigidBody2D)
├─ Sprite2D
└─ CollisionShape2D   # esim. Rectangle/Circle
```

> Valitse A, jos haluat painikkeen/triggerin. Valitse B, jos haluat _fyysisen_ objektin (laatikko, pallo).

Asetukset:

- **Area2D**: Collision **Mask** sisältää **2** (Player), collision layer voi olla **3**.
- **RigidBody2D**: Mode **Rigid**, Continuous CD ✅, mass 1–3, lin/ang damping maltillinen (0.2–0.6). Layer **3**, Mask **1 | 2**.

Lisää **ryhmä**: _Node → Groups → add_ → `"interactable"`.

---

# 2) Yhtenäinen rajapinta: Interactable.gd

Tee skripti, jonka kaikki interaktiiviset käyttävät. Tämä antaa yhden kutsun: `interact(user)`.

```gdscript
# scripts/Interactable.gd (Base, Godot 4.5)
extends Node
class_name Interactable

## Kutsutaan, kun käyttäjä (esim. Player) yrittää käyttää objektia.
func interact(user: Node) -> void:
	# Ylikirjoita alaluokissa.
	pass

## Vaihtoehtoinen: näytä vihje HUDissa
func get_prompt() -> String:
	return "E: Käytä"
```

**Tapa 1 – Peri base-luokka:**

- `InteractableArea.gd` extends **Area2D**, _sekä_ `extends Interactable` ei ole mahdollista samassa – käytä **compositionia**:
  - Vaihtoehto: tee base luokasta **Resource** tai käytä **virtual**-metodeja suoraan Area2D:ssä.
- **Yksinkertaisin käytäntö opiskelijoille:** kirjoita sama `interact(user)` suoraan objektikohtaiseen skriptiin (alla on valmiit mallit).

---

# 3) Kaksi yleistä käyttövirtaa

## 3A) ”Käytä E-näppäimellä” (InteractZone-lähestymistapa)

Pelaajalla on:

```
Player
└─ InteractZone (Area2D)  # pieni alue edessä
```

- InteractZone **Mask** sisältää **3** (interakt. objektit).

**Player.gd** (ote):

```gdscript
@onready var interact_zone: Area2D = $InteractZone

func _physics_process(_dt: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_try_interact()

func _try_interact() -> void:
	for body in interact_zone.get_overlapping_bodies():
		if body.has_method("interact"):
			body.interact(self)
			return
```

## 3B) ”Automaattinen trigger” (Area-alue laukeaa)

**Interactable (Area2D)**: reagoi pelaajaan suoraan.

```gdscript
# scripts/InteractButton.gd (Area2D)
extends Area2D

@export var one_shot := false
var _used := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _used and one_shot:
		return
	if body.is_in_group("player"):
		_used = true
		activate(body)

func activate(user: Node) -> void:
	print("Nappia painettu!")
	# TODO: lähetä signaali/avaa ovi/anna esine
```

---

# 4) Kolme valmista interaktio­tyyppiä (kopioi & käytä)

### Tyyppi 1: Painike → ovikytkin (Area2D)

```
Door (Node2D)
└─ CollisionShape2D (StaticBody2D tms.)
└─ Sprite2D
```

**Door.gd**

```gdscript
extends Node2D
var is_open := false

func open() -> void:
	if is_open: return
	is_open = true
	visible = false
	# Jos käytät StaticBody2D:tä: disable collision
	var sb := get_node_or_null("StaticBody2D")
	if sb: sb.set_deferred("disabled", true)

func close() -> void:
	is_open = false
	visible = true
	var sb := get_node_or_null("StaticBody2D")
	if sb: sb.set_deferred("disabled", false)
```

**Button.gd (Area2D)**

```gdscript
extends Area2D
@export var door_path: NodePath
@onready var door := get_node_or_null(door_path)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and door and door.has_method("open"):
		door.open()
```

> Vinkki: käytä **NodePath** Inspectorissa; sijoita `Button` ja `Door` samaan Leveliin.

---

### Tyyppi 2: Poimittava esine (Area2D) – ”Pick Up”

```
Pickup (Area2D)
├─ Sprite2D
└─ CollisionShape2D
```

**Pickup.gd**

```gdscript
extends Area2D
@export var item_id: String = "key_blue"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if Game.has_method("give_item"):
			Game.give_item(item_id)  # lisää tämä Game.gd:hen
		queue_free()
```

**Game.gd** (lisäys)

```gdscript
var inventory := {}

func give_item(id: String) -> void:
	inventory[id] = (inventory.get(id, 0) + 1)
	print("Sait esineen:", id, "x", inventory[id])
```

---

### Tyyppi 3: Työnnettävä laatikko (RigidBody2D) – ”Push”

```
Crate (RigidBody2D)
├─ Sprite2D
└─ CollisionShape2D
```

**Crate.gd**

```gdscript
extends RigidBody2D
@export var max_speed := 240.0
@export var friction_override := 0.8
@export var bounce_override := 0.0

func _ready() -> void:
	var m := PhysicsMaterial.new()
	m.friction = friction_override
	m.bounce = bounce_override
	$CollisionShape2D.material = m
	sleeping = false

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
```

> Pelaaja siirtää laatikkoa joko **maskien** kautta (Player-mask sisältää 3), tai lisää ”työntöimpulssi” pelaajan `get_slide_collision` -silmukassa (kuten aiemmin teit pallolle).

---

# 5) Vuorovaikutusviesti (HUD-vinkki)

Lisää HUD:iin label (”E: Käytä”). Näytä kun Playerin **InteractZone** havaitsee objektin, jolla on `get_prompt()`.

**Player.gd (ote):**

```gdscript
func _physics_process(_dt: float) -> void:
	var prompt := ""
	for body in interact_zone.get_overlapping_bodies():
		if body.has_method("get_prompt"):
			prompt = body.get_prompt()
			break
	# Hae HUD ja näytä prompt
	var hud := get_tree().current_scene.get_node_or_null("HUD")
	if hud and hud.has_method("set_prompt"):
		hud.set_prompt(prompt)
```

**HUD.gd**

```gdscript
@onready var prompt_label: Label = $"MarginContainer/HBoxContainer/PromptLabel"

func set_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = text != ""
```

---

# 6) Signaalit: yhdistä maailmaan

Usein on siistimpää **emitoida signaali** ja antaa Level/Main hoitaa seuraukset.

**InteractButton.gd**

```gdscript
signal activated(by: Node)

func activate(user: Node) -> void:
	emit_signal("activated", user)
```

**Level.gd** (tai suoraan editorissa signal → Connect):

```gdscript
func _ready() -> void:
	$Button.activated.connect(_on_button_activated)

func _on_button_activated(_by: Node) -> void:
	$Door.open()
```

---

# 7) Yhteensopivuus & tarkistuslista (Godot 4.5)

- Interaktiivinen objekti on **Area2D** (nappi/pickup) tai **RigidBody2D** (fysiikka).
- **Layer/Mask**: object layer **3**, mask **1 | 2** (osuu maahan ja pelaajaan).
- Lisää ryhmä **"interactable"** (ja pelaajalle **"player"**).
- Playerilla on **InteractZone**, jonka **Mask** sisältää **3**.
- Kutsu `interact(user)` E-näppäimellä _tai_ käytä `body_entered`-signaalia.
- (Pickup) kutsuu `Game.give_item()` tai `Game.add_coin()`.
- (Button→Door) **NodePath** kytketty ja `Door.open()` olemassa.
- HUD-prompt toimii (valinnainen).
- Ei kahta identtistä instanssia (Remote-puu).

---

# 8) Yleiset sudenkuopat

- **Mikit ei laukea:** Area2D:n **Collision Shape** puuttuu / väärä Mask (ei sisällä Player-layeria).
- **Kutsut eivät löydy:** `Nonexistent function interact` → objektilla ei ole metodia / väärä solmu valittu.
- **Fysiikka ”jitteröi”:** RigidBody2D:lle aseta Continuous CD ✅, kohtuullinen mass/damping, älä skaalasi nodea epä­yhtenäisesti.
- **Signaali ei toimi:** Connectaaminen puuttuu tai kytketty väärään nodeen; käytä `print()` varmistukseen.
- **UI-vihje ei näy:** HUD-polku väärin → kopioi oikea polku ”Copy Node Path” -toiminnolla tai käytä group-hakua.

---

# 9) Laajennusideoita

- **Key + Door**: `Pickup.gd` antaa `key_blue`, `Door.gd` avautuu vain jos `Game.inventory.has("key_blue")`.
- **Ajastinnappi**: `activate()` → käynnistä timer → sulje ovi uudelleen.
- **Painopainike**: käytä **Area2D** + maskaa RigidBody2D:lle (laatikko/pallo aktivoi).
- **Dialogi-NPC**: `interact()` avaa dialogi-UI:n.
- **Kärry / taso**: RigidBody2D + liikerajoitukset (PinJoint2D, tms.).
