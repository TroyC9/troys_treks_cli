class TrailImporter
    require 'uri'
    require 'openssl'


def self.api_key
    begin
        @@key = File.open(File.expand_path("~/.hikeproj-api-key")).read.strip
    rescue
        puts "Youre gonna need your HikingProject API Key.  Head over to https://www.hikingproject.com/data to get your Private Key.  Once you're done, come back here and paste your key here:"
        @@key = gets.strip 
              return if @@key == "exit"
              File.open(File.expand_path("~/.hikeproj-api-key"), "w") do |file|
                file.print @@key
              end
            end
            @@key
          end
def self.get_trails_by_lat_long_dist (lat, long, dist)
    url = "https://www.hikingproject.com/data/get-trails?lat=#{lat}&lon=#{long}&maxDistance=#{dist}&key=#{@@key}"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    output = JSON.parse(response.body)
    output["trails"].collect do |trail|
        hash = {
            :trail_id => trail["id"],
            :name => trail["name"],
            :summary => trail["summary"],
            :length => trail["length"],
            :url => trail["url"]
        }
    end 
end

end 