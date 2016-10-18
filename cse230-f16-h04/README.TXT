The files in 'win' terminate each line with the Windows end-of-line character sequence 0x0d, 0x0a. The files
in 'unix' (for Linux and Mac users as well) terminate each line with the Unix end-of-line character 0x0a.
Both of these should display fine in MARS, but if all of the text appears on one line in the editor window
(this typically happens when a Unix-created text file containing 0x0a for the end-of-line character is loaded
into a text editor on Windows that does not recognize this char as a valid end-of-line character sequence).
If the files when loaded into MARS are not correctly displayed, try using the other set of files.