#!/usr/bin/env ruby
VERSION = "1.0"
require 'optparse'
require 'active_support/core_ext/hash'
require 'chunky_png'
Cell = Struct.new(:visited, :connected_up, :connected_left)
class Maze
  attr_reader :width, :height
  def initialize(options = {})
    defaults = {maze_width: 10,
                maze_height: 10}
    options.reverse_merge!(defaults)
    @width, @height = options[:maze_width], options[:maze_height]
    @grid = Array.new(@height) { Array.new(@width) { Cell.new } }
    generate
  end
  def inspect
    "#<#{self.class.name} #{@width}x#{@height}>"
  end
  def to_s(options = {})
    defaults = {cell_width: 3,
                cell_height: 1}
    options.reverse_merge!(defaults)
    s = String.new
    @grid.each do |row|
      row.each do |cell|
        s << "+"
        cell.connected_up ? s << " "*options[:cell_width] : s << "-"*options[:cell_width]
        options[:cell_height].times do
          s << "\v"+"\b"+"\b"*options[:cell_width]
          cell.connected_left ? s << " " : s << "|"
          s << " "*options[:cell_width]
        end
        s << "\e[A"*options[:cell_height]
      end
      s << "+"+"\v\b|"*options[:cell_height]+"\n"
    end
    @width.times do
      s << "+"
      s << "-"*options[:cell_width]
    end
    s << "+\n"
    return s
  end
  def export_to_png(options = {})
    defaults = {cell_width: 10,
                cell_height: 10,
                background_color: ChunkyPNG::Color::rgb(255,255,255),
                wall_color: ChunkyPNG::Color::rgb(0,0,0),
                file_path: '',
                file_name: 'maze.png'
               }
    options.reverse_merge!(defaults)
    png_width = @width*(options[:cell_width]+1)+1
    png_height = @height*(options[:cell_height]+1)+1
    png = ChunkyPNG::Image.new(png_width, png_height, options[:background_color])
    x = y = 0
    @grid.each do |row|
      row.each do |cell|
        png[x,y] = options[:wall_color]
        if cell.connected_up
          options[:cell_width].times do
            x += 1
          end
        else
          options[:cell_width].times do
            x += 1
            png[x,y] = options[:wall_color]
          end
        end
        x -= options[:cell_width]
        if cell.connected_left
          options[:cell_height].times do
            y += 1
          end
        else
          options[:cell_height].times do
            y += 1
            png[x,y] = options[:wall_color]
          end
        end
        x += options[:cell_width]+1
        y -= options[:cell_height]
      end
      png[x,y] = options[:wall_color]
      options[:cell_height].times do
        y += 1
        png[x,y] = options[:wall_color]
      end
      y += 1
      x = 0
    end
    png[x,y] = options[:wall_color]
    @width.times do
      x += 1
      png[x,y] = options[:wall_color]
      options[:cell_width].times do
        x += 1
        png[x,y] = options[:wall_color]
      end
    end
    file = "#{options[:file_path]}#{options[:file_name]}"
    png.save(file)
    return file
  end
  private
  def generate
    random_start = [rand(@width),rand(@height)]
    stack = Array.new
    stack.push random_start
    until stack.empty?
      x,y = stack.last
      @grid[y][x].visited = true
      neighbors = Array.new
      neighbors.push [x, y-1] unless y-1 < 0
      neighbors.push [x+1, y] unless x+1 >= @width
      neighbors.push [x, y+1] unless y+1 >= @height
      neighbors.push [x-1, y] unless x-1 < 0
      neighbors.delete_if {|x, y| @grid[y][x].visited }
      if neighbors.any?
        random_neighbor = neighbors.sample
        connect stack.last, random_neighbor
        stack.push random_neighbor
      else
        stack.pop
      end
    end
  end
  def connect(coordinates, other_coordinates)
    x,y = coordinates
    nx, ny = other_coordinates
    if x > nx
      @grid[y][x].connected_left = true
    elsif x < nx
      @grid[ny][nx].connected_left = true
    elsif y > ny
      @grid[y][x].connected_up = true
    elsif y < ny
      @grid[ny][nx].connected_up = true
    end
  end
end
options = {}
errors = {}
OptionParser.new do |opts|
  opts.banner =  "Usage:   generate_maze.rb [options]\n"
  opts.banner << "Example: generate_maze.rb -s 30x40 -o\n"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on("-s", "--size WIDTHxHEIGHT", "Specify maze_size") do |maze_size|
    if maze_size =~ /^\d+x\d+$/
      width, height = maze_size.match(/^(\d+)x(\d+)$/).captures.map &:to_i
      errors[:maze_size] = "must be bigger" if [width,height].min <=0
      options[:maze_width], options[:maze_height]  = width, height
    else
      errors[:maze_size] = "must be in format WIDTHxHEIGHT" unless maze_size =~ /^\d+x\d+$/
    end
  end
  opts.on("-c", "--color R,G,B", "Specify wall_color") do |color|
    if color =~ /^\d+,\d+,\d+$/
      r, g, b = color.match(/^(\d+),(\d+),(\d+)$/).captures.map &:to_i
      errors[:wall_color] = "cannot have RGB values of more than 255" if [r,g,b].max > 255
      options[:wall_color] = ChunkyPNG::Color::rgb(r,g,b)
    else
      errors[:wall_color] = "must be in format R,G,B"
    end
  end
  opts.on("-b", "--background_color R,G,B","Specify background_color") do |color|
    if color =~ /^\d+,\d+,\d+$/
      r, g, b = color.match(/^(\d+),(\d+),(\d+)$/).captures.map &:to_i
      errors[:background_color] = "cannot have RGB values of more than 255" if [r,g,b].max > 255
      options[:background_color] = ChunkyPNG::Color::rgb(r,g,b)
    else
      errors[:background_color] = "must be in format R,G,B"
    end
  end
  opts.on("-p", "--file_path FILE_PATH", "Specify file_path") do |file_path|
    errors[:file_path] = "#{file_path} could not be found" unless File.exists? File.expand_path(file_path)
    file_path << "/" unless file_path.end_with? "/"
    options[:file_path] = file_path
  end
  opts.on("-n", "--file_name FILE_NAME", "Specify file_name") do |file_name|
    file_name << ".png" unless file_name.end_with? ".png"
    options[:file_name] = file_name
  end
  opts.on("-a", "--ascii_preview", "Get an ASCII preview in the terminal (ANSI only)") do |ascii_preview|
    options[:ascii_preview] = ascii_preview
  end
  opts.on("-o", "--open_file", "Open the exported maze when it is generated") do |open_file|
    options[:open_file] = open_file
  end
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  opts.on_tail("-v", "--version", "Show version") do
    puts "Version. #{VERSION}"
    exit
  end
end.parse!
if errors.any?
  error_report = String.new
  error_report << "------------ERRORS------------\n"
  errors.each do |parameter, error_message|
    error_report << "#{parameter} #{error_message}\n"
  end
  error_report <<"------------------------------\n"
  puts error_report
  exit
end
start = Time.now
maze = Maze.new(options)
file = maze.export_to_png options
puts maze if options[:ascii_preview]
finish = Time.now
elapsed = finish - start
report = String.new
report << "---------REPORT---------\n"
report << "Time:  #{elapsed} seconds\n"
report << "Saved: #{file}\n"
report << "------------------------"
puts report
system "open #{file}" if options[:open_file]