#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <WebSocketsServer.h>

// ==============================================================================
// AGON LIGHT 2 -> ESP-12F (UEXT) -> WIRELESS DUAL MONITOR (WEB & PC TCP 23)
// ==============================================================================

const char* ssid = "Agon-Light-WiFi";
const char* password = ""; // Open Wi-Fi AP (geen wachtwoord nodig)

ESP8266WebServer server(80);
WebSocketsServer webSocket = WebSocketsServer(81);
WiFiServer tcpServer(23);
WiFiClient tcpClient;

// HTML5 + CSS + JavaScript Tektronix 4014 Vector & Text WebApp
const char INDEX_HTML[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="nl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Agon Light 2 - Wireless Terminal & Monitor</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #050b06;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      overflow: hidden;
      font-family: monospace;
    }
    #header {
      position: absolute;
      top: 10px;
      left: 15px;
      right: 15px;
      display: flex;
      justify-content: space-between;
      color: #33ff66;
      font-size: 13px;
      opacity: 0.9;
      z-index: 10;
    }
    #screen-container {
      position: relative;
      width: 96vw;
      height: 90vh;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    canvas {
      background: #0a140c;
      border: 2px solid #1a3a20;
      border-radius: 8px;
      box-shadow: 0 0 35px rgba(51, 255, 102, 0.2);
      max-width: 100%;
      max-height: 100%;
      aspect-ratio: 1024 / 780;
      cursor: text;
    }
    #kb-btn {
      background: #112615;
      color: #33ff66;
      border: 1px solid #33ff66;
      padding: 4px 10px;
      border-radius: 4px;
      cursor: pointer;
      font-family: monospace;
    }
    #mobileInput {
      position: absolute;
      opacity: 0;
      pointer-events: none;
      top: 0; left: 0;
    }
  </style>
</head>
<body>
  <div id="header">
    <span id="status">Verbinden met Agon AP...</span>
    <button id="kb-btn" onclick="openKeyboard()">Toetsenbord</button>
  </div>
  <div id="screen-container">
    <canvas id="tekCanvas" width="1024" height="780"></canvas>
  </div>
  <input id="mobileInput" type="text" autocomplete="off" autocapitalize="off" spellcheck="false">

  <script>
    const canvas = document.getElementById('tekCanvas');
    const ctx = canvas.getContext('2d');
    const status = document.getElementById('status');
    const mobileInput = document.getElementById('mobileInput');

    // Gloeiende P31 Phosphor Green instellingen
    ctx.strokeStyle = '#33ff66';
    ctx.fillStyle = '#33ff66';
    ctx.lineWidth = 1.2;
    ctx.shadowBlur = 4;
    ctx.shadowColor = '#33ff66';
    ctx.font = '16px monospace';

    let curX = 20, curY = 30;
    const lineHeight = 20, charWidth = 9.6;

    function clearScreen() {
      ctx.save();
      ctx.shadowBlur = 0;
      ctx.fillStyle = '#0a140c';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.restore();
      curX = 20; curY = 30;
    }
    clearScreen();

    // Tektronix 4014 State Machine & Alpha Terminal
    let mode = 0; // 0=Alpha, 1..4=Move, 5..8=Draw, 30=Esc
    let xh=0, xl=0, yh=0, yl=0, x0=0, y0=0;

    function processByte(ch) {
      if (ch === 0x1B) { mode = 30; return; } // ESC
      if (mode === 30) {
        if (ch === 0x0C) clearScreen(); // ESC FF: Wis scherm
        mode = 0;
        return;
      }
      if (ch === 0x1D) { mode = 1; return; } // GS: Start Vector Mode
      if (ch === 0x1F) { mode = 0; return; } // US: Alpha Mode

      // Vector Coördinaten decoderen (Tektronix 1024x780)
      if (mode >= 1 && mode <= 8) {
        if ((ch & 0xE0) === 0x20) {
          if (mode === 1 || mode === 5) { yh = (ch & 31) << 5; mode++; }
          else if (mode === 3 || mode === 7) { xh = (ch & 31) << 5; mode++; }
        } else if ((ch & 0xE0) === 0x60) {
          yl = (ch & 31); mode++;
        } else if ((ch & 0xE0) === 0x40) {
          xl = (ch & 31);
          let tekX = xh + xl;
          let tekY = yh + yl;
          let x2 = (tekX * 1023) / 1023;
          let y2 = 779 - ((tekY * 779) / 779);

          if (mode === 4) {
            x0 = x2; y0 = y2;
            mode = 5;
          } else {
            ctx.beginPath();
            ctx.moveTo(x0, y0);
            ctx.lineTo(x2, y2);
            ctx.stroke();
            x0 = x2; y0 = y2;
            mode = 5;
          }
        }
        return;
      }

      // Alpha text mode (regular ASCII terminal)
      if (ch === 10) { // LF
        curY += lineHeight;
        if (curY > 750) clearScreen();
      } else if (ch === 13) { // CR
        curX = 20;
      } else if (ch === 8 || ch === 127) { // Backspace
        curX = Math.max(20, curX - charWidth);
        ctx.fillStyle = '#0a140c';
        ctx.fillRect(curX, curY - 14, charWidth, lineHeight);
        ctx.fillStyle = '#33ff66';
      } else if (ch === 12) { // Form feed / CLS
        clearScreen();
      } else if (ch >= 32 && ch < 127) {
        ctx.fillText(String.fromCharCode(ch), curX, curY);
        curX += charWidth;
        if (curX > 1000) {
          curX = 20;
          curY += lineHeight;
          if (curY > 750) clearScreen();
        }
      }
    }

    // WebSocket verbinding opzetten naar ESP-12F
    const ws = new WebSocket('ws://' + window.location.hostname + ':81/');
    ws.binaryType = 'arraybuffer';

    ws.onopen = () => { status.innerText = '● LIVE AGON STREAM (Verbonden)'; };
    ws.onclose = () => { status.innerText = '○ Verbinding verbroken'; };
    ws.onmessage = (event) => {
      const bytes = new Uint8Array(event.data);
      for (let i = 0; i < bytes.length; i++) {
        processByte(bytes[i]);
      }
    };

    function sendStr(str) {
      if (ws.readyState === WebSocket.OPEN) {
        ws.send(str);
      }
    }

    // Toetsenbord afvangen
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') sendStr('\r');
      else if (e.key === 'Backspace') sendStr('\b');
      else if (e.key === 'Escape') sendStr('\x1b');
      else if (e.key === 'Tab') { e.preventDefault(); sendStr('\t'); }
      else if (e.key.length === 1) sendStr(e.key);
    });

    function openKeyboard() {
      mobileInput.focus();
    }
    canvas.addEventListener('click', openKeyboard);
    mobileInput.addEventListener('input', (e) => {
      if (e.data) sendStr(e.data);
      mobileInput.value = '';
    });
  </script>
