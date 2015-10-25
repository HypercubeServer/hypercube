module protocol;
import logger;
import std.json;

class PacketField {
    string name;
    string type;
}

class Packet {
    enum To : string{
        Server = "Server",
        Client = "Client",
    }
    enum State : string{
        HandShake = "HandShake",
        Status = "Status",
        Login = "Login",
        Play = "Play",
    }
    
    To to;
    State state;
    string name;
    ubyte id;
    PacketField[] fields;
}

void parseProtocol(char[] s) {
    JSONValue p = parseJSON(s);
    // TODO: Find a better way to do this
    //parsePackets(p["states"]["handshaking"]["toClient"], Packet.State.HandShake, Packet.To.Client);
    parsePackets(p["states"]["handshaking"]["toServer"], Packet.State.HandShake, Packet.To.Server);
    parsePackets(p["states"]["status"]["toClient"], Packet.State.Status, Packet.To.Client);
    parsePackets(p["states"]["status"]["toServer"], Packet.State.Status, Packet.To.Server);
    parsePackets(p["states"]["login"]["toClient"], Packet.State.Login, Packet.To.Client);
    parsePackets(p["states"]["login"]["toServer"], Packet.State.Login, Packet.To.Server);
    parsePackets(p["states"]["play"]["toClient"], Packet.State.Play, Packet.To.Client);
    parsePackets(p["states"]["play"]["toServer"], Packet.State.Play, Packet.To.Server);
}

void parsePackets(JSONValue packets, Packet.State s, Packet.To t) {
    foreach(packet; packets.object) {
        parsePacket(packet, s, t);
    }
}

void parsePacket(JSONValue packet, Packet.State s, Packet.To t) {
    log(s ~ " " ~ t ~ " " ~ packet["id"].str);
}