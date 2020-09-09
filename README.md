# Generate Maze
This script lets you generate random rectangular mazes as .png files. The generated mazes will look something like this:

![maze 1](https://github.com/emilbonnek/generate_maze/blob/master/mazes/1.png)
![maze 2](https://github.com/emilbonnek/generate_maze/blob/master/mazes/2.png)
![maze 3](https://github.com/emilbonnek/generate_maze/blob/master/mazes/3.png)

If you want to use a generated maze for something, you will probably need to make an entrance and an exit for yourself.

##Requirements
*   Ruby version 1.9 or higher (OS X comes with that installed). 

##Installation
###Mac
*   Press the "Download ZIP" button on this site
*   Unzip the folder onto your dektop
*   Put the generate_maze.rb file on your desktop
*   Press Command(⌘)+Space and type "Terminal" and press Enter
*   Type in `Ruby desktop/generate_maze.rb -h` and press Enter to get started

###Windows
Please help me make this by contacting me on email, I do not own a Windows PC.

###Linux
*   Start out by [installing Ruby](https://www.ruby-lang.org/en/documentation/installation/), (see the requirements section above)
*   Press the "Download ZIP" button on this site
*   Put the generate_maze.rb file on your desktop
*   Open up a terminal
*   Type in `Ruby desktop/generate_maze.rb -h` and press Enter to get started

##Getting started
Running the script with `-h` will produce a help message. If you can get that help message to appear, you should be able to start appending other parameters. Remember to remove the `-h`.

###Parameters
The following is all the possible parameters:

| Name                       | Short | Effect                                           |
|----------------------------|-------|--------------------------------------------------|
| --size WIDTHxHEIGHT        | -s    | Specify maze_size                                |
| --seed SEED                | -g    | Specify seed for generation                      |
| --color (R,G,B)            | -c    | Specify wall_color                               |
| --background_color (R,G,B) | -b    | Specify background_color                         |
| --file_path FILE_PATH      | -p    | Specify file_path                                |
| --file_name FILE_NAME      | -n    | Specify file_name                                |
| --ascii_preview            | -a    | Get an ASCII preview in the terminal (ANSI only) |
| --open_file                | -o    | Open the exported maze when it is generated      |
| --help                     | -h    | Get a help message                               |
| --version                  | -v    | Show version                                     |
