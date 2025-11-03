# ✅ Ominaisuuden lisäämisen yleischecklist

## 0) Määrittely & suunnittelu

- [ ] **Tavoite yhdellä lauseella**: mitä pelaaja voi nyt tehdä?
- [ ] **Käynnin ehto**: milloin ominaisuus aktivoituu (syöte, törmäys, aika, tila)?
- [ ] **Poistumisen ehto**: milloin/miten ominaisuus päättyy?
- [ ] **Vaikutus pelitilaan**: muuttaako elämät, kolikot, inventaarion, tason?
- [ ] **Riskit**: kamerat, suorituskyky, törmäykset, monistuminen (duplikaatit).
- [ ] **Arvio kokoon**: pieni / keskisuuri / suuri (vaikuttaa testiin ja “definition of done” -kriteereihin).

---

## 1) Kansiot & resurssit

- [ ] Luo **scene** `scenes/`-kansioon (tai duplaa olemassa oleva pohja).
- [ ] Lisää **scripti** `scripts/`-kansioon (nimi = ominaisuuden rooli).
- [ ] Assetit `art/`, äänet `art/sfx/`, fontit `fonts/`, teemat `ui/`.
- [ ] Nimeä selkeästi: `Dash.gd`, `Door.gd`, `Button.tscn`, `Pickup.tscn`.

---

## 2) Solmurakenne (Node tree)

- [ ] Valitse oikea **node-tyyppi**:

  - Interaktio / triggeri → **Area2D**
  - Fyysinen esine → **RigidBody2D**
  - Pelaaja/vihollinen → **CharacterBody2D**
  - UI → **Control** (Label, Panel, TextureRect, tms.)

- [ ] Lisää **CollisionShape2D** oikealla muodolla.
- [ ] Aseta **z_index** tarvittaessa (tausta < 0, peli 0, UI CanvasLayerissä).
- [ ] Ryhmät: lisää esim. `"player"`, `"enemy"`, `"interactable"`.

---

## 3) Kerrokset & maskit (Physics layers/masks)

- [ ] Ground = Layer **1** (mask 0)
- [ ] Player = Layer **2**, Mask **1 | 3**
- [ ] Interaktio-objektit = Layer **3**, Mask **1 | 2**
- [ ] Tarkista myös **RayCast2D** → Mask **1** (vain maa/seinät).

---

## 4) Syötteet (Input Map)

- [ ] Lisää uudet toiminnot: `dash`, `interact`, `attack`, jne.
- [ ] Bindaa näppäimet + gamepad (Project Settings → Input Map).
- [ ] Lue pelissä: `Input.is_action_just_pressed("dash")`.
- [ ] Dokumentoi ohjaimet HUD:ssa tai ohjevalikossa.

---

## 5) Signaalit & kommunikointi

- [ ] Määritä **signal** lähdesolmussa (esim. `activated(by)`).
- [ ] **Connect** editorissa tai koodissa (vain kerran!).
- [ ] Autoload **Game.gd**: lisää metodit ja **emit_signal**-kutsut (coins/lives/inventory).
- [ ] Vältä kovia node-polkuja: käytä **ryhmiä** (`get_first_node_in_group`) tai **NodePath export**ia.

---

## 6) Logiikka & tila

- [ ] Kirjoita selkeä **tilavirta**: idle → active → cooldown (FSM kannattaa).
- [ ] Vältä “taikamuuttujia”: käytä **@export** parametreja Inspector-säädölle.
- [ ] Pidä **fysiikka** `_physics_process()` + `move_and_slide()`.
- [ ] Aikaperusteet: käytä **Timer** tai `create_timer()` (ei `yield`-spagettia).

---

## 7) UI / HUD päivitykset

- [ ] Lisää tarvittavat **Labelit/Panelit** (esim. PromptLabel, LivesLabel).
- [ ] Tee **Theme Overrides** (fontti, väri) tai käytä projektin UI-teemaa.
- [ ] Lisää **HUD API**: `show_message(text)`, `set_prompt(text)`, `set_lives(n)`.
- [ ] Kytke HUD **Game.gd** -signaaleihin (coins_changed, lives_changed).

---

## 8) Audio & VFX

- [ ] Lisää **AudioStreamPlayer2D** (pickup/activate/hit/kick).
- [ ] Partikkelit: **GPUParticles2D** tai **CPUParticles2D** (kevyet asetukset).
- [ ] Äänet toistetaan **läheltä lähdettä** (spatiaalisuus) tai HUDissa (UI-SFX).

---

## 9) Kamera & taustat

- [ ] Yksi **Camera2D** Mainissa, **Current=On**.
- [ ] Päivitä rajat TileMapLayerien **used_rect**-unionista.
- [ ] Parallax-tausta Godot 4.5: **Parallax2D + ParallaxLayer2D**; **Texture Repeat** ON; `motion_mirroring.x` ≥ näkymän leveys.

---

