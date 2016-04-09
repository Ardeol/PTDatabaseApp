package edu.tamu.pt;

import edu.tamu.pt.util.Config;

/** ConfigContract Class
 *  @author  Timothy Foster
 *
 *  This represents the config file for the database.  It is based off of the
 *  Config class, but only allows access to the allowed parameters.
 *  **************************************************************************/
abstract PTDatabaseConfig(Config) from Config {
    public static inline var DBPATH = "dbpath";
    public static inline var RELEVANT_CLASSES = "relevantclasses";
    public static inline var NONLAB_CLASSES = "nonlabclasses";
    
/**
 *  The path to the database file.
 */
    public var dbpath(get, set):String;
    
/**
 *  Comma-separated list of relevant classes.  This is of the form 121,221,315,etc.
 */
    public var relevantClasses(get, set):String;
    
/**
 *  Comma-separated list of classes which do not have labs but should be included.  Format is 222,314,etc.
 */
    public var nonlabClasses(get, set):String;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Constructs a new config instance
 */
    public inline function new() {
        this = new Config();
        setDefaults();
    }
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Resets the parameters to their default values.
 */
    public inline function setDefaults():Void {
        dbpath = "data/db.json";
        relevantClasses = "110,111,113,121,206,221,222,312,313,314,315";
        nonlabClasses = "222,314";
    }
    
/**
 *  Parses a config file into this object.  This will filter out any invalid or unapplied parameters.
 *  @param txt The raw contents of the config file.
 */
    public function parse(txt:String):Void {
        var c = new Config();
        c.parse(txt);
        if (c.exists(DBPATH))
            dbpath = c.get(DBPATH);
        if (c.exists(RELEVANT_CLASSES))
            relevantClasses = c.get(RELEVANT_CLASSES);
        if (c.exists(NONLAB_CLASSES))
            nonlabClasses = c.get(NONLAB_CLASSES);
    }
 
/**
 *  Returns the string version of the config.
 *  @return To be written to the file.
 */
    public inline function toString():String
        return this.toString();
 
/*  Private Methods
 *  =========================================================================*/
    private inline function get_dbpath():String 
        return this.get(DBPATH);
    private inline function set_dbpath(value:String):String {
        this.section("").set(DBPATH, value);
        return value;
    }
    
    private inline function get_relevantClasses():String 
        return this.get(RELEVANT_CLASSES);
    private inline function set_relevantClasses(value:String):String {
        this.section("").set(RELEVANT_CLASSES, value);
        return value;
    }
    
    private inline function get_nonlabClasses():String 
        return this.get(NONLAB_CLASSES);
    private inline function set_nonlabClasses(value:String):String {
        this.section("").set(NONLAB_CLASSES, value);
        return value;
    }
    
}