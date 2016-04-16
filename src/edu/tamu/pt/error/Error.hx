package edu.tamu.pt.error;

/** Error Class
 *  @author  Timothy Foster
 *  
 *  General error class which supports class and method reporting.
 *  **************************************************************************/
class Error {
/**
 *  Traceable error message
 */
    public var message(get, never):String;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new error.  Class and method information can be optionally provided.
 *  @param msg Detailed message describing the error and what caused it.
 *  @param cls The class in which the error occurred
 *  @param method The method in which the error occurred
 */
    public function new(msg:String, ?cls:String = "", ?method:String = "") {
        this.msg = msg;
        this.cls = cls;
        this.method = method;
    }
 
/*  Private Members
 *  =========================================================================*/
    private var msg:String;
    private var cls:String;
    private var method:String;
 
/*  Private Methods
 *  =========================================================================*/
    private function get_message():String {
        var str = "ERROR";
        if (cls.length + method.length > 0) {
            str += " in";
            if (cls.length > 0)
                str += ' $cls';
            if (method.length > 0)
                str += ' $method';
        }
        str += ': $msg';
        
        return str;
    }
}