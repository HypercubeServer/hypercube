module tcpserver;
import logger;
import std.conv;
import std.socket;
import std.concurrency;
import core.time;

class TcpListener {
    shared TcpSocket listener;
    
    this(InternetAddress ia) {
        TcpSocket t = new TcpSocket();
        assert(t.isAlive);
        t.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
        t.bind(ia);
        listener = cast(shared) t;
    }
    
    this(string hostname, ushort port) {
        this(new InternetAddress(hostname, port));
    }
    
    this(ushort port) {
        this(new InternetAddress(port));
    }
    
    ~this() {
        close();
    }
    
    void listen(int backlog) {
        (cast()listener).listen(backlog);
    }
    
    Socket accept() @property {
        Socket s = (cast()listener).accept;
        scope(failure) {
            if(s !is null) {
                s.close();
            }
        }
        return s;
    }
    
    void close() nothrow @nogc @property {
        if(listener !is null) {
            (cast()listener).close;
        }
    }
}

class TcpServer {
    TcpListener listener;
    
    this(InternetAddress ia) {
        listener = new TcpListener(ia);
    }
    
    this(string hostname, ushort port) {
        listener = new TcpListener(hostname, port);
    }
    
    this(ushort port) {
        listener = new TcpListener(port);
    }
    
    ~this() {
        listener.close();
    }
    
    void listen(int backlog = 1024) {
        listener.listen(backlog);
    }
    
    void run(void function(Socket) handler, uint threads = 2) {
        uint counter = threads;
        Tid ownerTid = thisTid;
        
        for(int i; i < threads; i++) {
            spawn(cast(void delegate() shared) () {
                scope(exit) ownerTid.send(thisTid);
                for(;;) {
                    Socket s = listener.accept;
                    log("Accepted " ~ to!string(thisTid));
                    handler(s);
                    if(s !is null) {
                        s.close();
                    }
                }
            });
        }
        
        bool running = true;
        
        while(running) {
            receiveTimeout(dur!"msecs"(10), (Tid tid) {
                counter--;
            });
            
            if(counter == 0) {
                running = false;
            }
        }
    }
}