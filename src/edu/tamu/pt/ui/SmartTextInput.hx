package edu.tamu.pt.ui;

import haxe.Timer;

import lime.ui.KeyCode;
import lime.ui.KeyModifier;

import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

import haxe.ui.toolkit.controls.TextInput;

import systools.Clipboard;

import edu.tamu.pt.util.Key;

/** SmartTextInput Class
 *  @author  Timothy Foster
 *  @version x.xx.150823
 *
 *  The TextInput class with some minor support for Ctrl commands.
 * 
 *  Currently, copying and pasting replaces entire text.  Text selection does
 *  nothing since OpenFL does not support it easily.
 *  **************************************************************************/
class SmartTextInput extends TextInput {

/**
 *  Create a new instance
 */
    public function new() {
        super();
        this.addEventListener(KeyboardEvent.KEY_DOWN, performPress);
        //Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, performPress);
        //this.addEventListener(Event.ENTER_FRAME, performPress);
    }
    
/**
 *  @private
 *  The press action, depending on the key.
 *  @param  e
 */
/*
    private function performPress(e:Event):Void {
        if (Key.isDown(Keyboard.CONTROL))
            trace("Control is down");
        trace(Key.keysDown());
    }
/*  */
/*  */
    private function performPress(e:KeyboardEvent):Void {
    /*
        if (e.ctrlKey) {
            switch(e.keyCode) {
                case Keyboard.C: copy();
                case Keyboard.V: paste();
            }
        }
    /*  */
        if (e.ctrlKey)
            if (e.keyCode == Keyboard.V)
                trace("Success!");
    }
/*  */
    
/**
 *  @private
 *  Copies the text to the clipboard
 */
    private function copy():Void {
        //var txt = this.text.substring(this.selectionBeginIndex, this.selectionEndIndex);
        var txt = this.text;
        Clipboard.setText(txt);
        preventStrayCharacter();
    }
    
/**
 *  @private
 *  Pastes from the clipboard to the field.  Newlines are removed if not multiline.
 */
    private function paste():Void {
        //this.replaceSelectedText(Clipboard.getText());
        var txt = Clipboard.getText();
        if (!this.multiline)
            txt = ~/[\r\n]/g.replace(txt, "");
        this.text = txt;
        preventStrayCharacter();
    }
    
/**
 *  @private
 *  Without this function, Ctrl+letter will also input this letter.
 * 
 *  The letter is prevented with a millisecond delay that resets the text.
 */
    private function preventStrayCharacter():Void {
        var txt = this.text;
        Timer.delay(function() { this.text = txt; }, 1);
    }
}