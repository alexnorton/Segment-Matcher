require 'nokogiri'
require 'rgeo'

class Track

	@filename
	@points

	attr_reader :points

	def initialize(filename)
		@filename = filename

		spherical_factory = ::RGeo::Geographic.spherical_factory

		@points = Array.new

		document = Nokogiri::XML(File.open(filename))

		document.css("trkpt").each do |element|
			point = {:point => spherical_factory.point( \
				element.attribute("lon").content.to_f, \
				element.attribute("lat").content.to_f), \
				:datetime => DateTime.parse(element.css("time").first.content)}

			@points.push(point)
		end
	end 


end