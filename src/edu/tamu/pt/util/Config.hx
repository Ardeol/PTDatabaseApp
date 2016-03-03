package edu.tamu.pt.util;

/** Config Class
 *  @author  Timothy Foster
 *  @version x.xx.160302
 *
 *  Reads custom data in from an ini file.  Meant to model preferences.
 *  **************************************************************************/
class Config {
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Initializes a new configuration object.
 */
    public function new() {
        sections = new Map<String, ConfigSection>();
        sections.set("", new ConfigSection());
    }
    
/*  Public Methods
 *  =========================================================================*/
/**
 *  Parses an ini string into a configuration object.
 *  @param txt A String in *.ini file format.
 */
    public function parse(txt:String):Void {
        var commentPattern = ~/^\s*[;#!]/;
        var sectionPattern = ~/^\s*\[\s*([^\]]*)\s*\]/;
        var valuePattern   = ~/^\s*([\w\.\-_]+)\s*[=:]\s*(.*)/;

        var curSection = sections.get("");
        var lines = ~/\r\n|\r|\n/g.split(txt);
        for (line in lines) {
            if (commentPattern.match(line))
                continue;
            else if (sectionPattern.match(line)) {
                var sectionName = sectionPattern.matched(1);
                if (!sections.exists(sectionName)) {
                    curSection = new ConfigSection();
                    sections.set(sectionName, curSection);
                }
                else
                    curSection = sections.get(sectionName);
            }
            else if (valuePattern.match(line)) {
                var param = valuePattern.matched(1);
                var value = valuePattern.matched(2);
                curSection.set(param, value);
            }
        }
    }
    
/**
 *  Retrieves an ini section
 *  @param name Name of the section
 *  @return A map of config names to values; null if section does not exist
 */
    public inline function section(name:String):ConfigSection
        return sections.get(name);
    
/**
 *  Retrieves a particular parameter.
 *  @param param The parameter, in the form SECTION.NAME
 *  @return The value of the parameter
 */
    public function get(param:String):String {
        var i = param.indexOf(".");
        if (i < 0)
            return section("").get(param);
        else 
            return section(param.substr(0, i)).get(param.substr(i + 1));
    }
    
/**
 *  Returns the parameter as an integer
 *  @param param The parameter, in the form SECTION.NAME
 */
    public inline function int(param:String):Int
	    return Std.parseInt(get(param));
	
/**
 *  Returns the parameter as a float
 *  @param param The parameter, in the form SECTION.NAME
 */
	public inline function float(param:String):Float
	    return Std.parseFloat(get(param));
        
/**
 *  Returns the parameter as an boolean
 *  @param param The parameter, in the form SECTION.NAME
 */
    public inline function bool(param:String):Bool
        return cast int(param);
    
/**
 *  Turns the current configuration object into a string in the *.ini format.
 */
    public function toString():String {
        var s = new StringBuf();
        for (param in section("").keys())
            s.add('$param=${section("").get(param)}\n');
        for (sec in sections.keys()) {
            if (sec == "")
                continue;
            sec = sec.toUpperCase();
            s.add('\n[$sec]\n');
            for (param in section(sec).keys())
                s.add('$param=${section(sec).get(param)}\n');
        }
        return s.toString();
    }
    
/*  Private Members
 *  =========================================================================*/
    private var sections:Map<String, ConfigSection>;
    
}
 
typedef ConfigSection = Map<String, String>