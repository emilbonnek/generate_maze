# Maze generation script

This script lets you generate random rectangular mazes as .png files. The generated mazes will look something like this:

![maze 1](https://github.com/emilbonnek/generate_maze/blob/master/mazes/1.png)
![maze 2](https://github.com/emilbonnek/generate_maze/blob/master/mazes/2.png)

If you want to use a maze for something, you will probably need to make an entrance and an exit for yourself.

##Installation
###Mac
*   Open the terminal and type `Ruby -v`, you will need at least version 1.9
*   Download this script and put somewhere on your computer
*   Open the terminal and type `Ruby path/to/script/generate_maze.rb -h`

###Windows
*   Start out by [installing Ruby](http://rubyinstaller.org/), you will need at least version 1.9
*   Download this script and put it somewhere on your computer
*   Open the command prompt and type `Ruby path/to/script/generate_maze.rb -h`

###Linux
*   Start out by [installing Ruby](https://www.ruby-lang.org/en/documentation/installation/), you will need at least version 1.9
*   Download this script and put somewhere on your computer
*   Open the terminal and type `Ruby path/to/script/generate_maze.rb -h`

##Getting started
Running the script with `-h` will produce a help message. If you can get that help message to appear, you should be able to start appending other parameters. 

###Parameters
The following is all the possible parameters:

| Name                     | Short | Effect                                           |
|--------------------------|-------|--------------------------------------------------|
| --size WIDTHxHEIGHT      | -s    | Specify maze_size                                |
| --color R,G,B            | -c    | Specify wall_color                               |
| --background_color R,G,B | -b    | Specify background_color                         |
| --file_path FILE_PATH    | -p    | Specify file_path                                |
| --file_name FILE_NAME    | -n    | Specify file_name                                |
| --ascii_preview          | -a    | Get an ASCII preview in the terminal (ANSI only) |
| --open_file              | -o    | Open the exported maze when it is generated      |
| --help                   | -h    | Get a help message                               |
| --version                | -v    | Show version                                     |
