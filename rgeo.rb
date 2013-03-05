require 'RGeo'
require 'nokogiri'

spherical_factory = ::RGeo::Geographic.spherical_factory

#cartesian_factory = ::RGeo::Cartesian.factory(:proj4 =>
#  '+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs')

filenames = ["Ride1.gpx", "Ride2.gpx"]

line_strings = Array.new

filenames.each do |filename|

	spherical_points = Array.new

	document = Nokogiri::XML(File.open("./GPX files/#{filename}"))

	document.css("trkpt").each do |element|
		spherical_point = spherical_factory.point(element.attribute("lon").content.to_f, element.attribute("lat").content.to_f)

		spherical_points.push(spherical_point)

	end

	spherical_line = spherical_factory.line_string(spherical_points)

	line_strings.push(spherical_line)

	puts "Length: #{spherical_line.length} metres"

end

line_strings[0].points.each_with_index do |point1, index|
	close_points = 0
	line_strings[1].points.each do |point2|
		if point1.distance(point2) < 15
			close_points += 1
		end
	end
	puts "point #{index} has #{close_points} points within 10 metres"
end