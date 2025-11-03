# 🎮 Tasohyppelypeli — Tekninen dokumentaatio (Opiskelijaversio)

## 📘 **Projektin kuvaus**

Tämä projekti on **2D-tasohyppelypelin** aloituspohja, tehty Godot 4 -pelimoottorilla.

Projektin tavoitteena on oppia:

- Godotin perusrakenne ja kohtausjärjestelmä
- Pelaajan liikkuminen ja fysiikka
- Viholliset ja vaaralliset elementit
- Kerättävät kolikot ja pistelaskuri
- Tarkistuspisteet (checkpointit)
- Tason maali
- Fysiikkaobjektit (pallo)
- Käyttöliittymä (HUD)
- Taustaparallaksi (Parallax background)
- Tasojen lataaminen

**Opiskelijan tehtävä** on laajentaa peliä, lisätä uusia ominaisuuksia ja tehdä siitä oma versio.

---

## 📂 **Kansiot**

| Kansio      | Tarkoitus                                                       |
| ----------- | --------------------------------------------------------------- |
| `art/`      | Pelin grafiikat (hahmot, taustat, ikonit, fontit)               |
| `autoload/` | Globaalit skriptit (kuten Game.gd)                              |
| `levels/`   | Jokainen pelitaso erillisenä scene-tiedostona                   |
| `scenes/`   | Uudelleenkäytettävät kohtaukset (Player, Enemy, Coin, HUD jne.) |
| `scripts/`  | Kaikki pelin skriptit                                           |
| `icon.svg`  | Projektin ikoni                                                 |

---

## 🎭 **Keskeiset kohtaukset**

| Scene             | Rooli                                                |
| ----------------- | ---------------------------------------------------- |
| `Main.tscn`       | Pelin päähallinta, lataa tason ja sijoittaa pelaajan |
| `Level01.tscn`    | Ensimmäinen pelitaso                                 |
| `Player.tscn`     | Pelaajan hahmo                                       |
| `Enemy.tscn`      | Vihollinen, joka partioi ja vaihtaa suuntaa          |
| `Coin.tscn`       | Kerättävä kolikko                                    |
| `Checkpoint.tscn` | Tallentaa pelaajan paluupisteen                      |
| `Goal.tscn`       | Tason maali                                          |
| `Ball.tscn`       | Työnnettävä / kannettava pallo                       |
| `HUD.tscn`        | Käyttöliittymä (kolikot, elämät, viestit)            |

---

## 🧠 **Global Game -järjestelmä**

### `Game.gd`

Toimii **pelin muisti- ja logiikkakeskuksena**. Se hallitsee:

- Kolikot
- Pelaajan elämät
- Respawn-sijainnit
- Pelin aloitus ja uudelleenkäynnistys

Lisäksi se lähettää **signaaleja**, joilla HUD ja Main tietävät, mitä tapahtui.

> ✅ Tänne voi lisätä myöhemmin esim. avaimia, voima-esineitä, pisteitä, inventaarion jne.

---

## 👤 **Pelaaja**

Pelaaja käyttää Godotin fysiikkaa (`CharacterBody2D`):

- Liikkuminen vasen/oikea
- Hyppääminen
- Painovoima
- Törmäykset ja vuorovaikutus

**Laajennusideoita opiskelijoille:**

- Tuplahyppy
- Seinähyppy / seinäliuku
- Dash / spurtti
- Hyökkäys / heitto
- Liukuminen / crouch

---

## 👾 **Viholliset**

Liikkuvat edestakaisin ja vaihtavat suuntaa:

- Kun edessä on seinä (RayCast2D)
- Kun reunassa ei ole maata (RayCast2D)

**Laajennusideoita:**

- Pelaajan jahtaaminen
- Luodit / hyökkäysanimaatiot
- Useita vihollistyyppejä
- Pomotaistelu

---

## 🪙 **Kolikot**

Toimii `Area2D`-objektina:

- Kun pelaaja koskee kolikkoon → se katoaa
- Kolikkolaskuri lisääntyy
- HUD päivittyy automaattisesti

> Voit tehdä eri arvoisia kolikoita tai bonus-kolikoita.

---

## ❤️ **Elämät ja respawn**

- Pelaajalla on elämät/hitpoints (esim. 3)
- Kun pelaaja saa osuman → respawn
- Kun kaikki elämät loppuvat → peli alkaa alusta
- Checkpoint tallentaa paluupaikan

**Laajennusideoita:**

- Sydänpalkki (HP)
- Lisäelämä-esine
- Väliaikainen kuolemattomuus

---

## 🏞️ **Parallax-tausta**

`Parallax2D` + useita kerroksia (taivas, pilvet, vuoret, puut)

Pelissä jo valmiina — opiskelija voi lisätä:

- Animoituja taustoja
- Useampia kerroksia
- Päivä-/yötila

---

## 🧰 **Ohjaimet**

| Toiminto     | Näppäin       |
| ------------ | ------------- |
| Liiku        | ← → / A D     |
| Hyppy        | Space / W / ↑ |
| Vuorovaikuta | E             |

---

## 🚀 **Projektin debugaus**

- **F5** — käynnistä peli
- **Remote-näkymä** — näe mitä oikeasti tapahtuu pelissä
- `print()` — tulosta debug-viestejä konsoliin
- Scene tree: varmista ettei taso lataudu kahdesti
- Jos jokin ei toimi — tarkista signaalit ja solmujen nimet

---

## 🎯 **Kehitystehtäviä opiskelijoille**

| Tehtävä                          | Tavoite              |
| -------------------------------- | -------------------- |
| Tee oma pelihahmo                | Grafiikan vaihto     |
| Luo uusi taso                    | Tason suunnittelu    |
| Lisää ääni kolikoille            | Äänet Godotissa      |
| Lisää uusi vihollinen            | Logiikka ja fysiikka |
| Lisää tehoste (dash, tuplahyppy) | Pelimekaniikka       |
| Tee valikko tai taukopainike     | UI-suunnittelu       |

---

## 💡 Vinkkejä oppimiseen

- Kokeile rohkeasti
- Lisää pieni osa kerrallaan
- Testaa usein
- Pidä koodisi selkeänä
- Tallenna varmuuskopiot
- Kysy apua ajoissa

---

## 🎉 **Yhteenveto**

Tämä projektipohja tarjoaa:

- Toimivan tasohyppelyn
- Pelaajan fysiikat
- Kolikot, viholliset ja elämät
- HUD-järjestelmä
- Tason maali ja respawn
- Taustaparallaksit

**Nyt on sinun vuorosi laajentaa peliä ja tehdä siitä oma versiosi.**  
Ole luova ja pidä hauskaa!
