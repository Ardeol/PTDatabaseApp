package edu.tamu.pt.io;

import sys.io.File;
import sys.io.FileOutput;

/** FileWriter Class
 *  @author  Timothy Foster
 *  @version A.00
 *
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
    
/*  Class Methods
 *  =========================================================================*/
    
 
/*  Public Methods
 *  =========================================================================*/
/**
 *  Read the file and return an object corresponding to the read data.
 *  @return Object representing the contents of the file.
 */
    public function write(obj:T, append:Bool = false):Void {
        var handle = append ? File.append(path) : File.write(path);
        parse(obj, handle);
        handle.close();
    }
 
/*  Private Members
 *  =========================================================================*/
    
 
/*  Private Methods
 *  =========================================================================*/
    private function parse(obj:T, out:FileOutput):Void {
        
    }
}