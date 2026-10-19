# ⚡ NEXUS CLAW V7.4.1
## Hybrid AI Office – Mobile Dashboard

> Eine modulare KI-Steuerzentrale für Android und Desktop mit lokalem Ollama-Modell, Agentenverwaltung, Aufgabensteuerung und einer Grundlage für autonome Entwicklungszyklen.

---

## 📌 Projektinformationen

- **Projekt:** NEXUS CLAW
- **Version:** 7.4.1
- **Projektbereich:** Hybrid AI Office
- **Plattform:** Android, Termux, Desktop-Browser
- **Backend:** Python und Flask
- **Frontend:** HTML, CSS und JavaScript
- **KI-Schnittstelle:** Ollama API
- **Standardmodell:** `qwen2.5-coder:1.5b`
- **Standardport:** `5000`
- **Standardadresse:** `http://127.0.0.1:5000`
- **Projektstatus:** Funktionsfähiger Prototyp, weitere Integration erforderlich

---

## 🎯 1. Projektziel

NEXUS CLAW ist als zentrale Steuerungsoberfläche für ein modulares KI-Agentensystem konzipiert.

Das System soll die Planung, Entwicklung, Analyse, Prüfung und Verbesserung von Software unterstützen.

Die langfristige Vision ist ein KI-gestütztes Entwicklungsbüro, in dem spezialisierte Agenten Aufgaben übernehmen, Ergebnisse überprüfen und Verbesserungen nachvollziehbar dokumentieren.

Die Architektur soll lokale KI-Modelle bevorzugen und externe Dienste nur bei Bedarf und mit entsprechender Konfiguration verwenden.

### Grundprinzipien

1. Lokale Verarbeitung bevorzugen.
2. Module unabhängig entwickeln.
3. Aufgaben systematisch planen.
4. Änderungen vor der Ausführung prüfen.
5. Ergebnisse durch Tests verifizieren.
6. Fehlerursachen analysieren.
7. Änderungen dokumentieren.
8. Berechtigungen und Sicherheitsgrenzen beachten.
9. Autonome Aktionen kontrollierbar gestalten.
10. Keine Änderungen ohne erforderliche Freigabe durchführen.

---

## 🖥️ 2. Dashboard-Funktionen

### 2.1 Übersicht

Die Startseite zeigt die wichtigsten Systembereiche:

- Systemstatus
- Ollama-Verbindung
- KI-Agentenprofile
- Digitale Büroräume
- Aufgabenübersicht
- Loop-Steuerung

Statusanzeigen müssen zwischen tatsächlichen Messwerten und Demo-Daten unterscheiden.

### 2.2 KI-Agenten

Das Dashboard enthält acht vorbereitete Agentenprofile:

| Agent | Schwerpunkt |
|---|---|
| Rick | Strategie und Planung |
| Peter | Kreativität |
| Morty | Recherche |
| Stewie | Entwicklung |
| Lois | Organisation |
| Happy Tree | Ideenentwicklung |
| Evil Morty | Sicherheit |
| Archive | Archivierung |

Die Profile dienen zunächst der Organisation und Darstellung.

Sie sind nicht automatisch acht unabhängig laufende KI-Prozesse.

### 2.3 Digitale Büroräume

Die Oberfläche enthält acht thematische Arbeitsbereiche:

1. NEXUS Leitstelle
2. Planungsraum
3. Entwicklungsraum
4. Recherchebüro
5. Testlabor
6. Sandmann Archiv
7. Sicherheitsbüro
8. Persönliches Büro

Die Räume bilden die organisatorische Struktur des geplanten Agentensystems ab.

### 2.4 Modellzentrale

Die Modellzentrale ermöglicht:

- Ollama-Verbindungsprüfung
- Konfiguration der Ollama-Adresse
- Auswahl eines Modellnamens
- Anzeige verfügbarer lokaler Modelle
- Nutzung des konfigurierten Modells im Chat

Die Kommunikation erfolgt über die Ollama-HTTP-API.

### 2.5 Aufgabenverwaltung

Die Aufgabenverwaltung unterstützt:

- Aufgaben erstellen
- Aufgaben abhaken
- Aufgaben löschen
- Prioritäten festlegen
- Aufgaben lokal in einer JSON-Datei speichern

### 2.6 Lokaler KI-Chat

Der integrierte Chat sendet Anfragen an das konfigurierte Ollama-Modell.

Verwendeter API-Endpunkt:

`/api/generate`

Voraussetzungen:

- Ollama ist erreichbar.
- Das konfigurierte Modell ist installiert.
- Das Modell unterstützt die angefragte Aufgabe.

### 2.7 Notizen

Notizen werden im Browser über `localStorage` gespeichert.

Die Speicherung ist browserspezifisch und nicht automatisch mit anderen Geräten synchronisiert.

### 2.8 Loop-Steuerung

Die Oberfläche besitzt Schaltflächen für:

- Start
- Pause

Im aktuellen Prototyp wird damit lediglich ein Steuerflag gespeichert.

Ein echter autonomer Entwicklungsprozess mit Codeänderungen, Tests und Fehlerbehebung ist noch nicht implementiert.

---

## 🏗️ 3. Projektarchitektur

```text
NEXUS CLAW V7.4.1
│
├── Mobile Dashboard
│   ├── Übersicht
│   ├── Agenten
│   ├── Büroräume
│   ├── Modellzentrale
│   ├── Workflow
│   ├── Bibliothek
│   ├── Skills
│   ├── Aufgaben
│   ├── Chat
│   ├── Notizen
│   └── Einstellungen
│
├── Flask Backend
│   ├── Dashboard-Routen
│   ├── Status-API
│   ├── Aufgaben-API
│   ├── Einstellungs-API
│   ├── Loop-Steuerung
│   └── Ollama-Chat
│
├── Ollama
│   ├── Modellverwaltung
│   ├── Modellstatus
│   └── Textgenerierung
│
├── Lokale Datenspeicherung
│   ├── Aufgaben
│   └── Einstellungen
│
└── Geplante Erweiterungen
    ├── Agenten-Orchestrierung
    ├── Entwicklungs-Loop
    ├── Testautomatisierung
    ├── Fehleranalyse
    ├── Sandbox
    ├── Skill-Verwaltung
    └── Audit-Protokoll