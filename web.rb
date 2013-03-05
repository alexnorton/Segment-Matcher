require 'sinatra'
require './track.rb'
require './segment_matcher.rb'
require 'json'

get '/' do
	File.read(File.join('public', 'index.htm'))
end

get '/match.json' do
	content_type :json

	track1 = Track.new("GPX files/#{params[:track1]}")
	track2 = Track.new("GPX files/#{params[:track2]}")

	segment_matcher = SegmentMatcher.new()

	matched_results = segment_matcher.match(track1, track2)

	segments = Array.new

	matched_results[:segments].each do |segment|
		if segment.length
			segments.push({:length => segment.length, :geojson => segment.geojson})
		end
	end

	{:journeys => [ \
		{:length => matched_results[:journey1].length, \
		 :starttime => matched_results[:journey1].start_time, \
		 :endtime => matched_results[:journey1].end_time, \
		 :timings => matched_results[:journey1].segment_timings, \
		 :geojson => matched_results[:journey1].geojson}, \
	 	{:length => matched_results[:journey2].length, \
	 	 :starttime => matched_results[:journey2].start_time, \
	 	 :timings => matched_results[:journey2].segment_timings, \
		 :endtime => matched_results[:journey2].end_time, \
		 :geojson => matched_results[:journey2].geojson} \
	], \
	:segments => segments}.to_json
end

get '/tracks.json' do
	content_type :json

	tracks = Array.new

	Dir.foreach(File.join(File.dirname(__FILE__), "GPX files/")) do |f|
		tracks.push({:filename => f}) unless f[0] == '.'
	end

	{:tracks => (tracks.sort_by { |hash| hash[:filename] } )}.to_json
end 

get '/gpx/*' do
	File.read(File.join('GPX files', params[:splat]))
end