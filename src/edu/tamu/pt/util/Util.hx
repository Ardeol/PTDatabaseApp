package edu.tamu.pt.util;

import haxe.io.Path;

import systools.Dialogs;

/** Util Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  **************************************************************************/
class Util {

/**
 *  Returns the location of a file opened with the file dialog.  Only allows a single file to be opened.
 *  @param title Title of the dialog
 *  @param text Text for the dialog
 *  @param extensions List of extensions to support (eg. ["json", "html", "db"])
 *  @return Absolute path to the file
 */
    public static function openFile(title:String, text:String, extensions:Array<String>):String {
        extensions = extensions.map(function(e) {  return '*.$e'; });
        var locations = Dialogs.openFile(title, text, {
            count: 1,
            extensions: extensions,
            descriptions: extensions
        });
        if (locations == null || locations.length <= 0)
            return null;
        else
            return locations[0];
    }
    
/**
 *  Returns the locations for files opened with the file dialog.
 *  @param title Title of the dialog
 *  @param text Text for the dialog
 *  @param extensions List of extensions to support (eg. ["json", "html", "db"])
 *  @return List of absolute paths to the files
 */
    public static function openFiles(title:String, text:String, extensions:Array<String>):Array<String> {
        extensions = extensions.map(function(e) {  return '*.$e'; });
        var locations = Dialogs.openFile(title, text, {
            count: 1,
            extensions: extensions,
            descriptions: extensions
        });
        if (locations == null || locations.length <= 0)
            return null;
        else
            return locations;
    }
    
/**
 *  Returns the location to which a file should be saved.
 * 
 *  Note: This function only supports a single extension.  The use of an array as a parameter is in case
 *  future versions support saving to one of many extensions.  Modifying the function to support this
 *  change would not break the API.
 *  @param title Title of the dialog
 *  @param text Text for the dialog
 *  @param initialDirectory The starting directory of the dialog
 *  @param extensions List of extensions to support (eg. ["json", "html", "db"]) 
 *  @return Absolute path to the file
 */
    public static function saveFile(title:String, text:String, initialDirectory:String, extensions:Array<String>):String {
        var extensions_ = extensions.map(function(e) {  return '*.$e'; });
        var location = Dialogs.saveFile(title, text, initialDirectory, {
            count: 1,
            extensions: extensions_,
            descriptions: extensions_
        });
        if (location == null || location.length <= 0)
            return null;
            
        var patt = new EReg('\\.${extensions[0]}$$', "");
        if (!patt.match(location))
            location += '.${extensions[0]}';
        return location;
    }
    
/**
 *  Finds a relative path of path relative to relativeTo.  Both arguments must be absolute paths.
 *  @param path Absolute path of the file to find a relative path for
 *  @param relativeTo Absolute path of a directory
 */
    public static function relativePath(path:String, relativeTo:String):String {
        if (!Path.isAbsolute(path) || !Path.isAbsolute(relativeTo))
            return path;
        path = Path.normalize(path);
        relativeTo = Path.normalize(relativeTo);
        
        var pathDirs = path.split("/");
        var relToDirs  = relativeTo.split("/");
        var i = 0;
        while (i < pathDirs.length && i < relToDirs.length && pathDirs[i] == relToDirs[i])
            ++i;
        var relativePathBuf = new StringBuf();
        for (j in 0...(relToDirs.length - i))
            relativePathBuf.add("../");
        for (j in i...pathDirs.length)
            relativePathBuf.add(pathDirs[j] + (j != pathDirs.length - 1 ? "/" : ""));
            
        return relativePathBuf.toString();
    }
    
}