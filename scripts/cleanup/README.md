
# Language-specific cleanup scripts

Cleanup scripts can be collected in language-specific sub-directories.
Each script should read lines from STDIN and print to STDOUT and should produce the same number of lines in the output as there are in the input (to make sure that sentence alignment doesn't break). Parameters are not supported by the data processing pipeline implemented in Makefile.data that uses those scripts. By default the makefile will use all exectuable files in the language sub-directory.

