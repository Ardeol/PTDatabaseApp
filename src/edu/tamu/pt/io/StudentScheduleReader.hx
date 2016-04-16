package edu.tamu.pt.io;

import haxe.io.Eof;
import sys.io.FileInput;

import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.TimeInterval;

/** StudentScheduleReader Class
 *  @author  Timothy Foster
 *
 *  Reads in a student's schedule file, if formatted correctly.
 *  **************************************************************************/
class StudentScheduleReader extends FileReader<PeerTeacher> {
    private static var nameFormat:EReg = ~/^\s*Schedule\s+for\s+([^\s]+)\s+(.*)\s*-/;
    private static var classFormat:EReg = ~/([A-Z]{4})-(\d\d\d)-(\d\d\d)/;
    private static var timeFormat:EReg = ~/\d?\d:\d\d\s*[aApP][mM]\s*-\s*\d?\d:\d\d\s*[aApP][mM]/;
    private static var daysFormat:EReg = ~/^\s*([MOTUWEHFR,]+)\s*$/;
    
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
                else if (daysFormat.match(line.split("\t")[0])) { // This line bothers me; if a bug arises, it might be here
                    var days = daysFormat.matched(1).split(",");
                    for (day in days)
                        appt.addDay(day);
                        
                //  The try block catches errors thrown by self-conflicting schedules
                //  Schedules really shouldn't self-conflict, but they seem to if the class
                //  has external exams.  We'll assume we know what the schedule is talking about.
                    try {
                        curSchedule.addAppointment(appt);
                    }
                    catch(err:Dynamic) {}
                }
            }
        }
        catch(e:Eof) {}
        
        return pt;
    }
}