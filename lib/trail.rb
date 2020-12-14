class Trail

    attr_accessor :trail_id, :name, :summary, :length, :url, :difficulty, :description, :route, :high_elev, :low_elev, :elev_gain, :dogs

    @@all = []

    def initialize(trail_hash)
        trail_hash.each {|attr_name, attr_value| self.send("#{attr_name}=", attr_value)}
        @@all << self 
    end 

    def self.create_from_collection(trail_array)
        trail_array.each {|trail| self.new(trail)}
    end 

    def add_trail_attributes(attributes_hash)
        attributes_hash.each {|attr_name, attr_value| self.send("#{attr_name}=", attr_value)}
        self
    end 

    def self.all
        @@all
    end 

    def self.sort_all
        self.all.sort_by {|a| a.length}
    end 

end 