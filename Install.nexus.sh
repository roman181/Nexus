#!/bin/bash
# ============================================================
# NEXUS.AI OLLAMA EDITION v1.9 - Termux Komplettinstallation
# ============================================================
# Lokal · Token-frei · Offline · Termux · Ollama · Three.js
# ============================================================

set -e

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logo anzeigen
show_logo() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║   ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗             ║"
    echo "║   ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝             ║"
    echo "║   ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗             ║"
    echo "║   ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║             ║"
    echo "║   ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║             ║"
    echo "║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝             ║"
    echo "║                                                              ║"
    echo "║   █████╗ ██╗    ██████╗ ██╗   ██╗████████╗██╗ ██████╗ ███╗   ██╗"
    echo "║  ██╔══██╗██║    ██╔══██╗╚██╗ ██╔╝╚══██╔══╝██║██╔═══██╗████╗  ██║"
    echo "║  ███████║██║    ██████╔╝ ╚████╔╝    ██║   ██║██║   ██║██╔██╗ ██║"
    echo "║  ██╔══██║██║    ██╔══██╗  ╚██╔╝     ██║   ██║██║   ██║██║╚██╗██║"
    echo "║  ██║  ██║███████╗██████╔╝   ██║      ██║   ██║╚██████╔╝██║ ╚████║"
    echo "║  ╚═╝  ╚═╝╚══════╝╚═════╝    ╚═╝      ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝"
    echo "║                                                              ║"
    echo "║           O L L A M A   E D I T I O N   v1.9                ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Prüfe Termux-Umgebung
check_termux() {
    echo -e "${YELLOW}🔍 Prüfe Termux-Umgebung...${NC}"
    
    if [ ! -d "$HOME" ]; then
        echo -e "${RED}❌ Fehler: Home-Verzeichnis nicht gefunden${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Termux-Umgebung OK${NC}"
}

# Pakete installieren
install_packages() {
    echo -e "${YELLOW}📦 Installiere benötigte Pakete...${NC}"
    
    pkg update -y || { echo -e "${RED}❌ Update fehlgeschlagen${NC}"; exit 1; }
    pkg upgrade -y
    
    pkg install -y python python-pip git nodejs openssl-tool curl wget || {
        echo -e "${RED}❌ Paketinstallation fehlgeschlagen${NC}"
        exit 1
    }
    
    pkg install -y termux-api termux-tools ffmpeg sox ncurses-utils || {
        echo -e "${YELLOW}⚠️  Einige Pakete konnten nicht installiert werden${NC}"
    }
    
    echo -e "${GREEN}✅ Alle Pakete installiert${NC}"
}

# Ollama installieren
install_ollama() {
    echo -e "${YELLOW}🤖 Installiere Ollama...${NC}"
    
    if [ -f "$HOME/ollama" ]; then
        echo -e "${GREEN}✅ Ollama bereits vorhanden${NC}"
        return
    fi
    
    # Architektur erkennen
    ARCH=$(uname -m)
    case $ARCH in
        aarch64|arm64)
            OLLAMA_URL="https://github.com/ollama/ollama/releases/download/v0.5.7/ollama-linux-arm64"
            ;;
        x86_64|amd64)
            OLLAMA_URL="https://github.com/ollama/ollama/releases/download/v0.5.7/ollama-linux-amd64"
            ;;
        *)
            echo -e "${RED}❌ Nicht unterstützte Architektur: $ARCH${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${BLUE}📥 Lade Ollama herunter...${NC}"
    curl -L "$OLLAMA_URL" -o "$HOME/ollama" || {
        echo -e "${RED}❌ Download fehlgeschlagen${NC}"
        exit 1
    }
    
    chmod +x "$HOME/ollama"
    
    # PATH setzen
    export PATH=$PATH:$HOME
    echo 'export PATH=$PATH:$HOME' >> "$HOME/.bashrc"
    
    echo -e "${GREEN}✅ Ollama installiert: $(~/ollama --version 2>/dev/null || echo 'OK')${NC}"
}

# Modelle herunterladen
download_models() {
    echo -e "${YELLOW}📥 Lade Ollama Modelle herunter...${NC}"
    
    # Starte Ollama im Hintergrund
    echo -e "${BLUE}🚀 Starte Ollama Server...${NC}"
    ~/ollama serve > /dev/null 2>&1 &
    sleep 5
    
    # Modelle herunterladen
    MODELS=("llama3.2:1b" "tinyllama:1.1b")
    
    for MODEL in "${MODELS[@]}"; do
        echo -e "${BLUE}📥 Lade $MODEL herunter...${NC}"
        ~/ollama pull "$MODEL" || {
            echo -e "${YELLOW}⚠️  $MODEL konnte nicht geladen werden${NC}"
        }
    done
    
    # Prüfe welches Modell verfügbar ist
    if ~/ollama list | grep -q "llama3.2:1b"; then
        DEFAULT_MODEL="llama3.2:1b"
    elif ~/ollama list | grep -q "tinyllama:1.1b"; then
        DEFAULT_MODEL="tinyllama:1.1b"
    else
        echo -e "${RED}❌ Kein Modell verfügbar${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Modell $DEFAULT_MODEL verfügbar${NC}"
}

