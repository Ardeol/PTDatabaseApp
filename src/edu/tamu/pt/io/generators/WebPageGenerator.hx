package edu.tamu.pt.io.generators;

import sys.io.FileOutput;

import edu.tamu.pt.db.IDatabase;
import edu.tamu.pt.struct.Appointment;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.util.Sorters;

/** WebPageGenerator Class
 *  @author  Timothy Foster
 *
 *  Creates the HTML for the peer teacher web page.  If the powers that be
 *  update the layout of the website and you find this obsolete, you can edit
 *  the files located in macro/generators/webpage to make this class generate
 *  a different HTML style.  You don't even have to edit this class, unless
 *  the style drastically changes.
 * 
 *  In case you need to know how this works, we use HTML partials.  The HTML
 *  files in the macro folder have variables denoted with a $.  All you have
 *  to do is create a variable of the same name as the one in the partial, and
 *  my Macros class automatically performs the substitution.  It's rather
 *  beautiful, really.
 * 
 *  You can see this in the parseMain function.  The main.html partial has a
 *  $body variable in it.  All the parseMain function needs to do, therefore,
 *  is define var body, and the macro will substitute the value of the body
 *  variable into the partial everywhere where $body appears.
 *  **************************************************************************/
class WebPageGenerator extends Generator {
    public static inline var NAME = "webpage";
    
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
        var bodyBuf = new StringBuf();
        var i = 0;
        while (i < pts.length) {
            var ptLeft = pts[i++];
            if (i < pts.length)
                bodyBuf.add(parsePTBlock(ptLeft, pts[i++]));
            else
                bodyBuf.add(parsePTBlock(ptLeft));
        }
        
        var body = bodyBuf.toString();
        return Macros.getGeneratorHtml("webpage", "main"); // requires body
    }
    
    private function parsePTBlock(ptLeft:PeerTeacher, ?ptRight:PeerTeacher):String {
        var left = parsePT(ptLeft);
        var right = ptRight == null ? "" : parsePT(ptRight);
        return Macros.getGeneratorHtml("webpage", "pt_block"); // requires left, right
    }
    
    private function parsePT(pt:PeerTeacher):String {
        var preferredname = pt.preferredname.length > 0 ? pt.preferredname : pt.firstname;
        var name = '$preferredname ${pt.lastname}';
        var image = pt.image;
        var email = pt.email;
        
    //  Obtaining courses in the right order, formatted so sections are concatenated, is hard
        var coursesBuf = new StringBuf();
        var labArray:Array<ClassSchedule> = Lambda.array(pt.labs);
        labArray.sort(Sorters.labOrder);
        var courseMap = new Map<String, Array<ClassSchedule>>(); // "CSCE ###" -> All class objects with that same code
        Lambda.iter(labArray, function(c) {
            var cStr = '${c.dept} ${c.code}';
            if (!courseMap.exists(cStr))
                courseMap.set(cStr, new Array<ClassSchedule>());
            if(c.section.length > 0)
                courseMap.get(cStr).push(c);
        });
        Lambda.iter(labArray, function(c) {
            var cStr = '${c.dept} ${c.code}';
            if (courseMap.exists(cStr)) {
                coursesBuf.add(parseCourse(cStr, courseMap.get(cStr)));
                courseMap.remove(cStr);
            }
        });
        var courses = coursesBuf.toString();
    //  Finally
        
        var sortedOfficeHours = pt.officeHours.slice(0);
        sortedOfficeHours.sort(Sorters.appointments);
        var hoursBuf = new StringBuf();
        for (h in sortedOfficeHours)
            hoursBuf.add(parseOfficeHours(h));
        var hours = hoursBuf.toString();
            
        return Macros.getGeneratorHtml("webpage", "pt"); // requires name, email, image, courses, hours
    }
    
    private function parseCourse(courseKey:String, sections:Array<ClassSchedule>):String {
        var course = courseKey;
        if(sections.length > 0)
            course += " - " + Lambda.map(sections, function(c) {  return c.section; }).join(", ");
        return Macros.getGeneratorHtml("webpage", "course"); // requires course
    }
    
    private function parseOfficeHours(appt:Appointment):String {
        var days = appt.daysString();
        var times = appt.timesString();
        return Macros.getGeneratorHtml("webpage", "hours");
    }
    
}