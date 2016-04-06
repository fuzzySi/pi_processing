// SPI to MCP3008 8 chanel ADC for processing on raspberry pi

// MCP pin 16, 15 to 3v3 on pi (eg pin 1)
// MCP pin 14 & 9 to ground (eg pin 9)
// MCP pin 13 CLK to pi SPI_CLK pin 23
// MCP pin 12 Dout to pi SPI_MISO pin 21
// MCP pin 11 Din to pi SPI_MOSI pin 19
// MCP pin 10 CS to pi SPI_CE0_N pin 24
// MCP pins 1-8 are ADC ins for channels 0-7

import processing.io.*;
SPI MCP;
int CHANNELS = 8; // 8 for MCP 3008, 4 for MCP3004
int[] channel = new int[CHANNELS];

void setup() {
  // printArray(SPI.list()); // to check SPI enabled - should give [0] "spidev0.0", [1] "spidev0.1"
  MCP = new SPI(SPI.list()[0]); // raspberry pi has 2 SPI interfaces, SPI.list()[1] is the other
  MCP.settings(1000000, SPI.MSBFIRST, SPI.MODE0); // 1MHz should be OK...
}

void draw() {
  for (int i = 0; i < CHANNELS; i ++) {
    channel[i] = returnADC(i);
    println("result for channel " + i + " is " + channel[i]);
  }
  delay(500);
}

int returnADC(int ch) {
  byte[] out = {1, byte((8 + ch) << 4), 0}; // outgoing bytes to the MCP
  byte[] in = MCP.transfer(out); // sends & returns
  int highInt = in[1] & 0xFF; // processing sees bytes as signed (-128 to 127) which is not what we want here
  int lowInt = in[2] & 0xFF; // doing this converts to unsigned ints (0 to 255)
  int result = ((highInt & 3) << 8) + lowInt; // adds lowest 2 bits of 2nd byte to 3rd byte to get 10 bit result 
  return result;
}
