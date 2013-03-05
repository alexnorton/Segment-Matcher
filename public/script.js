var poly;
var track1;
var track2;
var map;

var tracks = [];

var bounds;
var segmentsBounds;

$(document).ready(function() {

	getTracks({success: function(tracks) {
			for(i in tracks) {
				$("#track-list1").append("<option" + (track1 == tracks[i] ? " selected" : "") + ">" + tracks[i].split(".gpx")[0] + "</option>");
				$("#track-list2").append("<option" + (track2 == tracks[i] ? " selected" : "") + ">" + tracks[i].split(".gpx")[0] + "</option>");
			}}
		});

    $(".track-lists").change(function() {
    	track1 = $("#track-list1 option:selected").text() + ".gpx";
    	track2 = $("#track-list2 option:selected").text() + ".gpx";

    	matchTracks(track1, track2);
    });

    $("#segments-table td").click(function() {
    	console.log("clicked");
    });

    $("#zoom-out-button").click(function() {
    	map.fitBounds(bounds);
    	$(this).hide();
    });

});

function getTracks(options) {
	$.ajax({
		type: "GET",
		url: "tracks.json",
		dataType: "json",
		success: function(json) {
			var tracks = [];

			for(i in json.tracks) {
				tracks.push(json.tracks[i].filename)
			}


			track1 = tracks[0];
			track2 = tracks[3];

			matchTracks(track1, track2);

			options.success(tracks);

		}
	});
}

function matchTracks(track1, track2) {

	map = new google.maps.Map(document.getElementById("map_canvas") ,
    	{ mapTypeId: google.maps.MapTypeId.ROADMAP });

	$.ajax({
		type: "GET",
		url: "match.json?track1=" + track1 + "&track2=" + track2,
		dataType: "json",
		success: function(json) {

			// Populate journey table data

			var journey1start = new Date(json.journeys[0].starttime);
			var journey1end = new Date(json.journeys[0].endtime);
			var journey2start = new Date(json.journeys[1].starttime);
			var journey2end = new Date(json.journeys[1].endtime);

			$("#journey-table tr:eq(2) > td:eq(1)").html(metresToKm(json.journeys[0].length) + " km");
			$("#journey-table tr:eq(2) > td:eq(2)").html(metresToKm(json.journeys[1].length) + " km");

			$("#journey-table tr:eq(1) > td:eq(1)").html(new Date(json.journeys[0].starttime).getDate() + "/" + (new Date(json.journeys[0].starttime).getMonth() + 1) + "/" + new Date(json.journeys[0].starttime).getFullYear());
			$("#journey-table tr:eq(1) > td:eq(2)").html(new Date(json.journeys[1].starttime).getDate() + "/" + (new Date(json.journeys[1].starttime).getMonth() + 1) + "/" + new Date(json.journeys[1].starttime).getFullYear());

			$("#journey-table tr:eq(3) > td:eq(1)").html(Math.floor((journey1end - journey1start)/60000) + ":" + ((journey1end - journey1start)/1000) % 60);
			$("#journey-table tr:eq(3) > td:eq(2)").html(Math.floor((journey2end - journey2start)/60000) + ":" + ((journey2end - journey2start)/1000) % 60);

			//console.log(json.jou);

			bounds = new google.maps.LatLngBounds();

			var pointset1 = [];
			var pointset2 = [];


			for(i in json.journeys[0].geojson.coordinates) {
				var p = new google.maps.LatLng(json.journeys[0].geojson.coordinates[i][1], json.journeys[0].geojson.coordinates[i][0]);
				pointset1.push(p);
				bounds.extend(p);
			}

			poly1 = new google.maps.Polyline({
			  // use your own style here
			  path: pointset1,
			  strokeColor: "#0044cc",
			  strokeOpacity: 1,
			  strokeWeight: 4
			});

			poly1.setMap(map);

			for(i in json.journeys[1].geojson.coordinates) {
				var p = new google.maps.LatLng(json.journeys[1].geojson.coordinates[i][1], json.journeys[1].geojson.coordinates[i][0]);
				pointset2.push(p);
				bounds.extend(p);
			}

			poly2 = new google.maps.Polyline({
			  // use your own style here
			  path: pointset2,
			  strokeColor: "#bd362f",
			  strokeOpacity: 1,
			  strokeWeight: 4
			});

			poly2.setMap(map);


			$("#segments-table tbody").html("");

			segmentsBounds = [];

			for(i in json.segments) {
				var journey1time = (new Date(json.journeys[0].timings[i].end_time) - new Date(json.journeys[0].timings[i].start_time)) / 1000;
				var journey2time = (new Date(json.journeys[1].timings[i].end_time) - new Date(json.journeys[1].timings[i].start_time)) / 1000;

				$("#segments-table tbody").append(
					"<tr>" +
						"<td>" + (Number(i) + 1) + "</td>" +
						"<td>" + metresToKm(json.segments[i].length) + " km</td>" +
						"<td>" + Math.floor(journey1time/60) + ":" + zeroFill(journey1time % 60, 2) + "</td>" +
						"<td>" + Math.floor(journey2time/60) + ":" + zeroFill(journey2time % 60, 2) + "</td>" +
					"</tr>");

				var segmentBounds = new google.maps.LatLngBounds();
				var pointset = [];
				for(j in json.segments[i].geojson.coordinates) {
					var p = new google.maps.LatLng(json.segments[i].geojson.coordinates[j][1], json.segments[i].geojson.coordinates[j][0]);
					pointset.push(p);
					segmentBounds.extend(p);
				}
				var polyline = new google.maps.Polyline({
					path: pointset,
					strokeColor: "#5eb95e",
					strokeOpacity: 1,
					strokeWeight: 4
				});
				polyline.setMap(map);

				segmentsBounds.push(segmentBounds);

			}

			$("#segments-table td").click(function() { 
				map.fitBounds(segmentsBounds[$($(this).parent().children()[0]).html() - 1]);

				$("#zoom-out-button").show();
			});

			//$("#loading").hide();

			map.fitBounds(bounds);

		}
	});

	function metresToKm(metres) {
		return Math.round(metres / 100) / 10;
	}

	function zeroFill( number, width )
	{
		width -= number.toString().length;
		if ( width > 0 )
		{
		return new Array( width + (/\./.test( number ) ? 2 : 1) ).join( '0' ) + number;
		}
		return number + ""; // always return a string
	}
}
