class LolController < ApplicationController
    require 'net/http'
    require 'json'
    require 'date'
    $API_KEY = "RGAPI-678a5a41-14b8-40b3-9057-554f14adec98"
    
    def index # Liste les derniers matchs du joueur
        uri = URI("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/32487406?api_key=#{$API_KEY}")
        
        
        @matchs = JSON.parse(Net::HTTP.get(uri))["matches"].first(25) # 25 derniers matchs
        
        @choisis = select_matchs(@matchs)
        
        @temps_hier = add_durations(@choisis)
    end
    
    def show # Reste plus qu'à sélectionner le dernier timestamp, puis convertir en minutes
        uri = URI("https://euw1.api.riotgames.com//lol/match/v3/matches/3831204745?api_key=#{$API_KEY}")
    
        @match_info = JSON.parse(Net::HTTP.get(uri))
    end
    
    private
    def select_matchs(liste)
        
        selected_matchs = []
        liste.each {|i|
            hier = (DateTime.yesterday).strftime("%m/%d")
            jour_match = DateTime.strptime("#{i["timestamp"]}".first(10), '%s').strftime("%m/%d")
            
            if jour_match == hier
                selected_matchs << i["gameId"]
            end
        }
        return selected_matchs
    end
    
    def add_durations(match_ids)
        total_seconds = 0
        match_ids.each {|i|
            uri = URI("https://euw1.api.riotgames.com//lol/match/v3/matches/3831204745?api_key=#{$API_KEY}")
        
            match_infos = JSON.parse(Net::HTTP.get(uri))
            
            total_seconds += match_infos["gameDuration"]
        }
        Time.at(total_seconds).utc.strftime("%H:%M:%S")
    end
end