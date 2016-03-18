package edu.tamu.pt.struct;

import edu.tamu.pt.error.Error;

/** Appointment Class
 *  @author  Timothy Foster
 *  @version x.xx.160224
 *
 *  Represents a scheduled time.  This includes days of the week and the
 *  occupied times during those days.  This structure is used to detect
 *  conflicts between a proposed appointment and current appointments.
 *  **************************************************************************/
class Appointment {

/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new appointment.
 *  @param str String representing an appointment, formatted as DAYS TIMES
 */
    public function new(?str:String) {
        days = new Array<Day>();
        times = new Array<TimeInterval>();
        
        if (str != null)
            fromString(str);
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Returns true if the other appointment conflicts with this one.
 *  @param other An appointment.
 *  @return true if a conflict exists between any of the days, false otherwise
 */
    public function intersects(other:Appointment):Bool {
    //  This indention chain is absolutely beautiful, only because it works.
        for (d in days)
            if (other.days.indexOf(d) >= 0)
                for (ta in times)
                    for (tb in other.times)
                        if (ta.intersects(tb))
                            return true;
        return false;
    }
    
/**
 *  Adds a day to the appointment.  Keeps it in MTWRF order.
 *  @param d Day object
 */
    public function addDay(d:Day):Void {
        var i = days.length;
        while (i > 0 && d < days[i - 1])
            --i;
        days.insert(i, d);
    }
    
/**
 *  Adds a time interval to the appointment.  Keeps it in chronological order.
 *  @param t TimeInterval object
 */
    public function addInterval(t:TimeInterval):Void {
        var i = times.length;
        while (i > 0 && t.start < times[i - 1].start)
            --i;
        times.insert(i, t);
    }
    
/**
 *  Returns the days as a single conglomerate string
 *  @return "MW" format
 */
    public function daysString():String {
        return days.join("");
    }
    
/**
 *  Returns comma separated list of time intervals.
 *  @return Time intervals separated by commas
 */
    public function timesString():String {
        return times.join(", ");
    }
    
    public function fromString(value:String):Void {
        var regex = ~/^([MTWRFSau]+)\s(.*)$/;
        if (regex.match(value)) {
            for (day in regex.matched(1).split("")) {
                if (day == "a")
                    addDay(Day.Sa);
                else if (day == "u")
                    addDay(Day.Su);
                else if(day != "S") // skip S, as it means the next letter is either "a" or "u"
                    addDay(day);
            }
            if (days.length <= 0)
                throw new Error("Appointment was not given any days.", "Appointment", "fromString");
            
            for (time in regex.matched(2).split(","))
                addInterval(new TimeInterval(time));
        }
        else
            throw new Error('Appointment not formatted correctly ($value)', "Appointment", "fromString");
    }
    
/**
 *  Converts the appointment into a conglomerate string.
 */
    public function toString():String {
        return '${daysString()} ${timesString()}';
    }
 
/*  Private Members
 *  =========================================================================*/
    private var days:Array<Day>;
    private var times:Array<TimeInterval>;
    
}