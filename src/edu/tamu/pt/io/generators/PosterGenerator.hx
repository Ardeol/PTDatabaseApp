package edu.tamu.pt.io.generators;

import sys.io.FileOutput;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.util.Sorters;

/** PosterGenerator Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class PosterGenerator extends Generator {
    public static inline var NAME = "poster";
    public static inline var COLUMNS = 7;
    
    override private function get_extension():String
        return "html";
    
/**
 *  @inheritDoc
 */
    override private function parse(db:IDatabase, out:FileOutput):Void {
        var html = parseMain(db.pts(Sorters.alpha));
        out.writeString(html);
    }
    
    private function parseMain(pts:Array<PeerTeacher>):String {
        var rowsBuf = new StringBuf();
        
        var i = 0;
        for (pt in pts) {
            if (i == 0) rowsBuf.add("<tr>");
            rowsBuf.add(parsePT(pt));
            if (i == 6) rowsBuf.add("</tr>");
            i = (i + 1) % COLUMNS;
        }
        
        var rows = rowsBuf.toString();
        return Macros.getGeneratorHtml("poster", "main"); // requires rows
    }
    
    private function parsePT(pt:PeerTeacher):String {
        var preferredname = pt.preferredname.length > 0 ? pt.preferredname : pt.firstname;
        var name = '$preferredname ${pt.lastname}';
        var image = pt.image;
        
        var sortedOfficeHours = pt.officeHours.slice(0);
        sortedOfficeHours.sort(Sorters.appointments);
        var hoursBuf = new StringBuf();
        for (h in sortedOfficeHours)
            hoursBuf.add(parseOfficeHours(h));
        var hours = hoursBuf.toString();
        
        return Macros.getGeneratorHtml("poster", "pt"); // requires name, image, hours
    }
    
    private function parseOfficeHours(appt:Appointment):String {
        var days = appt.daysString();
        var times = appt.timesString();
        return Macros.getGeneratorHtml("poster", "hours");
    }
    
}