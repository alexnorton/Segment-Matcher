require 'rgeo'
require 'rgeo/geo_json'

class Journey
	@line_string
	@start_time
	@end_time
	@segments
	@length
	@segment_timings

	attr_reader :length, :start_time, :end_time, :segment_timings

	def initialize(points, start_time, end_time, segments, segment_timings)
		spherical_factory = ::RGeo::Geographic.spherical_factory

		@start_time = start_time
		@end_time = end_time
		@segments = segments
		@segment_timings = segment_timings

		@line_string = spherical_factory.line_string(points)

		@length = @line_string.length
	end

	def geojson
		RGeo::GeoJSON.encode(@line_string)
	end
end