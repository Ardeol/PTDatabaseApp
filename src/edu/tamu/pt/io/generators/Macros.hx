package edu.tamu.pt.io.generators;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Format;
import sys.io.File;

/** Macros Class
 *  @author  Timothy Foster
 *  @version A.00
 *
 *  My very first haxe macro.  Weep in its glorious presence.
 *  **************************************************************************/
class Macros {

/**
 *  Loads an HTML partial from the macros asset folder.  The partial may contain Haxe interpolation variables
 *  such as $student, or $class.  At compile-time, these variables are resolved in the appropriate generator.
 * 
 *  Inspired by http://stackoverflow.com/questions/22746216/haxe-macro-open-file-with-relative-path.
 * 
 *  @param generator Text name of the generator.  WebPageGenerator should become "webpage"
 *  @param partial The name of the html partial, without ".html" in it.
 *  @return A interpolatable Haxe string from the file.
 */
    public static macro function getGeneratorHtml(generator:String, partial:String):ExprOf<String> {
        var fileContents:String = "";
        try {
            fileContents = File.getContent('assets/macro/generators/$generator/$partial.html');
        }
        catch (e:Dynamic) {
            return Context.makeExpr(Context.error('Failed to load generator html partial for $generator $partial', Context.currentPos()), Context.currentPos());
        }
        
        return Format.format(Context.makeExpr(fileContents, Context.currentPos()));
    }
    
}