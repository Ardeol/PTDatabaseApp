The **PTDatabaseApp** is a desktop application meant to make peer teacher management simple and easy for the Texas A&M Computer Science faculty.  This application is the one-way stop for scheduling labs, managing office hours, keeping records of previous semesters, and generating resources (like webpages and Excel sheets).

Features
========

* You can load databases from JSON files, thereby allowing any number of databases to exist.  Presumably, you would have one database per semester.
* You can export database files
* You can load multiple schedules for peer teachers simultaneously
* You can load all the labs for computer science given a courses file
* You can assign peer teachers to labs without worry of scheduling conflicts arising
* You can assign labs to peer teachers as well
* You can easily assign office hours to peer teachers
* You can view a concise list of the peer teachers and their assigned labs/office hours
* You can view a concise list of the labs as well
* You can export either of the above two lists to an Excel file
* You can generate the required webpage to an HTML file
* You can generate a poster to an HTML file as well where it can then be converted into a PDF

Additionally...
* If stored on a shared drive, any number of assigned supervisors may access the program and the shared database files
* Courses are configurable in case updates to the Computer Science program are made in the future
* Progress is saved automatically, so you never need to worry about saving yourself

Technologies
============

This program was written using the [Haxe](http://haxe.org/) programming language.  Additionally, the following libraries were used:

* [OpenFL](http://www.openfl.org/)
* [HaxeUI](http://haxeui.org/)
* [systools](https://github.com/waneck/systools)

Modifying the Program
=====================

To compile this program, you must install Haxe and all of the above libraries.  The below steps show how to do this.

1. Download and install Haxe
2. Open up a terminal and run the following command:
```
haxelib setup
``` 
3. Now install the libraries with the below three commands:
```
haxelib install openfl
haxelib install haxeui
haxelib install systools
```
    
4. Clone this project to a folder of your choice.  You do this with the following, assuming you have Git on your computer:

    git clone https://github.com/Ardeol/PTDatabaseApp.git
    
5. Go to where you just cloned this project.  Now you can build the project with OpenFL, depending on your platform:

```
openfl build windows
openfl build mac
openfl build linux
```
    
The output is located in the newly created `bin` folder.  From here, you can edit source code and make changes as needed.

Import File Formats
===================

In the program, you can import Peer Teacher Schedule files and Labs files.  This section shows how to obtain these files.

Peer Teacher Schedules
----------------------

Before peer teachers can be assigned labs and office hours, their academic schedules for the next semester must be known.  Peer Teachers submit their schedules as a simple text file gathered from the Howdy website.  It is their responsiblity to send in their schedules in the appropriate format to you.  Steps for how they can do this are posted on [the peer teacher website](http://engineering.tamu.edu/cse/academics/peer-teachers/how-to-apply) and outlined briefly here:

1. Login to **Howdy**
2. Go to the **My Record** tab and click **My Schedule**
3. On this page, hit **Ctrl+A** if on Windows, or **Cmd+A** if on Mac.  This selects everything on the page
4. Hit **Ctrl+C** (**Cmd+C** on a Mac) to copy the selection
5. Open up a text editor.  Notepad on Windows is a good choice, or TextEdit on a Mac
6. Hit **Ctrl+V** (**Cmd+V** on a Mac) to paste the contents to the editor.  On a Mac, *make sure TextEdit is in plaintext mode!*
7. Save the file as `Firstname_Lastname.txt`
8. Email the file to the designated authority

The Labs File
-------------

The labs file details all information for computer science courses, including lecture times and classes we don't care about.  The PTDatabaseApp takes all that information and extracts only the bits it needs for assigning peer teachers.

This file is also a simple text (*.txt) file, and you only need one of these per semester.  To obtain it, follow the below instructions:

1. Go to [this link](https://compass-ssb.tamu.edu/pls/PROD/bwckschd.p_disp_dyn_sched).  If the link changes, you should be able to access it by Googling "tamu class schedule"
2. Select the correct term
3. Select CSCE as the subject
4. Click on Class Search at the bottom of the page
5. Ctrl+A
6. Paste into a text editor
7. Save as a .txt file

License
=======
The PTDatabaseApp is free, open-source software licensed under the [MIT License](LICENSE.md).

Modifications and adaptations may be freely made.