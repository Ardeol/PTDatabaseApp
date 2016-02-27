package edu.tamu.pt.io;

import haxe.io.Eof;
import sys.io.FileInput;

import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.Day;
import edu.tamu.pt.struct.TimeInterval;

/** LabReader Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class LabReader extends FileReader<Map<String, ClassSchedule>> {
    private static var classFormat:EReg = ~/(CSCE)\s(\d\d\d)\s-\s(\d\d\d)/;
    private static var timeFormat:EReg = ~/(\d?\d:\d\d\s*[ap]m\s*-\s*\d?\d:\d\d\s*[ap]m)\s*(M?T?W?R?F?)/;
    private static var labFormat:EReg = ~/^\s*Laboratory/;
    
/**
 *  @inheritDoc
 */
    override private function parse(stream:FileInput):Map<String, ClassSchedule> {
    /*  Strategy:
     *  Find a Course.  If one is found, set curSchedule equal to it.
     *  Find any Laboratory sections after a course is found.
     *  If a Lab is found, get its schedule and create an Appointment for the course.
     *  Rince and repeat.
     */
        var courses = new Map<String, ClassSchedule>();

        try {
            var line = "";
            var curSchedule = new ClassSchedule("INVALID", "000", "000");
            while (true) {
                line = stream.readLine();
                if (classFormat.match(line))
                    curSchedule = new ClassSchedule(classFormat.matched(1), classFormat.matched(2), classFormat.matched(3));
                else if (labFormat.match(line) && timeFormat.match(line)) {
                    var a = new Appointment();
                    for (d in timeFormat.matched(2).split(""))
                        a.addDay(new Day(d));
                    a.addInterval(new TimeInterval(timeFormat.matched(1)));
                    curSchedule.addAppointment(a);
                    if (!courses.exists(curSchedule.toString()))
                        courses.set(curSchedule.toString(), curSchedule);
                }
            }
        }
        catch (e:Eof) {}
        
        return courses;
    }

}