module hypercube;
import logger;
import protocol;
import std.stdio;
import std.file;
import std.json;
import core.stdc.stdlib;

string VERSION = "1.8-0.0.1"; ///Version of Hypercube

void setupPackets() {
    string protocolFileLocation = "minecraft-data/data/1.8/protocol.json"; /// Specific location protocol.json
    if(exists(protocolFileLocation) != 0) { /// protocol.json exists
        info("Found protocol.json");
        parseProtocol(cast(char[]) read(protocolFileLocation));
    } else { /// protocol.json doesn't exist
        error("Can't find protocol.json in " ~ protocolFileLocation);
        abort();
    }
}

int main(char[][] args) {
    writeln("\n Hypercube v" ~ VERSION ~ " initializing...\n");
    setDebug(true);
    /*auto listener = new Socket(AddressFamily.INET, SocketType.STREAM);
    listener.bind(new InternetAddress("localhost", 25565));
    lister.listen(10);
    auto readSet = new SocketSet();*/
    setupPackets();
    return 0;
}