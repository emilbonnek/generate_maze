#!/usr/bin/env ruby

# Versionsummer
VERSION = "1.0"

# Inkluder biblioteker
require 'optparse'
require 'active_support/core_ext/hash'
require 'chunky_png'

# 
# Cell er en datastruktur der bruges til at ræpresentere celler.
#
Cell = Struct.new(:visited, :connected_up, :connected_left)
# 
# Maze klassen bruges til at repræsentere en labyrint.
#
class Maze
  # Denne linje gør at width og heigth kan læses ude fra klassen.
  attr_reader :width, :height
  #
  # Denne funktion er klassens constructor.
  # Den gemmer labyrintens bredde og højde,
  # og et 2D-array med Cell objekter. Dernæst sætter den genereringen igang. 
  #
  def initialize(options = {})
    # Overskriv default indstillingerne med de indstillinger der blev givet til funktionen.
    defaults = {maze_width: 10,
                maze_height: 10}
    options.reverse_merge!(defaults)

    @width, @height = options[:maze_width], options[:maze_height]
    
    @grid = Array.new(@height) { Array.new(@width) { Cell.new } }
    generate
  end
  #
  # Denne funktion bruges til at identificere en labyrint.
  #
  def inspect
    "#<#{self.class.name} #{@width}x#{@height}>"
  end
  #
  # Denne funktion bruges til at vise labyrinten som ASCII.
  # Koden er en smule spaghetti, men princippet er beskrevet i rapporten under afsnit 6.2.
  #
  def to_s(options = {})
    defaults = {cell_width: 3,
                cell_height: 1}
    options.reverse_merge!(defaults)
    
    s = String.new
    # Den følgende kode er lidt rodet, men princippet er forklaret i rapporten under afsnit 6.2.
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
  #
  # Denne funktion bruges til at eksportere labyrinten som .png samt at returnere til stien til filen.
  # Her benyttes 'Chunky_png' biblioteket, som blev hentet ind øverst i programmet.
  # Koden er en smule spaghetti, men princippet er beskrevet i rapporten.
  #
  def export_to_png(options = {})
    # Overskriv default indstillingerne med de indstillinger der blev givet til funktionen
    defaults = {cell_width: 10,
                cell_height: 10,
                background_color: ChunkyPNG::Color::rgb(255,255,255),
                wall_color: ChunkyPNG::Color::rgb(0,0,0),
                file_path: '',
                file_name: 'maze.png'
               }
    options.reverse_merge!(defaults)

    # Opret .png filen
    png_width = @width*(options[:cell_width]+1)+1
    png_height = @height*(options[:cell_height]+1)+1
    png = ChunkyPNG::Image.new(png_width, png_height, options[:background_color])
    # Opret variabler til at manipulere hvorhenne i billed der manipuleres.
    x = y = 0
    # Den følgende kode er lidt rodet, men princippet er forklaret i rapporten under afsnit 6.2.
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
    # Gem filen og returner filens sti og navn
    file = "#{options[:file_path]}#{options[:file_name]}"
    png.save(file)
    return file
  end
  # De resterende metoder i klassen er private
  private
  #
  # Denne funktion er ansvarlig for at generere labyrinten.
  #
  def generate
    # Vælg et tilfældigt koordinat til at starte med.
    random_start = [rand(@width),rand(@height)]
    
    # Opret en stak og læg det tilfældige koordinat på stakken.
    stack = Array.new
    stack.push random_start
    until stack.empty?
      # Tag koordinaterne fra det øverste element på stakken.
      x,y = stack.last
      # Marker cellen som besøgt.
      @grid[y][x].visited = true
      # Gem alle cellens nabo-celler.
      neighbors = Array.new
      neighbors.push [x, y-1] unless y-1 < 0        # Nord
      neighbors.push [x+1, y] unless x+1 >= @width  # Øst
      neighbors.push [x, y+1] unless y+1 >= @height # Syd
      neighbors.push [x-1, y] unless x-1 < 0        # Vest
      # Sorter de naboer fra der allerede er blevet besøgt af algoritmen.
      neighbors.delete_if {|x, y| @grid[y][x].visited }
      # tjek om der er nogle ubesøgte naboer.
      if neighbors.any?
        # Vælg en tilfældig ubesøgt nabo.
        random_neighbor = neighbors.sample
        # Forbind denne celle med den tilfældige nabo.
        connect stack.last, random_neighbor
        # Læg den tilfældige nabo øverst på stakken.
        stack.push random_neighbor
      else
        # Hvis der ingen naboer er, så tager den en celle af stakken.
        stack.pop
      end
    end
  end
  #
  # Denne funktion er ansvarlig for at forbinde to celler sammen.
  #
  def connect(coordinates, other_coordinates)
    # Gør det nemmere at at arbejde med koordinater inde i denne metode.
    x,y = coordinates
    nx, ny = other_coordinates
    # Vurder hvordan forbindelsen skal gemmes. Det skal altid gemmes i cellen nederst eller cellen til højre.
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

