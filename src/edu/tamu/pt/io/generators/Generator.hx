package edu.tamu.pt.io.generators;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.io.FileWriter;

class Generator extends FileWriter<IDatabase> {
    
    public var extension(get, never):String;
    
    public function new() {
        super("");
    }
    
    private function get_extension():String
        return "";
}