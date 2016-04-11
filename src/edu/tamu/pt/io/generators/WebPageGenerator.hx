package edu.tamu.pt.io.generators;

import sys.io.FileOutput;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.struct.PeerTeacher;

/** WebPageGenerator Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class WebPageGenerator extends Generator {

    override private function get_extension():String
        return "html";
    
/**
 *  @inheritDoc
 */
    override private function parse(db:IDatabase, out:FileOutput):Void {
        out.writeString("yolo");
    }
    
}

private abstract PTFormatter(Formatter<PeerTeacher>) {
    
}