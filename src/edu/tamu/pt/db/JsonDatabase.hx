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
    
/*  Class Methods
 *  =========================================================================*/
    
 
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
    
    public function save():Bool {
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
    
    public function add(pt:PeerTeacher):Void {
        
    }
    
    public function remove(pt:PeerTeacher):Void {
        
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
}

private typedef SDatabase = {
    var labs:Array<JClassSchedule>;
    var pts:Array<JPeerTeacher>;
}