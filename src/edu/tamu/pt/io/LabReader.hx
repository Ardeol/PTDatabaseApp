package edu.tamu.pt.io;

import haxe.io.Eof;
import sys.io.FileInput;

import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.Day;
import edu.tamu.pt.struct.TimeInterval;

/** LabReader Class
 *  @author  Timothy Foster
 *  @version x.xx.160302
 *
 *  Reads in a Lab data file.
 *  
 *  Instructions for obtaining Lab Data:
 *  
 *  1) Go to https://compass-ssb.tamu.edu/pls/PROD/bwckschd.p_disp_dyn_sched
 *     note: If the link changes, you should be able to access it by Googling "tamu class schedule"
 *  2) Select the correct term
 *  3) Select CSCE as the subject
 *  4) Click on Class Search at the bottom of the page
 *  5) Ctrl+A
 *  6) Paste into a text editor
 *  7) Save as a .txt file
 *  **************************************************************************/
class LabReader extends FileReader<Map<String, ClassSchedule>> {
    private static var classFormat:EReg = ~/(CSCE)\s(\d\d\d)\s-\s(\d\d\d)/;
    private static var timeFormat:EReg = ~/(\d?\d:\d\d\s*[ap]m\s*-\s*\d?\d:\d\d\s*[ap]m)\s*(M?T?W?R?F?)/;
    private static var labFormat:EReg = ~/^\s*Laboratory/;
    
    private var relevantLabs:Array<String>;
    
/**
 *  Creates a new LabReader
 *  @param path Path to the file
 *  @param relevantLabs A list of class codes which should be included in the output.  This list is of the form ["110", "111", ..., "315"].
 */
    public function new(path:String, relevantLabs:Array<String>) {
        super(path);
        this.relevantLabs = relevantLabs;
    }
    
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
                    if (!courses.exists(curSchedule.toString()) && this.relevantLabs.indexOf(curSchedule.code) >= 0)
                        courses.set(curSchedule.toString(), curSchedule);
                }
            }
        }
        catch (e:Eof) {}
        
        return courses;
    }

}