## 10) Suorituskyky & vakaus

- [ ] Vältä **kaksi taso-instanssia** (katso Remote-puu).
- [ ] Kytke pois näkyvyydestä/poista **kaukaiset** objektit (LOD, `visible=false`).
- [ ] RigidBody2D: **Continuous CD** päälle pienille/nopeille esineille.
- [ ] Vältä ei-tarpeellista **\_process**-kuormaa – käytä signaaleja ja Timereita.
- [ ] Tarkista **import-asetukset** (Filter/Repeat, kohtuullinen koko).

---

## 11) Testaus (DoD – Definition of Done)

- [ ] **Käyttöpolku läpi**: ominaisuus voidaan aktivoida ja sulkea virheittä.
- [ ] **Törmäys & maskit** oikein (Debug → Visible Collision Shapes).
- [ ] **Signaalit** laukeavat kerran (ei duplikaattikytkentöjä).
- [ ] **HUD**/UI päivittyy oikein.
- [ ] **Peli ei kaadu** puuttuviin nodeihin/metodeihin (turvakutsut `get_node_or_null`, `has_method`).
- [ ] **Remote**-puussa ei ole duplikaatteja (tasot, pelaaja, HUD).
- [ ] **Restart** ja **game over** toimivat kuten ennen (regressiotestit).
- [ ] Konsoli **ei tulvi varoituksia** (siivoa `_unused`-parametrit).

---

# 🧱 Pika-mallit (kopioi & käytä)

## A) Area2D-interaktio (E-näppäin)

```gdscript
# Player.gd (ote)
@onready var interact_zone: Area2D = $InteractZone

func _physics_process(_dt: float) -> void:
    if Input.is_action_just_pressed("interact"):
        for b in interact_zone.get_overlapping_bodies():
            if b.has_method("interact"):
                b.interact(self)
                break
```

```gdscript
# Button.gd (Area2D)
extends Area2D
signal activated(by: Node)

func interact(user: Node) -> void:
    emit_signal("activated", user)
```

## B) Trigger-alue (automaattilaukaisu)

```gdscript
extends Area2D
@export var one_shot := false
var _used := false

func _ready() -> void:
    body_entered.connect(_on_enter)

func _on_enter(body: Node) -> void:
    if _used and one_shot: return
    if body.is_in_group("player"):
        _used = true
        _activate(body)

func _activate(user: Node) -> void:
    print("Triggered by:", user.name)
```

## C) Turvallinen node-haku & HUD-viesti

```gdscript
var hud := get_tree().current_scene.get_node_or_null("HUD")
if hud and hud.has_method("show_message"):
    hud.show_message("Hei maailma")
```

---

# 🔍 Debug & vianetsintä

- [ ] **print_tree_pretty()** heti instansoinnin jälkeen → näe puu.
- [ ] **Visible Collision Shapes** → muodot oikeissa paikoissa.
- [ ] **Signals**: tulosta `print("activated")` varmistaaksesi laukaisun.
- [ ] **Groups**: lisää `player` ja `interactable` – helpottaa logiikkaa.
- [ ] **Tyypitetty GDScript**: määritä tyypit (esim. `var pos: Vector2 = ...`).
- [ ] **Ternary GDScript 4.x**: käytä `B if A else C` (ei `? :`).

---

# 📦 Julkaisukelpoinen lisäys – minimit

- [ ] Koodi kommentoitu lyhyesti, `@export`-arvot järkevät.
- [ ] Ei kovakoodattuja polkuja (NodePath export / groups).
- [ ] Ominaisuus toimii **Level01** ja **Level02** -tasolla.
- [ ] Palautuu siististi **Game.new_game()** / restart-polussa.
- [ ] Ei vaikuta negatiivisesti FPS:ään.

---

# 🧭 Päätöspuu: millä mallilla aloitan?

- **Tarvitaan vain “käytä E”:** Area2D + `interact(user)` (A-malli).
- **Haluan automaattisen triggerin:** Area2D + `body_entered` (B-malli).
- **Fyysisesti liikutettava:** RigidBody2D + maskit + (tarvittaessa) impulssi pelaajasta.
- **UI-ominaisuus:** lisää Control-node + Theme/StyleBox + signaalit Game/HUD.
- **Globaali tila:** laajenna `autoload/Game.gd` (signaalit mukaan).

---

# 📝 Pieni “Feature brief” -pohja opiskelijoille

- **Nimi:** (esim. “Dash”)
- **Tavoite:** (nopea sivuttaisliike + cooldown)
- **Solmut:** Player.gd (logiikka), HUD (ikoni)
- **Input:** `dash`
- **Signaalit:** (ei/tarvittaessa `dash_used`)
- **Parametrit (@export):** nopeus, kesto, cooldown
- **Testit:** toimii ilmassa/maassa, ei läpäise seiniä, HUD päivittyy
- **Valmis kun:** testilista vihreä, ei varoituksia, ei FPS-droppia
