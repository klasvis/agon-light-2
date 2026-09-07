#ifndef VDP_STREAM_H
#define VDP_STREAM_H

#include <Arduino.h>
#include <HardwareSerial.h>
#include <WiFi.h>

class VDPDualStream : public Stream {
private:
    HardwareSerial hwSerial;
    WiFiServer wifiServer;
    WiFiClient wifiClient;
    bool wifiActive;
    SemaphoreHandle_t mutex;

public:
    VDPDualStream(int uart_nr) : hwSerial(uart_nr), wifiServer(23), wifiActive(false) {
        mutex = xSemaphoreCreateMutex();
    }

    void setTxBufferSize(size_t size) {
        hwSerial.setTxBufferSize(size);
    }

    void begin(unsigned long baud, uint32_t config = SERIAL_8N1, int8_t rxPin = -1, int8_t txPin = -1) {
        hwSerial.begin(baud, config, rxPin, txPin);
    }

    bool beginWiFiAP(const char *ssid = "Agon-Light-VDP", const char *pass = nullptr) {
        WiFi.mode(WIFI_AP);
        WiFi.setSleep(false);
        bool ok = WiFi.softAP(ssid, (pass && strlen(pass) >= 8) ? pass : nullptr);
        wifiServer.begin(23);
        wifiServer.setNoDelay(true);
        wifiActive = ok;
        return ok;
    }

    bool isWiFiAPActive() const {
        return wifiActive;
    }

    void update() {
        if (!wifiActive) return;
        if (wifiServer.hasClient()) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(10))) {
                WiFiClient newClient = wifiServer.available();
                if (!wifiClient || !wifiClient.connected()) {
                    if (wifiClient) wifiClient.stop();
                    wifiClient = newClient;
                    wifiClient.setNoDelay(true);
                } else {
                    newClient.stop();
                }
                xSemaphoreGive(mutex);
            }
        }
    }

    size_t write(uint8_t c) override {
        size_t n = hwSerial.write(c);
        if (wifiActive) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(2))) {
                if (wifiClient && wifiClient.connected()) {
                    wifiClient.write(c);
                }
                xSemaphoreGive(mutex);
            }
        }
        return n;
    }

    size_t write(const uint8_t *buffer, size_t size) override {
        size_t n = hwSerial.write(buffer, size);
        if (wifiActive && buffer && size > 0) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(2))) {
                if (wifiClient && wifiClient.connected()) {
                    wifiClient.write(buffer, size);
                }
                xSemaphoreGive(mutex);
            }
        }
        return n;
    }

    int available() override {
        int a = hwSerial.available();
        if (a > 0) return a;
        if (wifiActive) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(2))) {
                if (wifiClient && wifiClient.connected()) {
                    int wa = wifiClient.available();
                    xSemaphoreGive(mutex);
                    return wa;
                }
                xSemaphoreGive(mutex);
            }
        }
        return 0;
    }

    int read() override {
        if (hwSerial.available()) {
            return hwSerial.read();
        }
        if (wifiActive) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(2))) {
                if (wifiClient && wifiClient.connected() && wifiClient.available()) {
                    int b = wifiClient.read();
                    xSemaphoreGive(mutex);
                    return b;
                }
                xSemaphoreGive(mutex);
            }
        }
        return -1;
    }

    int peek() override {
        if (hwSerial.available()) {
            return hwSerial.peek();
        }
        if (wifiActive) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(2))) {
                if (wifiClient && wifiClient.connected() && wifiClient.available()) {
                    int b = wifiClient.peek();
                    xSemaphoreGive(mutex);
                    return b;
                }
                xSemaphoreGive(mutex);
            }
        }
        return -1;
    }

    void flush() override {
        hwSerial.flush();
        if (wifiActive) {
            if (xSemaphoreTake(mutex, pdMS_TO_TICKS(2))) {
                if (wifiClient && wifiClient.connected()) {
                    wifiClient.flush();
                }
                xSemaphoreGive(mutex);
            }
        }
    }
};

extern VDPDualStream DBGSerial;

#endif // VDP_STREAM_H
