require 'sinatra'
require 'httparty'
require 'nokogiri'
require 'uri'
require 'csv'

get '/' do
	erb :index
end

get '/search' do
	@id = params["id"]

	@encoded = URI.encode(@id)

	url = "http://www.op.gg/summoner/userName=#{@encoded}"
	resonse = HTTParty.get(url)

	html = Nokogiri(resonse.body)
	@win = html.css('#SummonerLayoutContent > div.tabItem.Content.SummonerLayoutContent.summonerLayout-summary > div.SideContent > div.TierBox.Box > div.SummonerRatingMedium > div.TierRankInfo > div.TierInfo > span.WinLose > span.wins').text
	@lose = html.css('#SummonerLayoutContent > div.tabItem.Content.SummonerLayoutContent.summonerLayout-summary > div.SideContent > div.TierBox.Box > div.SummonerRatingMedium > div.TierRankInfo > div.TierInfo > span.WinLose > span.losses').text
	@tier = html.css('#SummonerLayoutContent > div.tabItem.Content.SummonerLayoutContent.summonerLayout-summary > div.SideContent > div.TierBox.Box > div.SummonerRatingMedium > div.TierRankInfo > div.TierRank > span').text
	
	File.open("log.txt", "a+") do |f|     
	  f.write("#{@id}, #{@tier}, #{@win}, #{@lose}" + "\n")
	  #아이디, 승, 패, 티어 
	end

	CSV.open("log.csv", "a+") do |csv| #CSV야 나 지금 파일을 만들껀데 이름은 log.csv이고 a+타입으로 만들꺼야
		csv << [@id, @tier, @win, @lose, Time.now.to_s]
	end

	erb :search
end