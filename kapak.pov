#declare outputaspect = outputwidth / outputheight;
#declare coveraspectratio = coverwidth / coverheight;
#declare bookthickness = (spinewidth/coverwidth)/2;
#declare coverthickness = 0.005;
#declare paperinset = 0.005;
#declare halfthick = coverthickness / 2;

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
	diffuse 0.9
	reflection {0.25}
	specular 0.75
	roughness 0.05
}

background { color rgb<1,1,1> }

camera {
	location <-0.25,1.15,-0.75>
	look_at  <0.25,0.60,halfthick>
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
		scale <0.5,1,1>
		translate <0,0,(bookthickness/2)>
		finish { bookfinish }
	}
	box { <0,-0.001,0> <1,1.001,bookthickness>
		pigment { color rgb <1,1,1> }
		scale <coveraspectratio,1,1>
		translate <0,0,0>
	}
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
