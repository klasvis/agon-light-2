#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <WebSocketsServer.h>

// ==============================================================================
// AGON LIGHT 2 -> ESP-12F (UEXT) -> TABLET TEKTRONIX 4014 WIRELESS MONITOR
// ==============================================================================

const char* ssid = "Agon-Tektronix";
const char* password = ""; // Open Wi-Fi AP for easy connecting

ESP8266WebServer server(80);
WebSocketsServer webSocket = WebSocketsServer(81);

// HTML5 + CSS + JavaScript Tektronix 4014 Vector WebApp
const char INDEX_HTML[] PROGMEM = R"rawliteral(
<!DOCTYPE html>
<html lang="nl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Agon Light - Tektronix 4014 Display</title>
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
    #status {
      position: absolute;
      top: 10px;
      left: 15px;
      color: #33ff66;
      font-size: 13px;
      opacity: 0.8;
      z-index: 10;
    }
    #screen-container {
      position: relative;
      width: 96vw;
      height: 94vh;
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
    }
  </style>
</head>
<body>
  <div id="status">Verbinden met Agon AP...</div>
  <div id="screen-container">
    <canvas id="tekCanvas" width="1024" height="780"></canvas>
  </div>

  <script>
    const canvas = document.getElementById('tekCanvas');
    const ctx = canvas.getContext('2d');
    const status = document.getElementById('status');

    // Gloeiende P31 Phosphor Green instellingen
    ctx.strokeStyle = '#33ff66';
    ctx.fillStyle = '#33ff66';
    ctx.lineWidth = 1.2;
    ctx.shadowBlur = 4;
    ctx.shadowColor = '#33ff66';

    function clearScreen() {
      ctx.save();
      ctx.shadowBlur = 0;
      ctx.fillStyle = '#0a140c';
      ctx.fillRect(0, 0, canvas.width, canvas.height);
      ctx.restore();
    }
    clearScreen();

    // Tektronix 4014 State Machine
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
            x0 = x2; y0 = y2; // Move beam
            mode = 5;
          } else {
            ctx.beginPath();
            ctx.moveTo(x0, y0);
            ctx.lineTo(x2, y2);
            ctx.stroke();
            x0 = x2; y0 = y2; // Draw line
            mode = 5;
          }
        }
      }
    }

    // WebSocket verbinding opzetten naar ESP-12F
    const ws = new WebSocket('ws://' + window.location.hostname + ':81/');
    ws.binaryType = 'arraybuffer';

    ws.onopen = () => { status.innerText = '● LIVE TEKTRONIX STREAM (Verbonden)'; };
    ws.onclose = () => { status.innerText = '○ Verbinding verbroken'; };
    ws.onmessage = (event) => {
      const bytes = new Uint8Array(event.data);
      for (let i = 0; i < bytes.length; i++) {
        processByte(bytes[i]);
      }
    };
  </script>
</body>
</html>
)rawliteral";

void setup() {
  Serial.begin(115200);

  // 1. Wi-Fi Access Point starten
  WiFi.mode(WIFI_AP);
  WiFi.softAP(ssid, password);

  // 2. Webserver routes
  server.on("/", []() {
    server.send_P(200, "text/html", INDEX_HTML);
  });
  server.begin();

  // 3. WebSocket server starten op poort 81
  webSocket.begin();
}

uint8_t rxBuffer[256];

void loop() {
  server.handleClient();
  webSocket.loop();

  // Lees data van UEXT (Serial) en broadcast direct naar de tablet via WebSocket
  int available = Serial.available();
  if (available > 0) {
    int bytesToRead = min(available, (int)sizeof(rxBuffer));
    Serial.readBytes(rxBuffer, bytesToRead);
    webSocket.broadcastBIN(rxBuffer, bytesToRead);
  }
}
