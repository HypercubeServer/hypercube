module protocol;
import logger;
import stream;
import std.json;
import std.conv : to;
import std.typecons;
import std.string;
import std.array;
import std.algorithm;

class PacketField {
    string name;
    string type;
    
    this(string n, string t) {
        name = n;
        type = t;
    }
    
    string getName() {
        return name;
    }
    
    string getType() {
        return type;
    }
    
    override string toString() {
        return name ~ ": " ~ type;
    }
}  

class Packet {
    enum To : string {
        Server = "Server",
        Client = "Client",
    }
    enum State : string {
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
        string[] d = name.split("_");
        string j;
        foreach(e;d) j ~= capitalize(e);
        this.name = j;
        this.id = id;
        this.state = state;
        this.to = to;
        this.fields = fields;
    }

    ubyte getId() {
        return id;
    }
    
    PacketField[] getFields() {
        return fields;
    }
    
    string getName() {
        return name ~ "Packet";
    }

    override string toString() {
        return getName() ~ "(" ~ std.conv.to!string(id) ~ state ~ to ~ ")";
    }
}

Packet[] allPackets = void;

Packet getPacketById(ubyte id) {
    foreach(p; allPackets) {
        log(to!string(p.getId()));
        if(p.getId() == id) {
            return p;
        }
    }
    error("Unknown Packet Id: " ~ to!string(id));
    return null;
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
    
    log("Packets Found: " ~ to!string(packets.length));
    allPackets = packets;
    
    foreach(packet; packets) {
        log(packet.toString());
    }
}

Packet[] parsePackets(JSONValue packets, Packet.State s, Packet.To t) {
    Packet[] packetObjects;
    foreach(name, packet; packets.object) {
        packetObjects ~= parsePacket(name, packet, s, t);
    }
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

class IncomingPacket {

    ubyte[] data = void;
    int ptr = 0;
    
    this(ubyte[] buffer) {
        this.data = buffer;
        this.ptr = 0;
        int size = readVarInt(data, &ptr); /// size of packet
        int id = readVarInt(data, &ptr); /// packet id
        Packet p = getPacketById(cast(ubyte)id);
        log("Incoming Packet: " ~ to!string(id) ~ ":" ~ p.toString());
    }
}