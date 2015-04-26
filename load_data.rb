require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'json'
require 'awesome_print'


class Parser
  IGNORED_TAGS = ["created_by", "source"]

  def initialize
    @popular_attributes = {}
    @count = 0
    @total_count = 0
    @included = 0
  end

  def parse(input, output)
    out = File.new(output, "w")
    begin
      out.write "[\n"
      reader = Nokogiri::XML::Reader(File.new(input))
      while reader = parse_node(reader, out)
      end
    ensure
      out.write "{}\n]\n"
      out.close
      ap @popular_attributes.sort_by { |k,v| v}.reverse
      STDERR.puts ""
      puts "\n#{@included}  #{@count} / #{@total_count}\t"
    end
  end

  def parse_node(r, out)
    (r = r.read; progress) while r && r.name != 'node'
    return false unless r
   
    entry = { 
      :lat => r.attribute("lat"), 
      :lon => r.attribute("lon"), 
    }
    req = ["name"]

    while (progress; r = r.read)
      break if r.name == 'node'
      next unless r.name == 'tag'

      key = r.attribute "k"
      unless IGNORED_TAGS.include? key
        req.delete key
        entry[key] = r.attribute "v"
        @popular_attributes[key] ||= 0
        @popular_attributes[key] += 1
      end
    end

    if entry["amenity"] == "fuel"
      ap entry
    end

    # write_json(out, req, entry)
    progress(true)

    return r
  end

  def write_json out, req, entry
    if req.size == 0
      @included += 1
      out.write(entry.to_json)
      out.write(",\n")
    end
  end

  def progress(entry_found = false)
    @total_count += 1
    @count += 1 if entry_found
    limit = 10000

    if @total_count % limit == 0
      STDERR.print "."
      STDERR.print "\r#{@included} / #{@count} / #{@total_count}\t" if @total_count % (limit * 50)
      STDERR.flush
    end
  end



end

if ARGV.size < 2
  puts "Usage: #{$PROGRAM_NAME} osm_file output_json"
  exit 1
end

Parser.new.parse ARGV[0], ARGV[1]