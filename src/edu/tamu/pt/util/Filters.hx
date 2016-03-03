package edu.tamu.pt.util;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;

/** Filters Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class Filters {
    
    public static var name(default, null):String->String->PeerTeacher->Bool = function(last, first, pt) {
        return (last.length == 0 || pt.lastname == last) && (first.length == 0 || pt.firstname == first);
    };
    
    public static var hasLab(default, null):ClassSchedule->PeerTeacher->Bool = function(c, pt) {
        return pt.labs.exists(c.toString());
    };
    
}