module logger;
import std.stdio;

bool d = false;

void setDebug(bool t) {
    d = t;
}

void log(string s) {
    if(d) writeln("  [DEBUG] " ~ s);
}

void info(string s) {
    writeln("  [INFO] " ~ s);
}

void warning(string s) {
    writeln("  [WARN] " ~ s);
}

void error(string s) {
    writeln("  [ERROR] " ~ s);
}