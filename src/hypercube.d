module hypercube;
import logger;
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

string VERSION = "1.8-0.0.1"; ///Version of Hypercube
string HOSTNAME = "localhost";
ushort PORT = 25565;

void setupPackets() {
    info("Initializing protocol structure");
    string protocolFileLocation = "minecraft-data/data/1.8/protocol.json"; /// Specific location protocol.json
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
        s.receive(buffer);
        log("Data Recieved:");
        foreach(b;buffer){
            write(to!string(b));
        }
        //writeln(cast(string)buffer);
    });
}

int main(char[][] args) {
    writeln("\n Hypercube v" ~ VERSION ~ " initializing...\n");
    parseArguments(args);
    setupPackets();
    setupSockets();
    return 0;
}