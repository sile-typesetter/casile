#declare outputaspect = outputwidth / outputheight;
#declare coveraspectratio = coverwidth / coverheight;
#declare bookthickness = (spinewidth/coverwidth)/2;
#declare coverthickness = 0.0*5;
#declare paperinset = 0.001;
#declare halfthick = bookthickness / 2;

#declare paperpigment = pigment {
	gradient <0,1,0>
	color_map {
		[0.0 color rgb<0.9,0.9,0.9>]
		[0.5 color rgb<0.9,0.9,0.9>]
		[0.5 color rgb<1,1,1>]
		[1.0 color rgb<1,1,1>]
	}
	scale <0.002,0.002,0.002>
	rotate <90,0,0>
}

#declare bookfinish = finish {
	diffuse 0.5
	reflection { 0.15 }
	specular 0.75
	roughness 0.05
}

background { color rgb<1,1,1> }

camera {
	location <-1,1.50,-1>
	look_at  <.4*coveraspectratio,0.60,halfthick>
	right x*outputaspect
}

light_source { <2,3,-1>	color rgb<1,1,1> }

light_source { <-2,1,-2> color rgb<1,1,1> }

// front cover
box { <0,0,0> <1,1,coverthickness>
	pigment {
		image_map {
			png frontimg
			map_type 0
			interpolate 2
		}
	}
	scale <coveraspectratio,1,1>
	finish { bookfinish }
}

// back cover
box {
	<0,0,0> <1,1,coverthickness>
	pigment {
		image_map {
			png backimg
			map_type 0
			interpolate 2
		}
		rotate <0,180,0>
	}
	scale <coveraspectratio,1,1>
	finish { bookfinish }
	translate <0,0,bookthickness-coverthickness>
}

// spine
difference {
	cylinder { <0,0,0>,<0,1,0>,(bookthickness/2)
		pigment {
			image_map {
				png spineimg
				map_type 2
				interpolate 2
			}
		}
		scale <0.1,1,1>
		translate <0,0,(bookthickness/2)>
		finish { bookfinish }
	}
	box { <0,0,0> <1,1,1> }
}

// dimensions of pages
#declare paper = object {
	box {
		<0,0,0> <1,1,bookthickness-(coverthickness*2)>
		scale <coveraspectratio,1,1>
		translate <0,0,coverthickness>
	}
}

// pages box with inset
box { min_extent(paper) max_extent(paper)-((paperinset*2)*y)-(paperinset*x)
	translate <0,paperinset,0>
	pigment {paperpigment}
	finish {ambient 0.5}
}
