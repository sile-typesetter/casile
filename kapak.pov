#declare outputaspect = outputwidth / outputheight;
#declare coveraspectratio = coverwidth / coverheight;
#declare bookthickness = (spinewidth/coverwidth)/2;
#declare coverthickness = 0.004;
#declare paperinset = 0.0001;
#declare halfthick = bookthickness / 2;

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
	location <-2.3,3.00,1.8*viewz>
	look_at  <-0.2,0.6,0>
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
	<-0.2,4,1.0*viewz>
	color rgb<1,1,1>
	area_light <0.4, 0, 0>, <0, 0, 0.4>, lights, lights
	circular
}

light_source {
	<-3,0,-halfthick>
	color rgb<1,1,1>
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
	box {
		<0,-0.001,0> <1,1.001,bookthickness>
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

#end

union {
	#declare i = 0;
	#while(i <= 6)
		union {
			book()
			translate <0+i*0.02,0,i*bookthickness>
		}
		#declare i = i + 1;
	#end
}
union {
	#declare i = 0;
	#while(i <= 3)
		union {
			book()
			rotate <15,0,0>
			translate <0,0,-0.3>
			translate <0+i*.02,0,-i*bookthickness>
		}
		#declare i = i + 1;
	#end
	translate <-0.2,0,-0.05>
	rotate <0,30,0>
}
union {
	#declare i = 0;
	#while(i <= 6)
		union {
			book()
			rotate <-90,170,00>
			rotate <0,20+i*6,0>
			translate <0-i*0.03,i*bookthickness,0>
		}
		#declare i = i + 1;
	#end
	translate <-0.1,0,0.15>
}
