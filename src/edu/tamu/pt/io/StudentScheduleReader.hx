package edu.tamu.pt.io;

import haxe.io.Eof;
import sys.io.FileInput;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.TimeInterval;

/** StudentScheduleReader Class
 *  @author  Timothy Foster
 *  @version x.xx.160316
 *
 *  Reads in a student's schedule file, if formatted correctly.
 *  @TODO error handling
 *  **************************************************************************/
class StudentScheduleReader extends FileReader<PeerTeacher> {
    private static var nameFormat:EReg = ~/^\s*Schedule\s+for\s+([^\s]+)\s+(.*)\s*-/;
    private static var classFormat:EReg = ~/([A-Z]{4})-(\d\d\d)-(\d\d\d)/;
    private static var timeFormat:EReg = ~/\d?\d:\d\d\s*[aApP][mM]\s*-\s*\d?\d:\d\d\s*[aApP][mM]/;
    private static var daysFormat:EReg = ~/^\s*([MOTUWEHFR,]+)\s/;
    
/**
 *  @inheritDoc
 */
    override private function parse(stream:FileInput):PeerTeacher {
        var pt:PeerTeacher = null;
        try {
            var line = "";
            while (pt == null) {
                line = stream.readLine();
                if (nameFormat.match(line))
                    pt = new PeerTeacher(StringTools.trim(nameFormat.matched(1)), StringTools.trim(nameFormat.matched(2)));
            }
            
            var curSchedule = new ClassSchedule("INVALID", "000", "000");
            var appt = new Appointment();
            while (true) {
            //  Each schedule comes as the classname, followed by a time, followed by the days
                line = stream.readLine();
                if (classFormat.match(line)) {
                    curSchedule = new ClassSchedule(classFormat.matched(1), classFormat.matched(2), classFormat.matched(3));
                    pt.schedule.push(curSchedule);
                }
                else if (timeFormat.match(line)) {
                    appt = new Appointment();
                    appt.addInterval(new TimeInterval(timeFormat.matched(0)));
                }
                else if (daysFormat.match(line)) {
                    var days = daysFormat.matched(1).split(",");
                    for (day in days)
                        appt.addDay(day);
                    curSchedule.addAppointment(appt);
                }
            }
        }
        catch(e:Eof) {}
        
        return pt;
    }
}