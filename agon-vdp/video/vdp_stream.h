#ifndef VDP_STREAM_H
#define VDP_STREAM_H

#include <Arduino.h>
#include <HardwareSerial.h>

// High-speed Hardware Serial stream for Agon Light USB Monitor
class VDPDualStream : public Stream {
private:
    HardwareSerial hwSerial;

public:
    VDPDualStream(int uart_nr) : hwSerial(uart_nr) {}

    void setTxBufferSize(size_t size) {
        hwSerial.setTxBufferSize(size);
    }

    void begin(unsigned long baud, uint32_t config = SERIAL_8N1, int8_t rxPin = -1, int8_t txPin = -1) {
        hwSerial.begin(baud, config, rxPin, txPin);
    }

    size_t write(uint8_t c) override {
        return hwSerial.write(c);
    }

    size_t write(const uint8_t *buffer, size_t size) override {
        return hwSerial.write(buffer, size);
    }

    int available() override {
        return hwSerial.available();
    }

    int read() override {
        return hwSerial.read();
    }

    int peek() override {
        return hwSerial.peek();
    }

    void flush() override {
        hwSerial.flush();
    }
};

extern VDPDualStream DBGSerial;

#endif // VDP_STREAM_H
