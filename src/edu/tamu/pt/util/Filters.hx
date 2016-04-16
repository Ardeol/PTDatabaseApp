package edu.tamu.pt.util;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;

/** Filters Class
 *  @author  Timothy Foster
 *
 *  Used to filter only the desired results from the database.
 *  **************************************************************************/
class Filters {
    
/**
 *  If only one of the names is given, this will filter for that name.  Otherwise if both are given,
 *  it will match both as an AND.  To apply one one of the names, make the other the empty string.
 */
    public static var name(default, null):String->String->PeerTeacher->Bool = function(last, first, pt) {
        return (last.length == 0 || pt.lastname == last) && (first.length == 0 || pt.firstname == first);
    };
    
/**
 *  Determines if the teacher has the particular lab in question.  We match by value, not by
 *  reference.
 */
    public static var hasLab(default, null):ClassSchedule->PeerTeacher->Bool = function(c, pt) {
        return pt.labs.exists(c.toString());
    };
    
}