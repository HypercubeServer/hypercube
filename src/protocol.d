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
    
    override string toString() {
        return state ~ to ~ "Packet: " ~ name ~ "(" ~ std.conv.to!string(id) ~ ")";
    }
}

void parseProtocol(char[] s) {
    JSONValue p = parseJSON(s);
    Packet[] packets;
    packets ~= parsePackets(p["states"]["handshaking"]["toServer"], Packet.State.HandShake, Packet.To.Server);
    packets ~= parsePackets(p["states"]["status"]["toClient"], Packet.State.Status, Packet.To.Client);
    packets ~= parsePackets(p["states"]["status"]["toServer"], Packet.State.Status, Packet.To.Server);
    packets ~= parsePackets(p["states"]["login"]["toClient"], Packet.State.Login, Packet.To.Client);
    packets ~= parsePackets(p["states"]["login"]["toServer"], Packet.State.Login, Packet.To.Server);
    packets ~= parsePackets(p["states"]["play"]["toClient"], Packet.State.Play, Packet.To.Client);
    packets ~= parsePackets(p["states"]["play"]["toServer"], Packet.State.Play, Packet.To.Server);
    
    foreach(packet; packets) {
        log(packet.toString());
    }
}

Packet[] parsePackets(JSONValue packets, Packet.State s, Packet.To t) {
    Packet[] packetObjects;
    foreach(name, packet; packets.object) {
        packetObjects ~= parsePacket(name, packet, s, t);
    }
    /*foreach(packet; packetObjects) {
        log(packet.toString());
    }*/
    return packetObjects;
}

Packet parsePacket(string name, JSONValue packet, Packet.State s, Packet.To t) {
    auto id = to!ubyte(packet["id"].str.split("x")[1], 16);
    //log(s ~ " " ~ t ~ " " ~ name ~ "(" ~ to!string(id) ~ ")");
    PacketField[] fields;
    foreach(field; packet["fields"].array) {
        try{
            string fieldName = field["name"].str;
            string fieldType = field["type"].str;
            fields ~= new PacketField(fieldName, fieldType);
        } catch(Exception e) {
            // TODO: Handle buffers and other types of data
        }
    }
    return new Packet(name, id, s, t, fields);
}