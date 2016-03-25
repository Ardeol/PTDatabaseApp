package edu.tamu.pt.db;

import haxe.Json;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;
import sys.FileSystem;

import edu.tamu.pt.error.Error;
import edu.tamu.pt.io.FileReader;
import edu.tamu.pt.io.FileWriter;
import edu.tamu.pt.struct.ClassSchedule;
import edu.tamu.pt.struct.PeerTeacher;
import edu.tamu.pt.struct.TimeInterval;
import edu.tamu.pt.struct.Appointment;

/** JsonDatabase Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class JsonDatabase implements IDatabase {

/*  Constructor
 *  =========================================================================*/
    public function new() {
        err = new Error("");
        path = "";
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  @inheritDoc
 */
    public function load(specs:Dynamic):Bool {
        if (!Std.is(specs, String)) {
            this.err = new Error("JsonDatabase load expects a String representing a filename", "JsonDatabase", "load");
            return false;
        }
        else {
            try {
                path = specs;
                var reader = new JsonReader(path);
                var obj = reader.read();
                this.ptmap = obj.pts;
                this.labmap = obj.labs;
                return true;
            }
            catch (e:Error) {
                this.err = e;
            }
            catch (e:Dynamic) {
                this.err = new Error("An unknown error has occurred.", "JsonDatabase", "load");
            }
            return false;
        }
    }
    
/**
 *  @inheritDoc
 */
    public function save(?specs:Dynamic):Bool {
        if (specs != null) {
            if (!Std.is(specs, String)) {
                this.err = new Error("JsonDatabase save expects a String representing a filename", "JsonDatabase", "save");
                return false;
            }
            else
                this.path = specs;
        }
        try {
            var writer = new JsonWriter(path);
            writer.write({ labs: labmap, pts: ptmap });
            return true;
        }
        catch (e:Error) {
            this.err = e;
        }
        catch (e:Dynamic) {
            this.err = new Error("An unknown error has occurred.", "JsonDatabase", "save");
        }
        return false;
    }
    
/**
 *  @inheritDoc
 */
    public function error():String {
        return err.message;
    }
    
/**
 *  @inheritDoc
 */
    public function pt(name:String):PeerTeacher {
        return ptmap[name];
    }
    
/**
 *  @inheritDoc
 */
    public function pts(?filter:PeerTeacher->Bool, ?sorter:PeerTeacher->PeerTeacher->Int):Array<PeerTeacher> {
        var arr = new Array<PeerTeacher>();
        for (pt in ptmap)
            if (filter == null || filter(pt))
                arr.push(pt);
        
        if(sorter != null)
            arr.sort(sorter);
        return arr;
    }
    
/**
 *  @inheritDoc
 */
    public function lab(code:String):ClassSchedule {
        return labmap[code];
    }
    
/**
 *  @inheritDoc
 */
    public function labs(?filter:ClassSchedule->Bool, ?sorter:ClassSchedule->ClassSchedule->Int):Array<ClassSchedule> {
        var arr = new Array<ClassSchedule>();
        for (lab in labmap)
            if (filter == null || filter(lab))
                arr.push(lab);
        
        if(sorter != null)
            arr.sort(sorter);
        return arr;
    }
    
/**
 *  @inheritDoc
 */
    public function addPT(pt:PeerTeacher):Void {
        ptmap.set(pt.toString(), pt);
    }
    
/**
 *  @inheritDoc
 */
    public function removePT(pt:PeerTeacher):Void {
        ptmap.remove(pt.toString());
    }
    
/**
 *  @inheritDoc
 */
    public function addLab(lab:ClassSchedule):Void {
        labmap.set(lab.toString(), lab);
    }
    
/**
 *  @inheritDoc
 */
    public function removeLab(lab:ClassSchedule):Void {
        labmap.remove(lab.toString());
    }
    
/**
 *  @inheritDoc
 */
    public function clearPts():Void {
        for (k in ptmap.keys())
            ptmap.remove(k);
    }
    
/**
 *  @inheritDoc
 */
    public function clearLabs():Void {
        for (k in labmap.keys())
            labmap.remove(k);
            
        for (pt in ptmap)
            for (l in pt.labs.keys())
                pt.labs.remove(l);
    }
    
/**
 *  @inheritDoc
 */
    public function clearAll():Void {
        clearPts();
        clearLabs();
    }
 
/*  Private Members
 *  =========================================================================*/
    private var err:Error;
    private var path:String;
    private var ptmap:Map<String, PeerTeacher>;
    private var labmap:Map<String, ClassSchedule>;
 
/*  Private Methods
 *  =========================================================================*/
    
}
/*  ***********************************************************************  *
                                                                  End Class  */


