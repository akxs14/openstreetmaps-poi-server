require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'json'
require 'awesome_print'
require 'pg'

class Parser
  IGNORED_TAGS = ["created_by", "source"]

  def initialize
    @popular_attributes = {}
    @count = 0
    @total_count = 0
    @included = 0
    @db_conn = PG.connect(dbname: 'ats_suite')
    prepare_insert_gas_station
  end

  def parse(input, output)
    out = File.new(output, "w")
    begin
      # out.write "[\n"p
      reader = Nokogiri::XML::Reader(File.new(input))
      while reader = parse_node(reader, out)
      end
    ensure
      # out.write "{}\n]\n"
      # out.close
      # ap @popular_attributes.sort_by { |k,v| v}.reverse
      # STDERR.puts ""
      # puts "\n#{@included}  #{@count} / #{@total_count}\t"
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
      save_gas_station(entry)
    elsif entry["amenity"] == "cafe"
      save_cafe(entry)
    elsif entry["amenity"] == "pharmacy"
      save_pharmacy(entry)
    end

    # write_json(out, req, entry)
    progress(true)

    return r
  end

  def save_gas_station entry
    puts "Save #{entry["name"]}"
    # ap entry
    insert_gas_station entry
  end

  def save_pharmacy entry

  end

  def save_cafe entry

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
      # STDERR.print "."
      # STDERR.print "\r#{@included} / #{@count} / #{@total_count}\t" if @total_count % (limit * 50)
      # STDERR.flush
    end
  end

  private

  def insert_gas_station entry
    @db_conn.exec_prepared("insert_gas_station", [
      entry[:lat].to_f || 0.0,
      entry[:lon].to_f || 0.0,
      entry["brand"] || "",
      entry["operator"] || "",
      entry["name"] || "",
      entry["addr:country"] || "",
      entry["addr:city"] || "",
      entry["addr:street"] || "",
      entry["addr:housenumber"] || "",
      entry["addr:postcode"] || "",
      entry["phone"] || "",
      entry["shop"] || "no",
      entry["wheelchair"] || "no",
      entry["opening_hours"] || "",
      entry["payment:cash"] || "no",
      entry["payment:mastercard"] || "no",
      entry["payment:visa"] || "no",
      entry["payment:maestro"] || "no",
      entry["payment:dkv"] || "no",
      entry["payment:uta"] || "no",
      entry["payment:fuel_cards"] || "no",
      entry["fuel:diesel"] || "no",
      entry["fuel:GTL_diesel"] || "no",
      entry["fuel:HGV_diesel"] || "no",
      entry["fuel:octane_91"] || "no",
      entry["fuel:octane_95"] || "no",
      entry["fuel:octane_98"] || "no",
      entry["fuel:octane_100"] || "no",
      entry["fuel:octane_102"] || "no",
      entry["fuel:1_25"] || "no",
      entry["fuel:1_50"] || "no",
      entry["fuel:biodiesel"] || "no",
      entry["fuel:svo"] || "no",
      entry["fuel:e10"] || "no",
      entry["fuel:e85"] || "no",
      entry["fuel:biogas"] || "no",
      entry["fuel:lpg"] || "no",
      entry["fuel:cng"] || "no",
      entry["fuel:LH2"] || "no",
      entry["fuel:adblue"] || "no"
    ])
  end

  def prepare_insert_gas_station
    @db_conn.prepare("insert_gas_station", "insert into gas_stations ( " +
      "lat, lon, brand, operator, name, " + 
      "addr_country, addr_city, addr_street, addr_housenumber, addr_postcode, " +
      "phone, shop, wheelchair, opening_hours, " +
      "payment_cash, payment_mastercard, payment_visa, payment_maestro, payment_dkv, payment_uta, payment_fuel_cards, " +
      "fuel_diesel, fuel_GTL_diesel, fuel_HGV_diesel, " + "
      fuel_octane_91, fuel_octane_95, fuel_octane_98, fuel_octane_100, fuel_octane_102, " +
      "fuel_1_25, fuel_1_50, fuel_biodiesel, fuel_svo, fuel_e10, fuel_e85, fuel_biogas, fuel_lpg, " +
      "fuel_cng, fuel_LH2, fuel_adblue) " +
      "values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, " +
      "$11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, " +
      "$26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $40)")
  end

end

if ARGV.size < 2
  puts "Usage: #{$PROGRAM_NAME} osm_file output_json"
  exit 1
end

Parser.new.parse ARGV[0], ARGV[1]
