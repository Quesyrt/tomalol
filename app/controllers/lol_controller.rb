class LolController < ApplicationController
    require 'net/http'
    require 'json'
    require 'date'
    $API_KEY = "RGAPI-cb510d6f-0a93-461d-9c15-20c5dfff9638"
    
    def index # Liste les derniers matchs du joueur
        uri = URI("https://euw1.api.riotgames.com/lol/match/v3/matchlists/by-account/32487406?api_key=#{$API_KEY}")
        
        
        @matchs = JSON.parse(Net::HTTP.get(uri))["matches"]
        
        @mhier = select_hier(@matchs) #Matchs d'hier
        @mlastweek = select_lastweek(@matchs) #Matchs de la semaine précédente
        
        @total_hier_secondes = add_durations(@mhier)
        @hier_time = Time.at(add_durations(@mhier)).utc.strftime("%H heures, %M minutes, et %S secondes")
        
        @total_lastweek_secondes = add_durations(@mlastweek)
        @lastweek_time = Time.at(add_durations(@mlastweek)).utc.strftime("%H heures, %M minutes, et %S secondes")
    end
    
    def show # Reste plus qu'à sélectionner le dernier timestamp, puis convertir en minutes
        uri = URI("https://euw1.api.riotgames.com//lol/match/v3/matches/3831204745?api_key=#{$API_KEY}")
    
        @match_info = JSON.parse(Net::HTTP.get(uri))
    end
    
    private
    def select_hier(liste)
        return nil if liste == nil
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
    
    def select_lastweek(liste)
        return nil if liste == nil
        
        selected_matchs = []
        liste.each {|i|
            now = DateTime.now
            lastw = now-now.wday-6
            thisw = now-now.wday
            
            debut_sem = lastw.strftime("%m/%d")
            fin_sem = thisw.strftime("%m/%d")
            jour_match = DateTime.strptime("#{i["timestamp"]}".first(10), '%s').strftime("%m/%d")
            
            if jour_match <= fin_sem && jour_match >= debut_sem
                selected_matchs << i["gameId"]
            end
        }
        return selected_matchs
    end
    
    def add_durations(match_ids)
        return nil if match_ids == nil
        total_seconds = 0
        match_ids.each {|i|
            uri = URI("https://euw1.api.riotgames.com//lol/match/v3/matches/#{i}?api_key=#{$API_KEY}")
        
            match_infos = JSON.parse(Net::HTTP.get(uri))
            total_seconds += match_infos["gameDuration"] if match_infos["gameDuration"] != nil
        }
        return total_seconds
    end
end