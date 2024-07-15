# kOS Start, Navigation, boost back and landings scripts

This is a small script collection to automatise repetive tasks in Kerbal Space Program.

How to use
* Install kOS mod
* copy these script into Steam\steamapps\common\Kerbal Space Program\Ships\Script

How to use in game
* Add a scriptable unit on booster and select booster.ks or boostBackLanding.ks
    * Use booster.ks for between stages
* Add a scriptable unit on the most up stage and select main.ks or mainBackLanding.ks 


[![Watch the video](https://img.youtube.com/vi/GApod0AL3mQ/hqdefault.jpg)](https://www.youtube.com/watch?v=GApod0AL3mQ)

## Limitations

* The main-Script must be placed at the most upper stage. (Required for fuel detection)

## Overview
Kurzer Überblick über die Skripte
Die Skripte sind für die Steuerung von Raketen und Boostern in Kerbal Space Program mithilfe des kOS-Mods. Die Skripte sind auf verschiedene Aufgaben spezialisiert:

1. `ai-pilot`: Teils von KI geschriebener Code
   - `land.ks`: Berechnet die Höhe für einen Suicide Burn und führt die Landung durch.
   - `launch.ks`: Führt den Start und den Aufstieg in die Umlaufbahn durch.
   - `maneuver.ks`: Führt Manöverknoten aus.

2. `BoostBack`:
   - `boostBack.ks`: Führt den Boost-Back für die Landung eines Boosters durch.
   - `library.ks`: Enthält allgemeine Funktionen für Berechnungen und Initialisierungen.

3. `boot`:
   - Verschiedene Skripte (`ai-pilot.ks`, `booster.ks`, `boosterBackLanding.ks`, `boosterNoDecouple.ks`, `main.ks`, `mainBackLanding.ks`, `mainCenterCore.ks`, `mainPolar.ks`, `satelite.ks`) zum Initialisieren und Ausführen spezifischer Aufgaben wie Start, Landung, Boost-Back und Orbit-Operationen.

4. `exec.ks`: Führt Manöverknoten automatisch aus.
5. `land.ks`: Führt eine Fallschirm-Landung durch, wenn die Rakete keinen Treibstoff mehr hat.
6. `mainLib.ks`: Enthält globale Funktionen und Routinen, die in anderen Skripten verwendet werden.
7. `pland.ks`: Führt eine angetriebene Landung durch.
8. `README.md`: Dokumentation zur Installation und Verwendung der Skripte.
9. `start.ks`: Steuerung des Starts und des Aufstiegs in die Umlaufbahn.
10. `test.ks`: Test-Skript zur Ausgabe von Berechnungen wie Schub-Gewichts-Verhältnis (TWR).

Diese Skripte automatisieren verschiedene Aspekte des Raketenflusses in KSP, von Start und Aufstieg über Manöver bis hin zu verschiedenen Landungstypen.
