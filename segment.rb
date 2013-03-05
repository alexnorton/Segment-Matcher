require 'rgeo'
require 'rgeo/geo_json'
require 'json'

class Segment
	@points

	attr_accessor :points

	def initialize
		@points = Array.new
	end

	def add_point(point)
		@points.push(point)
	end

	def points_count
		@points.count
	end

	def line_string
		factory = ::RGeo::Geographic.spherical_factory
		
		factory.line_string(@points)
	end

	def geojson
		RGeo::GeoJSON.encode(line_string)
	end

	def length
		if line_string
			line_string.length
		end
	end
end