</body>
</html>
)rawliteral";

void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  if (type == WStype_TEXT || type == WStype_BIN) {
    // Toetsenbordinvoer van tablet/browser doorsturen naar Agon UEXT (Serial)
    Serial.write(payload, length);
  }
}

void setup() {
  Serial.begin(115200);

  // 1. Wi-Fi Access Point starten
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);

  // 2. Webserver routes (Port 80)
  server.on("/", []() {
    server.send_P(200, "text/html", INDEX_HTML);
  });
  server.begin();

  // 3. WebSocket server starten (Port 81)
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);

  // 4. Raw TCP Socket server starten (Port 23 voor agon_monitor.py)
  tcpServer.begin();
  tcpServer.setNoDelay(true);
}

uint8_t rxBuffer[512];

void loop() {
  server.handleClient();
  webSocket.loop();

  // A. TCP Client beheer op poort 23
  if (tcpServer.hasClient()) {
    if (!tcpClient || !tcpClient.connected()) {
      if (tcpClient) tcpClient.stop();
      tcpClient = tcpServer.available();
      tcpClient.setNoDelay(true);
    } else {
      WiFiClient dummy = tcpServer.available();
      dummy.stop();
    }
  }

  // B. Data van TCP client (agon_monitor.py) naar Agon UEXT (Serial) sturen
  if (tcpClient && tcpClient.connected() && tcpClient.available()) {
    while (tcpClient.available()) {
      Serial.write(tcpClient.read());
    }
  }

  // C. Data van Agon UEXT (Serial) lezen en uitzenden naar zowel WebSocket als TCP 23
  int available = Serial.available();
  if (available > 0) {
    int bytesToRead = min(available, (int)sizeof(rxBuffer));
    Serial.readBytes(rxBuffer, bytesToRead);
    
    // Naar browser / tablet via WebSocket
    webSocket.broadcastBIN(rxBuffer, bytesToRead);
    
    // Naar PC monitor via TCP port 23
    if (tcpClient && tcpClient.connected()) {
      tcpClient.write(rxBuffer, bytesToRead);
    }
  }
}
