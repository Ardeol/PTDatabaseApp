package edu.tamu.pt.io.generators;

import sys.io.FileOutput;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.util.Sorters;

/** BlockGenerator Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  NOT IMPLEMENTED
 *  **************************************************************************/
class BlockGenerator {
    public static inline var NAME = "block";
    
    override private function get_extension():String
        return "html";
    
/**
 *  @inheritDoc
 */
    override private function parse(db:IDatabase, out:FileOutput):Void {
        var html = "";//parseMain(db.pts(Sorters.alpha));
        out.writeString(html);
    }
    
}