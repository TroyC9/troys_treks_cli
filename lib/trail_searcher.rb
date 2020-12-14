class TrailSearcher

    def run
        puts "\nHello!"
        self.greeting
        self.prompt_zip
        self.prompt_trail_details
        self.exit_prompt
    end 

    def greeting
        puts "\nWhat is your name? "
        user_name = gets.chomp
        if user_name.match(/^[a-zA-z]+$/)
            print "\nWelcome, " + "#{user_name.capitalize}"
            print " to"
            2.times {puts "\n"}
            puts "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ ".colorize(:light_green) + "\nTroy's Treks, a Trail Finder CLI Application\n powered by the Hiking Project".colorize(:light_green)
            puts "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\".colorize(:light_blue)
            2.times {puts "\n"}
        else 
            puts "\nYour input of '".colorize(:light_red) + "#{user_name}".colorize(:light_yellow) + "' is invalid. Please try again.".colorize(:light_red)
            self.greeting 
        end 
    end

    def prompt_zip
        puts "\nPlease enter the five digit zip code of where you would like to hike."
        zip_code = gets.chomp
        if zip_code.match(/^\d{5}$/)
            self.zip_conversion(zip_code)
        else 
            puts "\nThe Zip Code '".colorize(:light_red) + "#{zip_code}".colorize(:light_yellow) + "' is not valid. Please try again".colorize(:light_red)
            self.prompt_zip
        end 
    end

    def zip_conversion(zip_code)
        results = Geocoder.search(zip_code)
        if results[0] != nil && results[0].data["address"]["city"] != nil
            lat = results[0].data["lat"]
            long = results[0].data["lon"]
            city = results[0].data["address"]["city"]
            state = results[0].data["address"]["state"]
            puts "\n'" + "#{zip_code}".colorize(:light_yellow) + "' which is located in #{city}, #{state}."
            self.prompt_distance(lat, long, city, state, zip_code)
        else 
            puts "\nWe can't seem to find any trails near '".colorize(:light_red) + "#{zip_code}".colorize(:light_yellow) + "'. Please try again".colorize(:light_red)
            self.prompt_zip
        end 
    end

    def prompt_distance(lat, long, city, state, zip_code)
        puts "\nHow far away from #{city}, #{state} would you like to travel (between 1-100 miles):"
        dist = gets.chomp
        if (1..100).include?(dist.to_i) && dist.match(/^\d+$/)
            puts "\nYou entered '" + "#{dist}".colorize(:light_yellow) + "' miles.\n"
            puts "\n"
            self.get_trails(lat, long, dist, city, state, zip_code)
        elsif dist != "restart"
            puts "\nOops, that was not a valid response, /n Try Again"
            self.prompt_distance(lat, long, city, state, zip_code)
        else 
            self.prompt_zip
        end 
    end

    def get_trails(lat, long, dist, city, state, zip_code)        trails_array = TrailImporter.get_trails_by_lat_long_dist(lat, long, dist)
        if trails_array[0] != nil 
            puts "Here are the trails available within " + "#{dist} miles".colorize(:light_yellow) + " of" + " #{city}, #{state} #{zip_code}".colorize(:light_yellow) + ":"
            puts "\n"
            Trail.create_from_collection(trails_array)
            self.list_trails
        else
            puts "There are no trails available within '".colorize(:light_red) + "#{dist}".colorize(:light_yellow) + "' miles of #{zip_code}.".colorize(:light_red)
            puts "Please try again or enter `".colorize(:light_red) + "restart".colorize(:light_yellow) + "` to enter a new zip code.".colorize(:light_red)
            self.prompt_distance(lat, long, city, state, zip_code)
        end
    end

    def list_trails
        Trail.sort_all.each_with_index do |trail, index|
            puts "#{index + 1}. ".colorize(:light_yellow) + "#{trail.name.upcase}".colorize(:light_cyan) + " -" + " Length: #{trail.length} mi".colorize(:light_blue) + " - #{trail.summary}\n"
        end
    end 
 
    def prompt_trail_details
        puts "\nEnter the " + "number".colorize(:light_yellow) + " corresponding to the specific trail you would like to get more details about."
        trail_num = gets.chomp
        if (1..Trail.all.length).include?(trail_num.to_i)
            self.get_trail_details(trail_num)
        else
            puts "\nYou entered '".colorize(:light_red) + "#{trail_num}".colorize(:light_yellow) + "' which is not a valid choice.".colorize(:light_red)
            self.prompt_trail_details
        end 
    end 

    def get_trail_details(trail_num)
        user_trail = Trail.sort_all[trail_num.to_i - 1]
        puts "\nYou requested more details for" + " #{user_trail.name.upcase}".colorize(:light_yellow) + "..."
        if user_trail.description == nil 
            detail_hash = TrailDetailImporter.get_trail_details_by_url(user_trail.url)
            user_trail.add_trail_attributes(detail_hash)
        end 
        self.list_trail_details(user_trail)
    end 

    def list_trail_details(user_trail)
        2.times {puts "\n"}
        puts "**********************************************"
        puts "\nTrail Details for ".colorize(:light_cyan) + "#{user_trail.name.upcase}".colorize(:light_yellow)
        puts "\nLength: ".colorize(:light_cyan) + "#{user_trail.length} miles"
        puts "Level of Difficulty: ".colorize(:light_cyan) + "#{user_trail.difficulty}"
        puts "Dogs Allowed?: ".colorize(:light_cyan) + "#{user_trail.dogs}"
        puts "Route Type:".colorize(:light_cyan) + "#{user_trail.route}"
        puts "Highest Elevation: ".colorize(:light_cyan) + "#{user_trail.high_elev}"
        puts "Lowest Elevation: ".colorize(:light_cyan) + "#{user_trail.low_elev}"
        puts "Elevation Gain: ".colorize(:light_cyan) + "#{user_trail.elev_gain}"
        puts "\nDescription: ".colorize(:light_cyan) + "#{user_trail.description}\n"
    end 

    def exit_prompt
        user_input = ""
        until user_input == "exit" || user_input == "2"
            puts "\n**********************************************"
            puts "\nSelect '" + "1".colorize(:light_yellow) + "' to go back to your list of trails."
            puts "Select '" + "2".colorize(:light_yellow) + "' to enter a new zip code."
            puts "Enter '" + "exit".colorize(:light_yellow) + "' to close."
            user_input = gets.chomp
            self.exit_logic(user_input)
        end
    end 

    def exit_logic(user_input)
        if user_input == "1"
            puts "\nYou entered '" + "1".colorize(:light_yellow) + "'."
            puts "\n"
            Trail.sort_all.each_with_index do |trail, index|
                puts "#{index + 1}. ".colorize(:light_yellow) + "#{trail.name.upcase}".colorize(:light_cyan) + " -" + " Length: #{trail.length} mi".colorize(:light_cyan) + " - #{trail.summary}\n"
            end
            self.prompt_trail_details
            user_input = ""
        elsif user_input == "2"
            puts "\nYou entered '" + "2".colorize(:light_yellow) + "'."
            Trail.all.clear
            self.prompt_zip
            self.prompt_trail_details
            self.exit_prompt
            user_input = ""
        elsif user_input != "exit"
            puts "\nYour input of '".colorize(:light_red) + "#{user_input}".colorize(:light_yellow) + "' is invalid! Please follow the instructions below:".colorize(:light_red)
        else 
            puts "\n"
            puts "\n*******************************************".colorize(:light_blue)
            puts "\n          HAVE FUN OUT THERE!".colorize(:light_cyan)
            puts "\n*******************************************\n".colorize(:light_blue)
        end 
    end 

end 


# Needs to have: 
# Greet
#Prompt for Zip Code
    # Converts Zip Code to Lat/Long using Geocoder Gem
#Prompt for distance
#List of trails within that distance
    #Prompt user to enter number for coresponding trail
#Display Trail Detail
#Choice Loop to determine if user wants to:
    #go back to previous list to select new trail
    #go back to zip code entry to enter new zipcode and obtain a new list
    #Gives user exit option
#Exit Loop
