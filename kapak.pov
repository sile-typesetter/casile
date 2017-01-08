#declare outputaspect = coverwmm / coverhmm;
#declare bookaspect = coverwmm / coverhmm;
#declare bookthickness = spinemm / coverwmm / 2;
#declare coverthickness = 0.004;
#declare paperinset = 0.0001;
#declare halfthick = bookthickness / 2;
#declare bx = 1 * bookaspect;
#declare by = 1;
#declare bz = bookthickness;

#declare paperpigment = pigment {
	gradient <0,1,0>
	color_map {
		[0.0 color rgb<0.59,0.57,0.55>]
		[0.5 color rgb<0.59,0.57,0.55>]
		[0.5 color rgb<0.79,0.76,0.73>]
		[0.5 color rgb<0.79,0.76,0.73>]
	}
	scale <0.003,0.003,0.003>
	rotate <90,0,0>
}

#declare bookfinish = finish {
	ambient 0.85
	diffuse 0.4
	reflection 0.10
	specular 0.35
	roughness 0.05
}

background { color rgb<1,1,1> }

camera {
	location <-1,1.50,1.2*viewz>
	look_at <.4*bookaspect,0.60,halfthick>
	right x*outputaspect
}

plane
{
	y, 0
	pigment {
		color rgb<0.9,0.9,0.9>
	}
	finish {
		reflection 0.05
		emission rgb<0.2,0.2,0.2>
	}
}

light_source {
	<-0.2,8,3.0*viewz>
	color rgb<1,1,1>
	area_light <0.4, 0, 0>, <0, 0, 0.4>, lights, lights
	circular
}

light_source {
	<-3,0,-halfthick>
	color rgb<0.5,0.5,0.5>
}

#macro book ()

// front cover
box { <0,0,0> <1,1,coverthickness>
	pigment {
		image_map {
			png frontimg
			map_type 0
			interpolate 2
		}
	}
	scale <bookaspect,1,1>
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
	scale <bookaspect,1,1>
	finish { bookfinish }
	translate <0,0,bz-coverthickness>
}

// spine
difference {
	cylinder { <0,0,0>,<0,1,0>,(bz/2)
		pigment {
			image_map {
				png spineimg
				map_type 2
				interpolate 2
			}
		}
		scale <0.1,1,1>
		translate <0,0,(bz/2)>
		finish { bookfinish }
	}
	box {
		<0,-0.001,0> <1,1.001,bz>
	}
}

// dimensions of pages
#declare paper = object {
	box {
		<0,0,0> <1,1,bz-(coverthickness*2)>
		scale <bookaspect,1,1>
		translate <0,0,coverthickness>
	}
}

// pages box with inset
box { min_extent(paper) max_extent(paper)-((paperinset*2)*y)-(paperinset*x)
	translate <0,paperinset,0>
	pigment {paperpigment}
	finish {ambient 0.5}
}

#end

#macro bookflip ()

union {
	book()
	rotate <0,180,0>
	translate <bx,0,bz>
}

#end

scene()
