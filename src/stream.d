module stream;
import logger;
import std.stdio;
import std.conv;

/*
 * Most of this file is based off of the Java 8 DataInputStream
 * Thank you D2 for getting rid of your streams ;-;
 */
 
ubyte read(ubyte[] data, int *ptr) {
    ubyte d = data[*ptr];
    *ptr += 1;
    return d;
}

byte[] readFully(ubyte[] data, int *ptr, int len) {
    byte[] b;
    int n = 0;
    while(n < len) {
        b ~= data[*ptr];
        *ptr += 1;
        n++;
    }
    return b;
}

int readVarInt(ubyte[] data, int *ptr) {
    int i = 0;
    int j = 0;
    while(true) {
        int k = data[*ptr];
        *ptr += 1;
        i |= (k & 0x7F) << j++ * 7;
        if(j > 5) {
            error("VarInt is too big");
        }
        if((k & 0x80) != 128) break;
    }
    return i;
}

int readUnsignedShort(ubyte[] data, int *ptr) {
    ubyte ch1 = read(data, ptr);
    ubyte ch2 = read(data, ptr);
    if((ch1 | ch2) < 0) {
        error("EOF when reading Unsigned Short");
    }
    return (ch1 << 8) + ch2;
}

char readChar(ubyte[] data, int *ptr) {
    return cast(char)readUnsignedShort(data, ptr);
}

int readInt(ubyte[] data, int *ptr) {
    int ch1 = read(data, ptr);
    int ch2 = read(data, ptr);
    int ch3 = read(data, ptr);
    int ch4 = read(data, ptr);
    if((ch1 | ch2 | ch3 | ch4) < 0) {
        error("EOF when reading Integer");
    }
    return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + ch4);
}

string readString(ubyte[] data, int *ptr) {
    int len = readVarInt(data, ptr);
    char[] chars = to!(char[])(readFully(data, ptr, len));
    return std.utf.toUTF8(chars);
}
