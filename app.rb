require 'bundler/setup'
Bundler.require(:default)
require_relative 'models/filestore'

before do
	MusicBrainz.configure do |c|
		c.app_name = "My Music App"
		c.app_version = "1.0"
		c.contact = "support@mymusicapp.com"
	end
end

get '/' do 
	@all_historical_query_results = Filestore.all
	erb :index
end

post '/' do 
	#Set up vars for query 

	#This comes from the radio button--whether to use the GEM or the Web API
	which_api = params[:technique]

	#Scope this var so we have it available inside and outside the below 'if' statement
	artist_string = ""

	#Conditional based on radio button
	if "gemapi" == which_api
		@results = MusicBrainz::Artist.search(params[:artist_name])
		artist_id = @results[0][:id]
		if artist_id == nil
			artist_id = "N/A"
		end

		#Format our output string to write to our filestore in a format we know how to parse
		#even though we have to fill in some dummy values
		artist_string = "#{params[:artist_name]}, N/A via Gem, N/A via Gem, #{artist_id}"		
	else
		#use Web API technique

		#query_name gets escaped because it turns into a normal "GET"
		query_name = URI.escape (params[:artist_name])

		url = "http://musicbrainz.org/ws/2/artist/?query=artist:#{query_name}&fmt=json"

		#HTTParty returns a Ruby hash since it's given JSON data
		response = HTTParty.get(url)
		
		artist_id = response["artist"][0]["id"]

		#Make the results pretty even if the MusicBrainz API didn't give us results
		if artist_id == nil
			artist_id = "N/A"
		end

		artist_birth = response["artist"][0]["life-span"]["begin"]
		if artist_birth == nil
			artist_birth = "N/A"
		end

		artist_death = response["artist"][0]["life-span"]["ended"]
		if artist_death == nil
			artist_death = "N/A"
		end

		#human readable artist_string = "Artist: #{params[:artist_name]}, b: #{artist_birth}, d: #{artist_death}, Artist ID: #{artist_id}"
		artist_string = "#{params[:artist_name]}, #{artist_birth}, #{artist_death}, #{artist_id}"		
	end
	
	Filestore.create(artist_string)
	redirect '/'
end

