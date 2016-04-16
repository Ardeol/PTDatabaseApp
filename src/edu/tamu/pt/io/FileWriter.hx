package edu.tamu.pt.io;

import sys.io.File;
import sys.io.FileOutput;

/** FileWriter Class
 *  @author  Timothy Foster
 *  
 *  Writes a given object to a file.  This class is meant to be extended, and
 *  parse() should be overridden.
 *  **************************************************************************/
class FileWriter<T> {
/**
 *  File path to read from
 */
    public var path:String;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Creates a new FileWriter for a given path.
 *  @param path Valid file path.
 */
    public function new(path:String) {
        this.path = path;
    }

/*  Public Methods
 *  =========================================================================*/
/**
 *  Write to the file given an object
 *  @param obj The object to write to the file
 *  @param append Whether to append the object or not; by default will overwrite file contents.
 */
    public function write(obj:T, append:Bool = false):Void {
        var handle = append ? File.append(path) : File.write(path);
        parse(obj, handle);
        handle.close();
    }
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Use a FileOutput object to write to a file.
 *  @param obj The object to write
 *  @param out A FileOutput stream
 */
    private function parse(obj:T, out:FileOutput):Void {}
}