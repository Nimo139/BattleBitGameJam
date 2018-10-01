# Grundlgendes

Im code Editor:

dofile("game.lua")

Wiki mit nützlichen Kram:
https://github.com/nesbox/TIC-80/wiki

## Steuerung 
- Arrows L/R: Move
- Arrow up: Jump
- Arrow down: Sneak
- D: Throw Wool
- D + Sneak: Pull wool (near to the wool)
- R: Reset level


# Notizen und Struktur

## Farbpalette:
- 16 15 14 -> Sind Farben der Katze (11 auch, aber wenn wir diesen Platz brauchen, dann mache ich das Design nochmal anders)
- 13 12 -> Sind Farben der Wolle
- 2 3 -> Farben für'n Himmel
- 4 5 6 7 8 -> Farben für'n Boden
- .. Der Rest ist für nichts, bis jetzt. Natürlich sind die Farben Universal, aber ungefähr geordnet.

## Sprites:
- #000: blank
- #001 - #031: currently unused
- #032 - #079: solid
- #080 - #111: half-solid
- #112 - #239: decoration / background
- #240 - #255: special-event-sprites
- #256 - #271: cat stuff
- #272 - #276: wool stuff
- #277 - #511: currently unused

## World Map:
- 01: preLevelOne
- 2-8: Level 1
- 9: preLevelTwo
- 10-16: Level 2
- 17: preLevelThree
- 18-24: Level 3
- 25: preLevelFour
- 26-32: Level 4
- 33: preLevelFive
- 34-40: Level 5
- 41: Game Done
- 42: Music Box
- 43-63: currently unused
- 64: Main Screen

## Level:
- 01: Basic Tutorial (kleiner Höhlenteil in der Mitte)
- 02: Basic mit einer neuen Sache (erster richtiger Level) (100% overworld?)
- 03: Overworld mit Übergang zur Höhle (anspruchsvoller)
- 04: Höhle - knifflig - am Ende Übergang zum letzten Gebiet/Level
- 05: brutal schwer; optisch anders (Castle? Hölle? Spooky?)

## SFX:
- 00: Lead (Pulse 1)
- 01: Lead (Pulse 1) Pitch Slide Up
- 02: Saw
- 03: Hat
- 04: Kick
- 05: Arp058
- 06: Arp047
- 07: Arp049
- 08: Arp058 fade
- 09: Arp038
- 10: Arp039
- 11: Arp036
- 12: Arp039 fade
- 13: Triangle
- 14: Square
- 15: Lead (Pulse 1) Vibrato
- 16: Lead (Pulse 1) Vibrato fade
- 17: Crash
- 18: RevCrash
- 19: Snare

## Music:
- Track 00:
Pattern 01	Beginning1
Pattern 02	Beginning2
Pattern 03	Lead1
Pattern 04	Arps1
Pattern 05	Arps2
Pattern 06	Bass1
Pattern 07	Bass2
Pattern 08	Triangle1
Pattern 09	Lead2
Pattern 10	Noise1
Pattern 11	Bass3
Pattern 12	Triangle2
Pattern 13	Bass4
Pattern 14	Triangle3
Pattern 15	SquareLead1
Pattern 16	SquareLead2
Pattern 17	SquareLead3
Pattern 18	TriangleBridge1
Pattern 19	SquareBridge1
Pattern 20	SawBridge1
Pattern 21	NoiseBridge1
Pattern 22	TriangleBridge2
Pattern 23	SquareBridge3
Pattern 24	SawBridge4
Pattern 25	SawBridge5
Pattern 26	Beginning3
Pattern 27	Beginning4

- Track 01:
Pattern 28	Beginning1
Pattern 29	Beginning2
Pattern 30	Beginning3
Pattern 31	Beginning4
Pattern 32	TriBass
Pattern 33	BeginningTriEnd + Snare
Pattern 34	Crash
Pattern 35	Noise1
Pattern 36	Snare
Pattern 37	Lead1
Pattern 38	Lead2
Pattern 39	Lead3
Pattern 40	Lead4
Pattern 41	Lead4b
Pattern 42	BassFade
Pattern 43	LeadFade

- Track 02:
Pattern 44	Bass1
Pattern 45	Noise1
Pattern 46	Tri+Bass1
Pattern 47	Noise2
Pattern 49	Tri+Bass2
Pattern 51	Tri+Bass3
Pattern 52	Lead1
Pattern 53	Tri+Bass4
Pattern 54	Lead2

- Track 03:
Pattern 03	Lead1
Pattern 06	Bass1
Pattern 07	Bass2
Pattern 09	Lead2
Pattern 10	Noise1
Pattern 11	Bass3
Pattern 13	Bass4
Pattern 15	SquareLead1
Pattern 17	SquareLead3
Pattern 34	Crash
Pattern 36	Snare
Pattern 44	Bass1
Pattern 24	SawBridge4
Pattern 39	Lead3
Pattern 40	Lead4
Pattern 41	Lead4b
Pattern 51	Tri+Bass3

- Track 04:
Pattern 48	Fanfare1
Pattern 50	Noise1
Pattern 55	Bass1
Pattern 56	TriangleRiseUp

- Track 05:
Pattern	09	Lead2

Pattern 57	empty
Pattern 58	empty
Pattern 59	empty
Pattern 60	empty