/*  Reader and Writer
 *  =========================================================================*/
private class JsonReader extends FileReader<Dynamic> {
/**
 *  @inheritDoc
 */
    override private function parse(stream:FileInput):Dynamic {
        var data:SDatabase = Json.parse(stream.readAll().toString());
        var labmap = new Map<String, ClassSchedule>();
        for (l in data.labs) {
            var lab:ClassSchedule = l;
            labmap.set(lab.toString(), lab);
        }
        var ptmap = new Map<String, PeerTeacher>();
        for (p in data.pts) {
            var pt:PeerTeacher = p.toPeerTeacher(labmap);
            ptmap.set('${pt.firstname} ${pt.lastname}', pt);
        }
        return { labs: labmap, pts: ptmap };
    }
}

private class JsonWriter extends FileWriter<Dynamic> {
/**
 *  @inheritDoc
 */
    override private function parse(obj:Dynamic, out:FileOutput):Void {
        var labs = new Array<ClassSchedule>();
        var labmap:Map<String, ClassSchedule> = obj.labs;
        for (l in labmap)
            labs.push(l);
        
        var pts = new Array<SPeerTeacher>();
        var ptmap:Map<String, PeerTeacher> = obj.pts;
        for (p in ptmap)
            pts.push(JPeerTeacher.fromPeerTeacher(p));
        
        out.writeString(Json.stringify({ labs: labs, pts: pts }));
    }
}


/*  Json Read/Write conversion
 *  =========================================================================*/
private typedef STimeInterval = {
    var start:Int;
    var end:Int;
}
private abstract JTimeInterval(STimeInterval) from STimeInterval to STimeInterval {
    @:to public function toTimeInterval():TimeInterval {
        var t = new TimeInterval();
        t.start = this.start;
        t.end = this.end;
        return t;
    }
    
    @:from public static function fromTimeInterval(value:TimeInterval):JTimeInterval {
        return Json.parse(Json.stringify(value));
    }
}

private typedef SAppointment = {
    var days:Array<String>;
    var times:Array<JTimeInterval>;
}
private abstract JAppointment(SAppointment) from SAppointment to SAppointment {
    @:to public function toAppointment():Appointment {
        var a = new Appointment();
        for (d in this.days)
            a.addDay(d);
        for (t in this.times)
            a.addInterval(t);
        return a;
    }
    
    @:from public static function fromAppointment(value:Appointment):JAppointment {
        return Json.parse(Json.stringify(value));
    }
}

private typedef SClassSchedule = {
    var dept:String;
    var code:String;
    var section:String;
    var times:Array<JAppointment>;
}
private abstract JClassSchedule(SClassSchedule) from SClassSchedule to SClassSchedule {
    @:to public function toClassSchedule():ClassSchedule {
        var c = new ClassSchedule(this.dept, this.code, this.section);
        for (a in this.times)
            c.addAppointment(a);
        return c;
    }
    
    @:from public static function fromClassSchedule(value:ClassSchedule):JClassSchedule {
        return Json.parse(Json.stringify(value));
    }
}

private typedef SPeerTeacher = {
    var firstname:String;
    var lastname:String;
    var preferredname:String;
    var email:String;
    var image:String;
    var schedule:Array<JClassSchedule>;
    var labs:Array<String>;
    var officeHours:Array<JAppointment>;
}
private abstract JPeerTeacher(SPeerTeacher) from SPeerTeacher to SPeerTeacher {
    public function toPeerTeacher(labmap:Map<String, ClassSchedule>):PeerTeacher {
        var p = new PeerTeacher(this.firstname, this.lastname);
        p.preferredname = this.preferredname;
        p.email = this.email;
        p.image = this.image;
        for (s in this.schedule)
            p.schedule.push(s);
        for (l in this.labs) 
            p.labs.set(l, labmap[l]);
        for (o in this.officeHours)
            p.officeHours.push(o);
        return p;
    }
    
    public static function fromPeerTeacher(p:PeerTeacher):JPeerTeacher {
        var labstrings = new Array<String>();
        for (l in p.labs.keys())
            labstrings.push(l);
        return {
            firstname: p.firstname,
            lastname: p.lastname,
            preferredname: p.preferredname,
            email: p.email,
            image: p.image,
            schedule: cast p.schedule,
            labs: labstrings,
            officeHours: cast p.officeHours
        };
    }
}

private typedef SDatabase = {
    var labs:Array<JClassSchedule>;
    var pts:Array<JPeerTeacher>;
}