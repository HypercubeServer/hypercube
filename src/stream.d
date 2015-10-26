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
    writeln("s; Starting readString()");
    int len = readUnsignedShort(data, ptr);
    writeln("s; read unsigned short: " ~ to!string(len));
    byte[] bytearr = readFully(data, ptr, len);
    char[] chararr;
    int c, char2, char3;
    int count = 0;
    writeln("s; initialized variables");
    
    while(count < len) {
        write("\nca: " ~ chararr ~ " c:");
        c = cast(int)bytearr[count] & 0xff;
        writeln(c);
        if(c > 127) break;
        count++;
        chararr ~= c;
    }
    writeln("\ns; went through one loop");
    while(count < len) {
        c = cast(int)bytearr[count] & 0xff;
        switch(c >> 4) {
            case 0: case 1: case 2: case 3: case 4:case 6: case 7:
                /* 0xxxxxxx */
                count++;
                chararr ~= cast(char)c;
                break;
            case 12: case 13:
                /* 110x xxxx  10xx xxxx */
                count += 2;
                if(count > len) {
                    error("UTF Data is improperly formatted: Partial character at end");
                }
                
                char2 = cast(int) bytearr[count-1];
                if((char2 & 0xc0) != 0x80) {
                    error("UTF Data is improperly formatted: Malformed byte around " ~ to!string(count));
                }
                chararr ~= cast(char)(((c & 0x1f) << 6) | (char2 & 0x3f));
                break;
            case 14:
                /* 1110 xxxx  10xx xxxx  10xx xxxx */
                count += 3;
                if(count > len) {
                    error("UTF Data is improperly formatted: Partial character at end");
                }
                char2 = cast(int) bytearr[count-2];
                char3 = cast(int) bytearr[count-1];
                if(((char2 & 0xc0) != 0x80) || ((char3 & 0xc0) != 0x80)) {
                    error("UTF Data is improperly formatted: Malformed byte around " ~ to!string(count-1));
                }
                chararr ~= cast(char)(((c & 0x0f) << 12) | ((char2 & 0x3f) << 6) | (char3 & 0x3f));
                break;
            default:
                /* 10xx xxxx,  1111 xxxx */
                error("UTF Data is improperly formatted: Malformed byte around " ~ to!string(count));
        }
    } 
    //The number of chars produced may be less than len
    log(chararr.idup);
    return chararr.idup;
}