# Projekt erstellen
create_project() {
    echo -e "${YELLOW}📁 Erstelle NEXUS.AI Projekt...${NC}"
    
    mkdir -p "$HOME/nexus_workspace/office"
    cd "$HOME/nexus_workspace/office"
    
    # Python-Pakete
    echo -e "${BLUE}📦 Installiere Python-Pakete...${NC}"
    pip install --upgrade pip
    pip install flask flask-cors python-dotenv requests gunicorn gevent psutil
    
    echo -e "${GREEN}✅ Projektstruktur erstellt${NC}"
}

# Dateien erstellen
create_files() {
    echo -e "${YELLOW}📝 Erstelle Projekt-Dateien...${NC}"
    
    cd "$HOME/nexus_workspace/office"
    
    # === app.py ===
    cat > app.py << 'EOFAPP'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from flask import Flask, render_template, request, jsonify, send_from_directory
from flask_cors import CORS
import json
import subprocess
import os
import sys
import requests
import threading
import time

app = Flask(__name__, static_folder='.')
CORS(app)

OLLAMA_URL = "http://localhost:11434"
MODEL_NAME = "llama3.2:1b"

SYSTEM_PROMPT = """Du bist NEXUS.AI, ein intelligenter KI-Assistent.
Antworte kurz und prägnant auf Deutsch.
Sei freundlich und hilfsbereit.
Bei technischen Fragen erkläre verständlich."""

conversations = {}

@app.route('/')
def index():
    return send_from_directory('.', 'index.html')

@app.route('/api/chat', methods=['POST'])
def chat():
    data = request.json
    user_message = data.get('message', '')
    session_id = data.get('session_id', 'default')
    emotion = data.get('emotion', 'neutral')
    
    if not user_message:
        return jsonify({'error': 'Keine Nachricht'}), 400
    
    if session_id not in conversations:
        conversations[session_id] = []
    
    conversations[session_id].append({
        'role': 'user',
        'content': user_message
    })
    
    if len(conversations[session_id]) > 10:
        conversations[session_id] = conversations[session_id][-10:]
    
    try:
        response = requests.post(
            f"{OLLAMA_URL}/api/chat",
            json={
                "model": MODEL_NAME,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    *conversations[session_id]
                ],
                "stream": False,
                "options": {
                    "temperature": 0.7,
                    "num_predict": 256
                }
            },
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            ai_response = result.get('message', {}).get('content', '')
            
            conversations[session_id].append({
                'role': 'assistant',
                'content': ai_response
            })
            
            detected_emotion = detect_emotion(ai_response)
            
            return jsonify({
                'response': ai_response,
                'emotion': detected_emotion,
                'session_id': session_id
            })
        else:
            return jsonify({'error': f'Ollama Fehler: {response.status_code}'}), 500
            
    except requests.exceptions.ConnectionError:
        return jsonify({'error': 'Ollama Server nicht erreichbar'}), 503
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def detect_emotion(text):
    text_lower = text.lower()
    happy_words = ['ja', 'super', 'toll', 'fantastisch', 'freut', 'danke', 'gerne', 'glücklich']
    sad_words = ['leider', 'traurig', 'schade', 'vermisst', 'depressiv']
    angry_words = ['wütend', 'genervt', 'frustriert', 'ärgerlich']
    surprised_words = ['überrascht', 'unglaublich', 'wow', 'krass']
    
    if any(word in text_lower for word in happy_words):
        return 'happy'
    elif any(word in text_lower for word in sad_words):
        return 'sad'
    elif any(word in text_lower for word in angry_words):
        return 'angry'
    elif any(word in text_lower for word in surprised_words):
        return 'surprised'
    return 'neutral'

@app.route('/api/emotion', methods=['POST'])
def set_emotion():
    data = request.json
    emotion = data.get('emotion', 'neutral')
    return jsonify({'emotion': emotion, 'status': 'ok'})

@app.route('/api/hardware', methods=['GET'])
def get_hardware():
    info = {}
    try:
        result = subprocess.run(
            ['termux-battery-status'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            info['battery'] = json.loads(result.stdout)
    except:
        pass
    
    try:
        result = subprocess.run(
            ['termux-location'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            info['location'] = json.loads(result.stdout)
    except:
        pass
    
    return jsonify(info)

@app.route('/api/tts', methods=['POST'])
def tts():
    data = request.json
    text = data.get('text', '')
    if not text:
        return jsonify({'error': 'Kein Text'}), 400
    try:
        subprocess.run(
            ['termux-tts-speak', text],
            capture_output=True,
            text=True,
            timeout=10
        )
        return jsonify({'status': 'ok'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/clear', methods=['POST'])
def clear_conversation():
    data = request.json
    session_id = data.get('session_id', 'default')
    if session_id in conversations:
        conversations[session_id] = []
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    port = 8080
    print(f"""
    ╔══════════════════════════════════════════════╗
    ║     NEXUS.AI OLLAMA EDITION v1.9           ║
    ║     Server läuft auf http://localhost:{port} ║
    ║     Ollama: {OLLAMA_URL}                     ║
    ║     Modell: {MODEL_NAME}                     ║
    ╚══════════════════════════════════════════════╝
    """)
    app.run(host='0.0.0.0', port=port, debug=False, threaded=True)
EOFAPP

    # === index.html ===
    cat > index.html << 'EOFHTML'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>NEXUS.AI - Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #0a0a0f;
            color: #e0e0e0;
            min-height: 100vh;
            padding: 16px;
        }
        .container { max-width: 800px; margin: 0 auto; }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px 0;
            border-bottom: 1px solid #1a1a2e;
            margin-bottom: 20px;
        }
        .header h1 {
            font-size: 20px;
            background: linear-gradient(135deg, #00d4ff, #7b2ffc);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .status-badge {
            font-size: 12px;
            padding: 4px 12px;
            border-radius: 20px;
            background: #00d4ff20;
            color: #00d4ff;
            border: 1px solid #00d4ff40;
        }
        .avatar-card {
            background: linear-gradient(135deg, #0f0f1a, #1a0a2e);
            border-radius: 16px;
            padding: 24px;
            text-align: center;
            margin-bottom: 20px;
            border: 1px solid #2a1a4e;
            position: relative;
            overflow: hidden;
        }
        .avatar-card::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, #7b2ffc10, transparent 70%);
            animation: rotate 20s linear infinite;
        }
        @keyframes rotate {
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
        }
        .avatar-preview { position: relative; z-index: 1; }
        .avatar-preview .emoji { font-size: 72px; display: block; margin-bottom: 8px; transition: transform 0.3s; }
        .avatar-preview .emoji:hover { transform: scale(1.1); }
        .avatar-preview .name { font-size: 18px; font-weight: 600; color: #fff; }
        .avatar-preview .emotion-label { font-size: 14px; color: #888; margin-top: 4px; }
        .chat-container {
            background: #0f0f1a;
            border-radius: 16px;
            border: 1px solid #1a1a2e;
            padding: 16px;
            margin-bottom: 16px;
            height: 300px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }
        .chat-container::-webkit-scrollbar { width: 4px; }
        .chat-container::-webkit-scrollbar-track { background: #0a0a0f; }
        .chat-container::-webkit-scrollbar-thumb { background: #2a1a4e; border-radius: 4px; }
        .message {
            max-width: 80%;
            padding: 10px 14px;
            border-radius: 12px;
            margin-bottom: 8px;
            animation: fadeIn 0.3s ease;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .message.user {
            align-self: flex-end;
            background: linear-gradient(135deg, #7b2ffc, #00d4ff);
            color: #fff;
        }
        .message.assistant {
            align-self: flex-start;
            background: #1a1a2e;
            border: 1px solid #2a2a4e;
        }
        .message .time { font-size: 10px; opacity: 0.5; margin-top: 4px; display: block; }
        .input-container {
            display: flex;
            gap: 8px;
            margin-bottom: 16px;
        }
        .input-container input {
            flex: 1;
            padding: 12px 16px;
            border-radius: 12px;
            border: 1px solid #1a1a2e;
            background: #0f0f1a;
            color: #e0e0e0;
            font-size: 14px;
            outline: none;
            transition: border-color 0.3s;
        }
        .input-container input:focus { border-color: #7b2ffc; }
        .input-container input::placeholder { color: #555; }
        .btn {
            padding: 12px 20px;
            border: none;
            border-radius: 12px;
            background: linear-gradient(135deg, #7b2ffc, #00d4ff);
            color: #fff;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, opacity 0.2s;
            font-size: 14px;
        }
        .btn:active { transform: scale(0.95); }
        .btn-secondary { background: #1a1a2e; border: 1px solid #2a2a4e; }
        .btn-danger { background: #ff2d55; }
        .btn-success { background: #34c759; }
        .btn:disabled { opacity: 0.5; transform: none; }
        .btn-group {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            margin-bottom: 16px;
        }
        .btn-group .btn {
            flex: 1;
            min-width: 60px;
            text-align: center;
            padding: 8px 12px;
            font-size: 12px;
        }
        .hardware-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 8px;
            margin-bottom: 16px;
        }
        .hardware-card {
            background: #0f0f1a;
            border: 1px solid #1a1a2e;
            border-radius: 12px;
            padding: 12px;
            text-align: center;
        }
        .hardware-card .icon { font-size: 24px; margin-bottom: 4px; }
        .hardware-card .value { font-size: 14px; font-weight: 600; color: #00d4ff; }
        .hardware-card .label { font-size: 10px; color: #666; text-transform: uppercase; }
        .typing-indicator {
            display: none;
            align-self: flex-start;
            padding: 10px 14px;
            background: #1a1a2e;
            border-radius: 12px;
            border: 1px solid #2a2a4e;
            margin-bottom: 8px;
        }
        .typing-indicator.active { display: block; }
        .typing-dots { display: flex; gap: 4px; }
        .typing-dots span {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: #7b2ffc;
            animation: bounce 1.4s infinite;
        }
        .typing-dots span:nth-child(2) { animation-delay: 0.2s; }
        .typing-dots span:nth-child(3) { animation-delay: 0.4s; }
        @keyframes bounce {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-6px); }
        }
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 8px;
            margin-bottom: 16px;
        }
        .quick-actions .btn { padding: 8px; font-size: 12px; }
        @media (max-width: 480px) {
            .header h1 { font-size: 16px; }
            .avatar-preview .emoji { font-size: 48px; }
            .chat-container { height: 200px; }
            .btn-group .btn { font-size: 10px; padding: 6px 8px; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>✦ NEXUS.AI</h1>
            <span class="status-badge" id="statusBadge">● Online</span>
        </div>
        <div class="avatar-card">
            <div class="avatar-preview">
                <span class="emoji" id="avatarEmoji">🤖</span>
                <div class="name">NEXUS</div>
                <div class="emotion-label" id="emotionLabel">Emotion: neutral</div>
            </div>
        </div>
        <div class="quick-actions">
            <button class="btn btn-secondary" onclick="setEmotion('happy')">😊 Happy</button>
            <button class="btn btn-secondary" onclick="setEmotion('sad')">😢 Sad</button>
            <button class="btn btn-secondary" onclick="setEmotion('angry')">😠 Angry</button>
            <button class="btn btn-secondary" onclick="setEmotion('surprised')">😲 Surprised</button>
        </div>
        <div class="hardware-grid" id="hardwareGrid">
            <div class="hardware-card">
                <div class="icon">🔋</div>
                <div class="value" id="batteryValue">--</div>
                <div class="label">Battery</div>
            </div>
            <div class="hardware-card">
                <div class="icon">📍</div>
                <div class="value" id="locationValue">--</div>
                <div class="label">Location</div>
            </div>
            <div class="hardware-card">
                <div class="icon">📶</div>
                <div class="value" id="wifiValue">--</div>
                <div class="label">WLAN</div>
            </div>
        </div>
        <div class="chat-container" id="chatContainer">
            <div class="message assistant">
                Hallo! Ich bin NEXUS.AI. Wie kann ich dir helfen?
                <span class="time">Jetzt</span>
            </div>
            <div class="typing-indicator" id="typingIndicator">
                <div class="typing-dots"><span></span><span></span><span></span></div>
            </div>
        </div>
        <div class="input-container">
            <input type="text" id="messageInput" placeholder="Nachricht eingeben..." onkeydown="if(event.key==='Enter') sendMessage()">
            <button class="btn" onclick="sendMessage()">Senden</button>
            <button class="btn btn-danger" onclick="clearChat()" style="padding: 12px 14px;">✕</button>
        </div>
        <div class="btn-group">
            <button class="btn btn-success" onclick="speakLastResponse()">🔊 Vorlesen</button>
            <button class="btn btn-secondary" onclick="open3DAvatar()">🎮 3D Avatar</button>
            <button class="btn btn-secondary" onclick="refreshHardware()">🔄 Refresh</button>
        </div>
    </div>
    <script>
        const sessionId = 'termux_' + Date.now();
        const emotionEmojis = { 'neutral': '🤖', 'happy': '😊', 'sad': '😢', 'angry': '😠', 'surprised': '😲' };
        let lastResponse = '';
        let isProcessing = false;
        const chatContainer = document.getElementById('chatContainer');
        const messageInput = document.getElementById('messageInput');
        const typingIndicator = document.getElementById('typingIndicator');
        const avatarEmoji = document.getElementById('avatarEmoji');
        const emotionLabel = document.getElementById('emotionLabel');
        
        async function sendMessage() {
            const message = messageInput.value.trim();
            if (!message || isProcessing) return;
            messageInput.value = '';
            isProcessing = true;
            addMessage(message, 'user');
            typingIndicator.classList.add('active');
            scrollToBottom();
            try {
                const response = await fetch('/api/chat', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message, session_id: sessionId, emotion: getCurrentEmotion() })
                });
                const data = await response.json();
                typingIndicator.classList.remove('active');
                if (data.error) {
                    addMessage('❌ ' + data.error, 'assistant');
                } else {
                    const aiResponse = data.response || 'Ich habe keine Antwort.';
                    lastResponse = aiResponse;
                    addMessage(aiResponse, 'assistant');
                    if (data.emotion) setEmotion(data.emotion);
                }
            } catch (error) {
                typingIndicator.classList.remove('active');
                addMessage('❌ Verbindungsfehler zum Server', 'assistant');
            }
            isProcessing = false;
            scrollToBottom();
        }
        
        function addMessage(text, type) {
            const div = document.createElement('div');
            div.className = `message ${type}`;
            div.innerHTML = text;
            const time = document.createElement('span');
            time.className = 'time';
            time.textContent = new Date().toLocaleTimeString();
            div.appendChild(time);
            chatContainer.insertBefore(div, typingIndicator);
        }
        
        function scrollToBottom() { chatContainer.scrollTop = chatContainer.scrollHeight; }
        function getCurrentEmotion() { return emotionLabel.textContent.replace('Emotion: ', ''); }
        
        async function setEmotion(emotion) {
            try {
                await fetch('/api/emotion', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ emotion })
                });
                avatarEmoji.textContent = emotionEmojis[emotion] || '🤖';
                emotionLabel.textContent = `Emotion: ${emotion}`;
            } catch (error) { console.error('Emotion error:', error); }
        }
        
        async function clearChat() {
            try {
                await fetch('/api/clear', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ session_id: sessionId })
                });
                document.querySelectorAll('.message').forEach(m => m.remove());
                addMessage('Hallo! Ich bin NEXUS.AI. Wie kann ich dir helfen?', 'assistant');
            } catch (error) { console.error('Clear error:', error); }
        }
        
        async function speakLastResponse() {
            if (!lastResponse) return;
            try {
                await fetch('/api/tts', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ text: lastResponse })
                });
            } catch (error) { console.error('TTS error:', error); }
        }
        
        async function refreshHardware() {
            try {
                const response = await fetch('/api/hardware');
                const data = await response.json();
                if (data.battery) document.getElementById('batteryValue').textContent = data.battery.percentage + '%';
                if (data.location) {
                    const loc = data.location;
                    document.getElementById('locationValue').textContent = loc.latitude?.toFixed(2) + '° ' + loc.longitude?.toFixed(2) + '°';
                }
            } catch (error) { console.error('Hardware error:', error); }
        }
        
        function open3DAvatar() { window.open('/nexus_3d_avatars_v2.html', '_blank'); }
        
        setInterval(refreshHardware, 30000);
        refreshHardware();
        messageInput.focus();
    </script>
</body>
</html>
EOFHTML

    # === nexus_3d_avatars_v2.html ===
    cat > nexus_3d_avatars_v2.html << 'EOF3D'
<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>NEXUS 3D Avatar v1.9</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { background: #0a0a0f; overflow: hidden; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; color: #fff; }
        #canvas-container { width: 100vw; height: 100vh; display: block; }
        .controls {
            position: fixed;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            display: flex;
            gap: 10px;
            background: rgba(10, 10, 15, 0.85);
            padding: 12px 20px;
            border-radius: 16px;
            border: 1px solid #1a1a2e;
            backdrop-filter: blur(20px);
            flex-wrap: wrap;
            justify-content: center;
            max-width: 90%;
            z-index: 10;
        }
        .controls button {
            padding: 8px 16px;
            border: none;
            border-radius: 10px;
            background: linear-gradient(135deg, #7b2ffc, #00d4ff);
            color: #fff;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
            font-size: 12px;
        }
        .controls button:active { transform: scale(0.95); }
        .controls button.secondary { background: #1a1a2e; border: 1px solid #2a2a4e; }
        .controls button.danger { background: #ff2d55; }
        .controls .status { color: #888; font-size: 11px; display: flex; align-items: center; gap: 6px; padding: 0 10px; }
        .controls .status .dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; }
        .dot.online { background: #34c759; }
        .dot.offline { background: #ff2d55; }
        .emotion-selector { display: flex; gap: 4px; }
        .emotion-selector button { padding: 6px 10px; font-size: 14px; min-width: 36px; }
        @media (max-width: 480px) {
            .controls { padding: 8px 12px; gap: 6px; bottom: 10px; }
            .controls button { padding: 6px 10px; font-size: 10px; }
            .controls .status { font-size: 9px; }
        }
        .mic-indicator {
            position: fixed;
            top: 20px;
            right: 20px;
            background: rgba(10, 10, 15, 0.85);
            padding: 8px 16px;
            border-radius: 12px;
            border: 1px solid #1a1a2e;
            font-size: 12px;
            z-index: 10;
            backdrop-filter: blur(10px);
        }
        .mic-indicator .active { color: #34c759; }
    </style>
</head>
<body>
    <div id="canvas-container"></div>
    <div class="mic-indicator" id="micIndicator">🎤 <span id="micStatus" class="inactive">Inaktiv</span></div>
    <div class="controls">
        <div class="status"><span class="dot online" id="statusDot"></span><span id="statusText">Online</span></div>
        <div class="emotion-selector">
            <button onclick="setEmotion('happy')">😊</button>
            <button onclick="setEmotion('sad')">😢</button>
            <button onclick="setEmotion('angry')">😠</button>
            <button onclick="setEmotion('surprised')">😲</button>
            <button onclick="setEmotion('neutral')">😐</button>
        </div>
        <button onclick="toggleMic()" id="micBtn">🎤 Mikrofon</button>
        <button onclick="speakTest()">🔊 Test</button>
        <button onclick="window.close()" class="danger">✕ Schließen</button>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script>
        let scene, camera, renderer;
        let avatar, head, leftEye, rightEye, leftBrow, rightBrow, mouth;
        let isMicActive = false;
        let audioContext, analyser, dataArray;
        let currentEmotion = 'neutral';
        let isSpeaking = false;
        
        const emotionSettings = {
            neutral: { browY: 0, eyeOpen: 1, mouthOpen: 0, smile: 0, browAngle: 0 },
            happy: { browY: 0.3, eyeOpen: 0.9, mouthOpen: 0.1, smile: 0.5, browAngle: 0.1 },
            sad: { browY: -0.2, eyeOpen: 0.7, mouthOpen: 0, smile: -0.3, browAngle: -0.15 },
            angry: { browY: -0.4, eyeOpen: 0.6, mouthOpen: 0.05, smile: -0.2, browAngle: -0.2 },
            surprised: { browY: 0.5, eyeOpen: 1.2, mouthOpen: 0.4, smile: 0.1, browAngle: 0.2 }
        };
        
        let targetEmotion = { ...emotionSettings.neutral };
        let currentMorph = { ...emotionSettings.neutral };
        let targetHeadRotation = { x: 0, y: 0 };
        let lastTime = 0;
        
        function initThree() {
            const container = document.getElementById('canvas-container');
            scene = new THREE.Scene();
            scene.background = new THREE.Color(0x0a0a0f);
            camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, 0.1, 100);
            camera.position.set(0, 0.2, 2.5);
            camera.lookAt(0, 0, 0);
            renderer = new THREE.WebGLRenderer({ antialias: true });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
            renderer.shadowMap.enabled = true;
            renderer.toneMapping = THREE.ACESFilmicToneMapping;
            renderer.toneMappingExposure = 1.2;
            container.appendChild(renderer.domElement);
            
            const ambientLight = new THREE.AmbientLight(0x222244, 0.5);
            scene.add(ambientLight);
            const keyLight = new THREE.DirectionalLight(0xffeedd, 1.2);
            keyLight.position.set(2, 3, 4);
            keyLight.castShadow = true;
            scene.add(keyLight);
            const fillLight = new THREE.DirectionalLight(0x4488ff, 0.6);
            fillLight.position.set(-2, 1, 2);
            scene.add(fillLight);
            const rimLight = new THREE.DirectionalLight(0x7b2ffc, 0.8);
            rimLight.position.set(-1, 0.5, -3);
            scene.add(rimLight);
            
            createParticles();
            createAvatar();
            
            window.addEventListener('resize', onResize);
            window.addEventListener('mousemove', onMouseMove);
            window.addEventListener('touchmove', onTouchMove);
            animate();
        }
        
        function createParticles() {
            const geometry = new THREE.BufferGeometry();
            const count = 500;
            const positions = new Float32Array(count * 3);
            for (let i = 0; i < count * 3; i++) positions[i] = (Math.random() - 0.5) * 10;
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            const material = new THREE.PointsMaterial({ color: 0x7b2ffc, size: 0.008, transparent: true, opacity: 0.6, blending: THREE.AdditiveBlending });
            const particles = new THREE.Points(geometry, material);
            particles.position.z = -3;
            scene.add(particles);
        }
        
        function createAvatar() {
            avatar = new THREE.Group();
            const headGeo = new THREE.SphereGeometry(0.45, 32, 32);
            const headMat = new THREE.MeshStandardMaterial({ color: 0xf5d0b8, roughness: 0.4, metalness: 0.05, emissive: new THREE.Color(0x1a0a2e), emissiveIntensity: 0.1 });
            head = new THREE.Mesh(headGeo, headMat);
            head.scale.y = 1.1;
            head.castShadow = true;
            avatar.add(head);
            createEyes();
            createEyebrows();
            createMouth();
            createNose();
            createNeck();
            scene.add(avatar);
        }
        
        function createEyes() {
            const eyeWhiteGeo = new THREE.SphereGeometry(0.12, 16, 16);
            const eyeWhiteMat = new THREE.MeshStandardMaterial({ color: 0xf5f5ff, roughness: 0.1, metalness: 0 });
            const irisGeo = new THREE.SphereGeometry(0.07, 16, 16);
            const irisMat = new THREE.MeshStandardMaterial({ color: 0x4a7aff, roughness: 0.2, metalness: 0.1, emissive: new THREE.Color(0x4a7aff), emissiveIntensity: 0.3 });
            const pupilGeo = new THREE.SphereGeometry(0.03, 8, 8);
            const pupilMat = new THREE.MeshStandardMaterial({ color: 0x111111, roughness: 0 });
            
            const leftEyeGroup = new THREE.Group();
            const leftWhite = new THREE.Mesh(eyeWhiteGeo, eyeWhiteMat);
            leftWhite.scale.set(1, 0.9, 0.7);
            leftEyeGroup.add(leftWhite);
            const leftIris = new THREE.Mesh(irisGeo, irisMat);
            leftIris.position.set(0, 0, 0.1);
            leftIris.scale.set(0.9, 0.9, 0.5);
            leftEyeGroup.add(leftIris);
            const leftPupil = new THREE.Mesh(pupilGeo, pupilMat);
            leftPupil.position.set(0, 0, 0.13);
            leftEyeGroup.add(leftPupil);
            leftEyeGroup.position.set(-0.17, 0.08, 0.38);
            leftEye = leftEyeGroup;
            avatar.add(leftEyeGroup);
            
            const rightEyeGroup = new THREE.Group();
            const rightWhite = new THREE.Mesh(eyeWhiteGeo, eyeWhiteMat);
            rightWhite.scale.set(1, 0.9, 0.7);
            rightEyeGroup.add(rightWhite);
            const rightIris = new THREE.Mesh(irisGeo, irisMat);
            rightIris.position.set(0, 0, 0.1);
            rightIris.scale.set(0.9, 0.9, 0.5);
            rightEyeGroup.add(rightIris);
            const rightPupil = new THREE.Mesh(pupilGeo, pupilMat);
            rightPupil.position.set(0, 0, 0.13);
            rightEyeGroup.add(rightPupil);
            rightEyeGroup.position.set(0.17, 0.08, 0.38);
            rightEye = rightEyeGroup;
            avatar.add(rightEyeGroup);
        }
        
        function createEyebrows() {
            const browMat = new THREE.MeshStandardMaterial({ color: 0x3d2817, roughness: 0.8 });
            const browGroup = new THREE.Group();
            const brow = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.02, 0.04), browMat);
            brow.position.set(0, 0, 0);
            browGroup.add(brow);
            for (let i = -2; i <= 2; i++) {
                const hair = new THREE.Mesh(new THREE.BoxGeometry(0.02, 0.01, 0.015), browMat);
                hair.position.set(i * 0.025, 0.015 + Math.random() * 0.01, 0);
                hair.rotation.z = (i * 0.08) + (Math.random() - 0.5) * 0.1;
                browGroup.add(hair);
            }
            browGroup.position.set(-0.18, 0.18, 0.42);
            browGroup.rotation.z = 0.1;
            leftBrow = browGroup;
            avatar.add(browGroup);
            
            const rightBrowGroup = new THREE.Group();
            const rightBrow = new THREE.Mesh(new THREE.BoxGeometry(0.12, 0.02, 0.04), browMat);
            rightBrow.position.set(0, 0, 0);
            rightBrowGroup.add(rightBrow);
            for (let i = -2; i <= 2; i++) {
                const hair = new THREE.Mesh(new THREE.BoxGeometry(0.02, 0.01, 0.015), browMat);
                hair.position.set(i * 0.025, 0.015 + Math.random() * 0.01, 0);
                hair.rotation.z = (i * 0.08) + (Math.random() - 0.5) * 0.1;
                rightBrowGroup.add(hair);
            }
            rightBrowGroup.position.set(0.18, 0.18, 0.42);
            rightBrowGroup.rotation.z = -0.1;
            rightBrow = rightBrowGroup;
            avatar.add(rightBrowGroup);
        }
        
        function createMouth() {
            const mouthGroup = new THREE.Group();
            const lipMat = new THREE.MeshStandardMaterial({ color: 0xcc8899, roughness: 0.6, metalness: 0.1 });
            const upperLipGeo = new THREE.SphereGeometry(0.06, 8, 8, 0, Math.PI * 2, 0, Math.PI / 2);
            const upperLip = new THREE.Mesh(upperLipGeo, lipMat);
            upperLip.scale.set(1, 0.4, 0.4);
            upperLip.position.set(0, 0.02, 0);
            mouthGroup.add(upperLip);
            const lowerLipGeo = new THREE.SphereGeometry(0.06, 8, 8, 0, Math.PI * 2, Math.PI / 2, Math.PI / 2);
            const lowerLip = new THREE.Mesh(lowerLipGeo, lipMat);
            lowerLip.scale.set(1, 0.3, 0.4);
            lowerLip.position.set(0, -0.02, 0);
            mouthGroup.add(lowerLip);
            const line = new THREE.Mesh(new THREE.BoxGeometry(0.08, 0.01, 0.01), new THREE.MeshStandardMaterial({ color: 0xaa7788, roughness: 0.8 }));
            mouthGroup.add(line);
            mouthGroup.position.set(0, -0.08, 0.42);
            mouth = mouthGroup;
            avatar.add(mouthGroup);
        }
        
        function createNose() {
            const noseGroup = new THREE.Group();
            const noseMat = new THREE.MeshStandardMaterial({ color: 0xf0c8b0, roughness: 0.6 });
            const bridge = new THREE.Mesh(new THREE.BoxGeometry(0.04, 0.02, 0.06), noseMat);
            bridge.position.set(0, 0.06, 0.02);
            noseGroup.add(bridge);
            const tip = new THREE.Mesh(new THREE.SphereGeometry(0.025, 8, 8), noseMat);
            tip.position.set(0, 0.04, 0.06);
            noseGroup.add(tip);
            noseGroup.position.set(0, 0.04, 0.4);
            avatar.add(noseGroup);
        }
        
        function createNeck() {
            const neck = new THREE.Mesh(
                new THREE.CylinderGeometry(0.15, 0.2, 0.15, 8),
                new THREE.MeshStandardMaterial({ color: 0xf0c8b0, roughness: 0.6 })
            );
            neck.position.set(0, -0.35, 0);
            avatar.add(neck);
        }
        
        function setEmotion(emotion) {
            currentEmotion = emotion;
            targetEmotion = { ...emotionSettings[emotion] };
            document.getElementById('statusText').textContent = `Emotion: ${emotion}`;
        }
        
        function updateMorphTargets(delta) {
            const lerpSpeed = 8 * delta;
            currentMorph.browY += (targetEmotion.browY - currentMorph.browY) * lerpSpeed;
            currentMorph.eyeOpen += (targetEmotion.eyeOpen - currentMorph.eyeOpen) * lerpSpeed;
            currentMorph.mouthOpen += (targetEmotion.mouthOpen - currentMorph.mouthOpen) * lerpSpeed;
            currentMorph.smile += (targetEmotion.smile - currentMorph.smile) * lerpSpeed;
            currentMorph.browAngle += (targetEmotion.browAngle - currentMorph.browAngle) * lerpSpeed;
            
            if (leftEye && rightEye) {
                const eyeScaleY = 0.7 + (1 - currentMorph.eyeOpen) * 0.3;
                leftEye.scale.y = eyeScaleY;
                rightEye.scale.y = eyeScaleY;
            }
            if (leftBrow && rightBrow) {
                const browHeight = 0.18 + currentMorph.browY * 0.08;
                leftBrow.position.y = browHeight;
                rightBrow.position.y = browHeight;
                leftBrow.rotation.z = 0.1 + currentMorph.browAngle;
                rightBrow.rotation.z = -0.1 - currentMorph.browAngle;
            }
            if (mouth) {
                const mouthScaleY = 0.3 + currentMorph.mouthOpen * 0.5 + currentMorph.smile * 0.1;
                mouth.scale.y = Math.max(0.1, mouthScaleY);
                mouth.position.y = -0.08 + currentMorph.smile * 0.02;
            }
        }
        
        function initAudio() {
            try {
                audioContext = new (window.AudioContext || window.webkitAudioContext)();
                analyser = audioContext.createAnalyser();
                analyser.fftSize = 256;
                dataArray = new Uint8Array(analyser.frequencyBinCount);
                return true;
            } catch (e) { return false; }
        }
        
        async function startMic() {
            if (!audioContext && !initAudio()) { alert('Audio nicht verfügbar!'); return; }
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                const source = audioContext.createMediaStreamSource(stream);
                source.connect(analyser);
                isMicActive = true;
                document.getElementById('micStatus').textContent = 'Aktiv';
                document.getElementById('micStatus').className = 'active';
                document.getElementById('micBtn').textContent = '⏹ Stopp';
                processAudio();
            } catch (e) {
                alert('Mikrofon Zugriff verweigert!');
            }
        }
        
        function stopMic() {
            isMicActive = false;
            document.getElementById('micStatus').textContent = 'Inaktiv';
            document.getElementById('micStatus').className = 'inactive';
            document.getElementById('micBtn').textContent = '🎤 Mikrofon';
            if (currentEmotion === 'neutral') targetEmotion = { ...emotionSettings.neutral };
        }
        
        function toggleMic() {
            isMicActive ? stopMic() : startMic();
        }
        
        function processAudio() {
            if (!isMicActive || !analyser) return;
            analyser.getByteFrequencyData(dataArray);
            let sum = 0, len = dataArray.length;
            for (let i = 0; i < len; i++) sum += dataArray[i] / 255;
            const volume = sum / len;
            if (volume > 0.15) {
                targetEmotion.mouthOpen = Math.min(0.8, volume * 2.5);
            } else if (currentEmotion === 'neutral' || currentEmotion === 'surprised') {
                targetEmotion.mouthOpen = 0.05;
            }
            requestAnimationFrame(processAudio);
        }
        
        async function speak(text) {
            if (isSpeaking) return;
            isSpeaking = true;
            try {
                const response = await fetch('/api/tts', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ text })
                });
                if (response.ok) {
                    let duration = Math.min(3, text.length / 15 + 0.5);
                    let elapsed = 0;
                    targetEmotion.mouthOpen = 0.3;
                    const lipSyncInterval = setInterval(() => {
                        elapsed += 0.05;
                        if (elapsed < duration * 0.8) {
                            targetEmotion.mouthOpen = 0.2 + Math.random() * 0.5;
                        } else {
                            targetEmotion.mouthOpen = Math.max(0.05, targetEmotion.mouthOpen - 0.03);
                        }
                        if (elapsed >= duration) {
                            clearInterval(lipSyncInterval);
                            targetEmotion.mouthOpen = 0.05;
                            isSpeaking = false;
                        }
                    }, 50);
                    setTimeout(() => { clearInterval(lipSyncInterval); targetEmotion.mouthOpen = 0.05; isSpeaking = false; }, duration * 1000 + 1000);
                }
            } catch (e) { isSpeaking = false; }
        }
        
        function speakTest() { speak('Hallo, ich bin dein NEXUS 3D Avatar. Schön dich zu sehen!'); }
        function onMouseMove(e) { updateHeadRotation((e.clientX / window.innerWidth) * 2 - 1, -(e.clientY / window.innerHeight) * 2 + 1); }
        function onTouchMove(e) { if (e.touches.length > 0) { const t = e.touches[0]; updateHeadRotation((t.clientX / window.innerWidth) * 2 - 1, -(t.clientY / window.innerHeight) * 2 + 1); } }
        function updateHeadRotation(x, y) { targetHeadRotation.x = x * 0.15; targetHeadRotation.y = y * 0.1; }
        
        function animate() {
            const time = performance.now() / 1000;
            const delta = Math.min(0.05, time - lastTime);
            lastTime = time;
            if (avatar) {
                avatar.rotation.y += (targetHeadRotation.x - avatar.rotation.y) * 4 * delta;
                avatar.rotation.x += (targetHeadRotation.y - avatar.rotation.x) * 4 * delta;
            }
            updateMorphTargets(delta);
            renderer.render(scene, camera);
            requestAnimationFrame(animate);
        }
        
        function onResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(window.innerWidth, window.innerHeight);
        }
        
        initThree();
        window.setEmotion = setEmotion;
        window.toggleMic = toggleMic;
        window.speak = speak;
        window.speakTest = speakTest;
    </script>
</body>
</html>
EOF3D

    # === start_all.sh ===
    cat > start_all.sh << 'EOFSTART'
#!/bin/bash
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     NEXUS.AI OLLAMA EDITION v1.9 - Termux Start            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
cd ~/nexus_workspace/office

if pgrep -f "ollama serve" > /dev/null; then
    echo "✅ Ollama läuft bereits"
else
    echo "🚀 Starte Ollama..."
    ~/ollama serve &
    sleep 3
fi

if ~/ollama list | grep -q "llama3.2:1b"; then
    echo "✅ Modell verfügbar"
else
    echo "📥 Lade Modell..."
    ~/ollama pull llama3.2:1b
fi

echo "🚀 Starte NEXUS.AI Server auf http://localhost:8080"
python app.py
EOFSTART

    chmod +x start_all.sh
    
    echo -e "${GREEN}✅ Alle Dateien erstellt${NC}"
}

# Abschluss
finish_installation() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║     🎉 NEXUS.AI OLLAMA EDITION v1.9 installiert!            ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║     Starte mit: bash ~/nexus_workspace/office/start_all.sh  ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║     Öffne im Browser: http://localhost:8080                 ║${NC}"
    echo -e "${GREEN}║     3D Avatar: http://localhost:8080/nexus_3d_avatars_v2.html${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Hauptfunktion
main() {
    show_logo
    check_termux
    install_packages
    install_ollama
    download_models
    create_project
    create_files
    finish_installation
}

# Ausführen
main "$@"