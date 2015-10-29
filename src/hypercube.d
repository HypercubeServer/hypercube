module hypercube;
import logger;
import stream;
import protocol;
import tcpserver;
import std.stdio;
import std.file;
import std.json;
import std.algorithm;
import std.string;
import std.conv;
import std.socket;
import core.stdc.stdlib;

string VERSION = "15w40b-0.0.1"; ///Version of Hypercube
string HOSTNAME = "localhost";
ushort PORT = 25565;

void setupPackets() {
    info("Initializing protocol structure");
    string protocolFileLocation = "minecraft-data/data/1.9/protocol.json"; /// Specific location protocol.json
    if(exists(protocolFileLocation) != 0) { /// protocol.json exists
        log("Found protocol.json");
        parseProtocol(cast(char[]) read(protocolFileLocation));
    } else { /// protocol.json doesn't exist
        error("Can't find protocol.json in " ~ protocolFileLocation);
        abort();
    }
}

void parseArguments(char[][] args) {
    foreach(w; args) {
        if(w == "-debug" || w == "-d") {
            setDebug(true);
        }
        else if(w.startsWith("-h=")){
            HOSTNAME = (to!string(w).split("-h="))[1];
        }
        else if(w.startsWith("-p=")){
            PORT = to!ushort((to!string(w).split("-p="))[1]);
        }
    }
}

void setupSockets() {
    info("Opening socket at " ~ HOSTNAME ~ ":" ~ to!string(PORT));
    auto server = new TcpServer(HOSTNAME, PORT);
    server.listen(1024);
    server.run((s) {
        ubyte[1024] buffer;
        int ptr = 0;
        s.receive(buffer);
        int size = readVarInt(buffer, &ptr); /// size of packet
        int id = readVarInt(buffer, &ptr); /// packet id
        int protocolVersion = readVarInt(buffer, &ptr); /// protocol version
        string address = readString(buffer, &ptr);
        if(id == 0) {
            writeln("Packet Id: " ~ to!string(id) ~ "\nPacket Size: " ~ to!string(size) ~ "\nProtocol Version: " ~ to!string(protocolVersion) ~ "\nAddress: " ~ address);
        }
        /*ptr = 0;
        while(ptr <= buffer.length) {
            write(to!string(readVarInt(buffer, &ptr)) ~ " ");
        }*/
    });
}

int main(char[][] args) {
    writeln("\n Hypercube v" ~ VERSION ~ " initializing...\n");
    parseArguments(args);
    setupPackets();
    setupSockets();
    return 0;
}
