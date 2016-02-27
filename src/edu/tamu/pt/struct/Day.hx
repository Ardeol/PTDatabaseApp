package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** Day Class
 *  @author  Timothy Foster
 *  @version x.xx.160224
 *
 *  Represents a day (M, T, W, R, or F), but also supports Saturday and
 *  Sunday.
 *  **************************************************************************/
@:enum abstract Day(String) to String {
    public var M = "M";
    public var T = "T";
    public var W = "W";
    public var R = "R";
    public var F = "F";
    public var Sa = "Sa";
    public var Su = "Su";
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Makes a new Day instance
 *  @param s String representing the day
 */
    public inline function new(s:String) {
        this = fromString(s);
    }
    
/*  Cast
 *  =========================================================================*/
/**
 *  Converts a string into a Day instance.  Required since days can have multiple string formats.
 *  @param value String
 *  @throws Error When invalid day is given
 */
    @:from public static function fromString(value:String):Day {
        value = value.toLowerCase();
        if (value == "m" || value == "mo")
            return M;
        else if (value == "t" || value == "tu")
            return T;
        else if (value == "w" || value == "we")
            return W;
        else if (value == "r" || value == "th")
            return R;
        else if (value == "f" || value == "fr")
            return F;
        else if (value == "sa")
            return Sa;
        else if (value == "su")
            return Su;
        else
            throw new Error('Invalid day provided: $value', "Day", "fromString");
    }
    
/*  Operator Overload
 *  =========================================================================*/
    @:op(A < B)
    public static function lt(lhs:Day, rhs:Day):Bool {
        var s = "MTWRFSaSu";
        return s.indexOf(lhs) < s.indexOf(rhs);
    }
     
    @:op(A <= B)
    public static function ltequals(lhs:Day, rhs:Day):Bool {
        return lhs < rhs || lhs == rhs;
    }
     
    @:op(A > B)
    public static function gt(lhs:Day, rhs:Day):Bool {
        return !(lhs <= rhs);
    }
     
    @:op(A >= B)
    public static function gtequals(lhs:Day, rhs:Day):Bool {
        return !(lhs < rhs);
    }

}