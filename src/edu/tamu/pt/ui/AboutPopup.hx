package edu.tamu.pt.ui;

import haxe.ui.toolkit.core.XMLController;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.controls.TextInput;

/**
 *  AboutPopup Class
 *  @author  Timothy Foster (tfAuroratide)
 */
class AboutPopup extends XMLController {

/*  Constructor
 *  =========================================================================*/
    public function new() {
        super("ui/popups/about.xml");
        
        var githubField = getComponentAs("about-github", TextInput);
        var emailField = getComponentAs("about-email", TextInput);
        
        getComponent("about-text-1").text = "This application was created by " + PTDatabaseApp.AUTHOR + " in 2016 to help make peer teacher management simpler.  Source code is available and may be extended freely at:";
        githubField.text = "github.com/Ardeol/PTDatabaseApp";
        getComponent("about-text-2").text = "You may contact " + PTDatabaseApp.AUTHOR + " by email:";
        emailField.text  = "tf.auroratide@gmail.com";
        getComponent("about-text-3").text = "Version: " + PTDatabaseApp.VERSION;
        
        attachEvent("about-github", UIEvent.CHANGE, keepTextSame.bind(githubField, githubField.text));
        attachEvent("about-email", UIEvent.CHANGE, keepTextSame.bind(emailField, emailField.text));
    }
    
/*  Private Methods
 *  =========================================================================*/
    private function keepTextSame(field:TextInput, text:String, e:UIEvent):Void {
        field.text = text;
    }
}