# Options og errors bruges til at gemme indstillinger og fejl i parametre.
options = {}
errors = {}
#
# Denne blok er bruges til at beskrive parametrene der gives til scriptet.
# Her benyttes 'optparser' biblioteket, som blev hentet ind øverst i programmet.
# Fordi der bruges optparser bliver der automatisk laven en pæn liste, der gemmes i opts.
#
OptionParser.new do |opts|
  opts.banner =  "Usage:   generate_maze.rb [options]\n"
  opts.banner << "Example: generate_maze.rb -s 30x40 -o\n"
  opts.separator ""
  opts.separator "Specific options:"
  #
  # Ansvarlig for -s parametret.
  # Benytter et regex til at sikre at formatet er på størrelsen er rigtigt.
  # Benytter derefter det samme regex til at definere bredden og højden.
  # Til sidst laver den et lille tjek for om de er i en ordentlig størrelse.
  #
  opts.on("-s", "--size WIDTHxHEIGHT", "Specify maze_size") do |maze_size|
    if maze_size =~ /^\d+x\d+$/
      width, height = maze_size.match(/^(\d+)x(\d+)$/).captures.map &:to_i
      errors[:maze_size] = "must be bigger" if [width,height].min <=0
      options[:maze_width], options[:maze_height]  = width, height
    else
      errors[:maze_size] = "must be in format WIDTHxHEIGHT" unless maze_size =~ /^\d+x\d+$/
    end
  end
  #
  # Ansvarlig for -c parametret.
  # Benytter et regex til at sikre at at formatet på farven er rigtigt.
  # Benytter derefter det samme regex til at definere rgb værdier.
  # Til sidst laver den et lille tjek for om farven findes. 
  #
  opts.on("-c", "--color R,G,B", "Specify wall_color") do |color|
    if color =~ /^\d+,\d+,\d+$/
      r, g, b = color.match(/^(\d+),(\d+),(\d+)$/).captures.map &:to_i
      errors[:wall_color] = "cannot have RGB values of more than 255" if [r,g,b].max > 255
      options[:wall_color] = ChunkyPNG::Color::rgb(r,g,b)
    else
      errors[:wall_color] = "must be in format R,G,B"
    end
  end
  #
  # Ansvarlig for -b parametret.
  # Det helt samme som -c parametret ovenfor.
  #
  opts.on("-b", "--background_color R,G,B","Specify background_color") do |color|
    if color =~ /^\d+,\d+,\d+$/
      r, g, b = color.match(/^(\d+),(\d+),(\d+)$/).captures.map &:to_i
      errors[:background_color] = "cannot have RGB values of more than 255" if [r,g,b].max > 255
      options[:background_color] = ChunkyPNG::Color::rgb(r,g,b)
    else
      errors[:background_color] = "must be in format R,G,B"
    end
  end
  #
  # Ansvarlig for -p parametret.
  # Tjekker bare at filstien findes og sætter et / på enden hvis der mangler.
  #
  opts.on("-p", "--file_path FILE_PATH", "Specify file_path") do |file_path|
    errors[:file_path] = "#{file_path} could not be found" unless File.exists? File.expand_path(file_path)
    file_path << "/" unless file_path.end_with? "/"
    options[:file_path] = file_path
  end
  #
  # Ansvarlig for -n parametret.
  # Sætter .png på enden hvis det mangler.
  #
  opts.on("-n", "--file_name FILE_NAME", "Specify file_name") do |file_name|
    file_name << ".png" unless file_name.end_with? ".png"
    options[:file_name] = file_name
  end
  #
  # Ansvarlig for -a parametret.
  #
  opts.on("-a", "--ascii_preview", "Get an ASCII preview in the terminal (ANSI only)") do |ascii_preview|
    options[:ascii_preview] = ascii_preview
  end
  #
  # Ansvarlig for -o parametret.
  #
  opts.on("-o", "--open_file", "Open the exported maze when it is generated") do |open_file|
    options[:open_file] = open_file
  end
  #
  # Ansvarlig for -h parametret.
  # Udskriver hjælpemenuen.
  #
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  #
  # Ansvarlig for -v parametret.
  # Udskriver verionsnummeren.
  #
  opts.on_tail("-v", "--version", "Show version") do
    puts "Version. #{VERSION}"
    exit
  end
end.parse!

# Hvis der er nogle fejl i parametrene bliver de udskrevet og programmet stopper.
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

# Tag tiden.
start = Time.now

#
# Opret et Maze objekt.
# Eksporter det som .png.
# Og udskriv som ASCII hvis det er ønsket.
#
maze = Maze.new(options)
file = maze.export_to_png options
puts maze if options[:ascii_preview]

# Tag tiden igen og regn ud hvor lang tid det har taget at tegne labyrinten.
finish = Time.now
elapsed = finish - start

# Udskriv en lille rapport over hvad der blev genereret.
report = String.new
report << "---------REPORT---------\n"
report << "Time:  #{elapsed} seconds\n"
report << "Saved: #{file}\n"
report << "------------------------"
puts report

# Åben den eksporterede fil hvis det er ønsket.
system "open #{file}" if options[:open_file]