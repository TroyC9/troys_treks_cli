class TrailDetailImporter

    def self.get_trail_details_by_url(url)
        doc = Nokogiri::HTML(open(url))
        details = {
        :difficulty => doc.css("div.trail-subheader span.difficulty-text").text.strip,
        :route => doc.css("div.mt-2#trail-stats-bar h3")[2].text.strip,
        :high_elev => doc.css("div.mt-2#trail-stats-bar h3")[3].css("span.imperial").text.strip,
        :low_elev => doc.css("div.mt-2#trail-stats-bar h3")[4].css("span.imperial").text.strip,
        :elev_gain => doc.css("div.mt-2#trail-stats-bar h3")[5].css("span.imperial").text.strip,
        :dogs => doc.css("div.mb-1 h3.inline")[0].css("span.font-body").text.strip,
        }
        if doc.css("div.mb-1")[5] != nil
            details[:description] = doc.css("div.mb-1")[5].text.strip
        else
            details[:description] = "Not available"
        end 
        details 
    end
    
end 
