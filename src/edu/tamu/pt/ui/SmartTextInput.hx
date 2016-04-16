package edu.tamu.pt.ui;

import haxe.Timer;

import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.events.Event;
import openfl.events.KeyboardEvent;

import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.events.UIEvent;

import systools.Clipboard;

/** SmartTextInput Class
 *  @author  Timothy Foster
 *
 *  The TextInput class with some minor support for Ctrl commands.
 * 
 *  Currently, copying and pasting replaces entire text.  Text selection does
 *  nothing since OpenFL does not support it easily.
 * 
 *  By the way, this class of all things gave me the most headaches.
 *  **************************************************************************/
class SmartTextInput extends TextInput {
    
    public var nextTextInput:TextInput;
    
/*  Constructor
 *  =========================================================================*/
/**
 *  Create a new instance
 */
    public function new() {
        super();
        ctrlDown = false;
        this.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
        this.addEventListener(KeyboardEvent.KEY_UP, keyUp);
        this.nextTextInput = null;
    }
    
/*  Private Members
 *  =========================================================================*/
    private static inline var CTRL_SENSITIVITY = 100; // lower = more rigid

    private var ctrlDown:Bool;
 
/*  Private Methods
 *  =========================================================================*/
/**
 *  @private
 *  Sets whether the control is down upon a keypress
 *  @param e
 */
    private function keyDown(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.CONTROL || e.keyCode == Keyboard.COMMAND)
            ctrlDown = true;
        else if (e.keyCode == Keyboard.TAB && nextTextInput != null)
            nextTextInput.focus();
    }
    
/**
 *  Performs an action if the ctrl is down
 *  @param e
 */
    private function keyUp(e:KeyboardEvent):Void {
        if (e.keyCode == Keyboard.CONTROL || e.keyCode == Keyboard.COMMAND)
        //  The delay here is for people who release control before releasing the letter key
            Timer.delay(function() {  ctrlDown = false; }, CTRL_SENSITIVITY);
        if (ctrlDown) {
            switch(e.keyCode) {
                case Keyboard.C: copy();
                case Keyboard.V: paste();
            }
        }
    }
    
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
        if (txt == null)
            return;
        if (!this.multiline)
            txt = ~/[\r\n]/g.replace(txt, "");
        this.text = txt;
        preventStrayCharacter();
        dispatchEvent(new Event(UIEvent.CHANGE));
    }
    
/**
 *  @private
 *  Without this function, Ctrl+letter will also input this letter.
 * 
 *  The letter is prevented with a millisecond delay that resets the text.
 */
    private function preventStrayCharacter():Void {
        var txt = this.text;
        Timer.delay(function() {  this.text = txt; }, 1);
    }
}