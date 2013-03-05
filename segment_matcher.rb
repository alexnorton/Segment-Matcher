require 'rgeo'
require './segment.rb'
require './journey.rb'

class SegmentMatcher

	@factory
	@distance

	def initialize()
		@factory = ::RGeo::Geographic.spherical_factory
		@distance = 40
	end

	def match(track1, track2)

		segments = Array.new

		segment = nil

		track1.points.each_with_index do |point1, index|
			close_points = 0

			total_lon = point1[:point].x
			total_lat = point1[:point].y

			track2.points.each do |point2|
				if point1[:point].distance(point2[:point]) < @distance
					close_points += 1
					total_lon += point2[:point].x
					total_lat += point2[:point].y
				end
			end

			avg_lon = total_lon / (close_points + 1)
			avg_lat = total_lat / (close_points + 1)
			
			if close_points > 1 or point1 == track1.points.last
				if segment == nil
					segment = Segment.new
				end
				
				segment.add_point(@factory.point(avg_lon, avg_lat))
			else
				if segment != nil
					segments.push(segment)
				end
				segment = nil
			end

			if point1 == track1.points.last
				segments.push(segment)
			end
		end
		
		journey1_points = Array.new

		track1.points.each do |point_hash|
			journey1_points.push(point_hash[:point])
		end

		journey2_points = Array.new

		track2.points.each do |point_hash|
			journey2_points.push(point_hash[:point])
		end
		
		segment_timings = Array.new

		[track1, track2].each do |track|

			track_segment_timings = Array.new

			segments.each_with_index do |segment, index|
				if segment.length

					closest_to_start = 0
					closest_to_end = 0
					start_time = nil
					end_time = nil

				
					track.points.each do |point_hash|
						if closest_to_start == 0 or (closest_to_start != 0 and point_hash[:point].distance(segment.points.first) < closest_to_start)
							closest_to_start = point_hash[:point].distance(segment.points.first)
							start_time = point_hash[:datetime]
						end

						if closest_to_end == 0 or (closest_to_end != 0 and point_hash[:point].distance(segment.points.last) < closest_to_end)
							closest_to_end = point_hash[:point].distance(segment.points.last)
							end_time = point_hash[:datetime]
						end
					end

					track_segment_timings.push({:segment => index, :start_time => start_time, :end_time => end_time})
					end

				end

				segment_timings.push(track_segment_timings)
				
		end

		journey1 = Journey.new(journey1_points, track1.points.first[:datetime], track1.points.last[:datetime], segments, segment_timings[0])

		journey2 = Journey.new(journey2_points, track2.points.first[:datetime], track2.points.last[:datetime], segments, segment_timings[1])


		{:journey1 => journey1, :journey2 => journey2, :segments => segments}
	end
end