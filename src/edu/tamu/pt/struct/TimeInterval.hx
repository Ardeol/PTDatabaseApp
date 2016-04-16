package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** TimeInterval Class
 *  @author  Timothy Foster
 *  
 *  Represents a time interval in a schedule.  For instance, a Time object can
 *  represent 10:00 am - 12:00 pm.
 * 
 *  The time object will fail for times crossing midnight.  In the scope of
 *  the application, this will never occur, so it is left unsupported.
 * 
 *  Note: "Common" format is how most English people write times.  This is the
 *  HH:MM am/pm format.  Acceptable times include 1:00 pm, 04:35 am, and so
 *  on.  13:00 pm is not a valid time.
 *  **************************************************************************/
class TimeInterval {
/**
 *  The start of the interval.
 */
    public var start(default, set):Int;
    
/**
 *  The end of the interval.
 */
    public var end(default, set):Int;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new Time instance.
 *  @param range String representing an interval of time in common format (HH:MM - HH:MM a/pm)
 */
    public function new(?range:String) {
        if (range == null) {
            this.start = 0;
            this.end = 0;
        }
        else {
            var times = range.split("-");
            if (times.length < 2)
                throw new Error('Invalid time range given. $range', "Time", "new");
            
        //  4:00 - 5:00 pm becomes 4:00 pm - 5:00 pm
            var hasAPM = ~/[aApP][mM]/;
            if (!hasAPM.match(times[0])) {
                if (hasAPM.match(times[1]))
                    times[0] += " " + hasAPM.matched(0);
            }
            
            this.setStart(StringTools.trim(times[0]));
            this.setEnd(StringTools.trim(times[1]));
        }
    }
    
/*  Class Methods
 *  =========================================================================*/
/**
 *  Converts common time to data the Time object can use.  Specifically, this will convert common time into the number of minutes since midnight.
 *  @param time Time in common format.
 *  @return Number of minutes since midnight.
 */
    public static function fromCommon(time:String):Int {
        var regex = ~/^(\d|0\d|1[0-2]):([0-5]\d)\s+([aApP])[mM]$/;
        if (regex.match(time)) {
            var apm = regex.matched(3).toLowerCase();
            var h = Std.parseInt(regex.matched(1));
            h += (apm == "p" && h < 12 ? 12 : 0);
            if (h == 12 && apm == "a")  // 12:00 am -> 0:00 am
                h = 0;
            var m = Std.parseInt(regex.matched(2));
            return 60 * h + m;
        }
        else
            throw new Error('Invalid time provided $time', "Time", "fromCommon");
    }
    
/**
 *  Converts encoded time (aka. minutes from midnight) into common time format.
 *  @param time Minutes from midnight
 *  @return HH:MM (a/p)m
 */
    public static function toCommon(time:Int):String {
        var h = Math.floor((time % (MINUTES_IN_DAY / 2)) / 60);
        var m = time % 60;
        if (h == 0)
            h = 12;
        var mz = "";
        if (m < 10)
            mz = "0";
        var apm = "a";
        if (time >= MINUTES_IN_DAY / 2)
            apm = "p";
        return '$h:$mz$m ${apm}m';
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Convenience for setting the start time.
 *  @param common Time in common format
 */
    public inline function setStart(common:String):Int {
        return this.start = fromCommon(common);
    }
    
/**
 *  Convenience for setting the end time.
 *  @param common Time in common format
 */
    public inline function setEnd(common:String):Int {
        return this.end = fromCommon(common);
    }
    
/**
 *  Determines if two times overlap or not.
 *  @param other A Time object
 *  @return true if the times overlap, false otherwise
 */
    public function intersects(other:TimeInterval):Bool {
        return (other.start <= this.start && this.start <= other.end) || (this.start <= other.start && other.start <= this.end);
    }
    
/**
 *  Convert to string
 *  @return HH:MM - HH:PP (a/p)m
 */
    public function toString():String {
        var s = toCommon(start);
        var e = toCommon(end);
        if (!(start < MINUTES_IN_DAY / 2 && end >= MINUTES_IN_DAY / 2))
            s = s.substr(0, s.length - 3);
        return '$s - $e';
    }
 
/*  Private Members
 *  =========================================================================*/
    private static inline var MINUTES_IN_DAY = 1440;
 
/*  Private Methods
 *  =========================================================================*/
    private function set_start(value:Int):Int {
        return start = (MINUTES_IN_DAY + value % MINUTES_IN_DAY) % MINUTES_IN_DAY;
    }
    
    private function set_end(value:Int):Int {
        return end = (MINUTES_IN_DAY + value % MINUTES_IN_DAY) % MINUTES_IN_DAY;
    }
}