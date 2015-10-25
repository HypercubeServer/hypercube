module protocol;
import logger;
import std.json;
import std.conv : to;
import std.string;

class PacketField {
    string name;
    string type;
    
    this(string n, string t) {
        name = n;
        type = t;
    }
    
    override string toString() {
        return name ~ ": " ~ type;
    }
}  

class Packet {
    static Packet[] packets;
    
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
    
    this(string name, ubyte id, State state, To to, PacketField[] fields) {
        this.name = name;
        this.id = id;
        this.state = state;
        this.to = to;
        this.fields = fields;
    }
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
    foreach(name, packet; packets.object) {
        parsePacket(name, packet, s, t);
    }
}

void parsePacket(string name, JSONValue packet, Packet.State s, Packet.To t) {
    auto id = to!ubyte(packet["id"].str.split("x")[1], 16);
    if(id != 0) return;
    //log(s ~ " " ~ t ~ " " ~ name ~ "(" ~ to!string(id) ~ ")");
    PacketField[] fields;
    foreach(field; packet["fields"].array) {
        string fieldName = field["name"].str;
        string fieldType = field["type"].str;
        fields ~= new PacketField(fieldName, fieldType);
    }
    foreach(field; fields) {
        log(field.toString());
    }
}