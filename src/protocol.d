module protocol;
import logger;
import stream;
import std.json;
import std.conv : to;
import std.typecons;
import std.string;
import std.array;

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

class PacketTemplate {
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
        string[] d = name.split("_");
        string j;
        foreach(e;d){
            j ~= capitalize(e);
        }
        this.name = j;
        this.id = id;
        this.state = state;
        this.to = to;
        this.fields = fields;
    }

    ubyte getId() {
        return id;
    }
    
    string getName() {
        return name ~ "Packet";
    }

    override string toString() {
        return getName() ~ "(" ~ std.conv.to!string(id) ~ state ~ to ~ ")";
    }
}

PacketTemplate[] allPacketTemplate;

PacketTemplate getPacketTemplateById(ubyte id) {
    foreach(p; allPacketTemplate) {
        if(p.getId()) {
            return p;
        }
    }
    error("Unknown Packet Id: " ~ to!string(id));
    return null;
}

void parseProtocol(char[] s) {
    JSONValue p = parseJSON(s);
    PacketTemplate[] packets;
    packets ~= parsePackets(p["states"]["handshaking"]["toServer"], PacketTemplate.State.HandShake, PacketTemplate.To.Server);
    packets ~= parsePackets(p["states"]["status"]["toClient"], PacketTemplate.State.Status, PacketTemplate.To.Client);
    packets ~= parsePackets(p["states"]["status"]["toServer"], PacketTemplate.State.Status, PacketTemplate.To.Server);
    packets ~= parsePackets(p["states"]["login"]["toClient"], PacketTemplate.State.Login, PacketTemplate.To.Client);
    packets ~= parsePackets(p["states"]["login"]["toServer"], PacketTemplate.State.Login, PacketTemplate.To.Server);
    packets ~= parsePackets(p["states"]["play"]["toClient"], PacketTemplate.State.Play, PacketTemplate.To.Client);
    packets ~= parsePackets(p["states"]["play"]["toServer"], PacketTemplate.State.Play, PacketTemplate.To.Server);

    allPacketTemplate = packets;

    foreach(packet; packets) {
        log(packet.toString());
    }
    
    
}

PacketTemplate[] parsePackets(JSONValue packets, PacketTemplate.State s, PacketTemplate.To t) {
    PacketTemplate[] packetObjects;
    foreach(name, packet; packets.object) {
        packetObjects ~= parsePacket(name, packet, s, t);
    }
    /*foreach(packet; packetObjects) {
        log(packet.toString());
    }*/
    return packetObjects;
}

PacketTemplate parsePacket(string name, JSONValue packet, PacketTemplate.State s, PacketTemplate.To t) {
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
    return new PacketTemplate(name, id, s, t, fields);
}

class IncomingPacket {

    int ptr = 0;
    
    this(ubyte[] buffer) {
        int size = readVarInt(buffer, &ptr); /// size of packet
        int id = readVarInt(buffer, &ptr); /// packet id
        
    }
}