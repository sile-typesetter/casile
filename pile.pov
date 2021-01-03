#declare ViewZ = -1;

#macro Scene ()

#declare Count = BX / BookThickness;

camera {
	location < -(BX+BY)*1.25, (BX+BY)*1.75, -(BX+BY)*2.5 >
	up y
	right x*8/6
	angle 35
	look_at < 0, BY/2, 0 >
}

// Uprights in the background
union {
	#declare i = 0;
	#while(i < Count*1.5)
		union {
			Book(DefaultBook)
			translate < BZ, 0, -BZ >
			rotate < 0, -95, 0 >
			translate < BZ*i+(BZ/100*rand(Rand1)), 0, 0 >
			rotate < rand(Rand1)/4, 0, 0 >
		}
		#declare i = i + 1;
	#end
}

// Forward facing leaning stack
union {
	#declare i = 0;
	#while(i < Count/4+1)
		union {
			Book(DefaultBook)
			translate < 0, -1, BookThickness >
			rotate < 15, rand(Rand2)/2, 0 >
			translate < 0, .96+(BookThickness*.52), -BookThickness-.26 >
			// translate < -BZ/3*i, BY-BZ, -BZ*i >
			translate <0+i*.01+(BookThickness/2*rand(Rand2)),0,-BookThickness*i>
		}
		#declare i = i + 1;
	#end
	// translate < 0, 0, .29 >
	translate < min(BX/10,BookThickness*10), 0, 0 >
	rotate < 0, 15, 0 >
}

// Twisted flat stack on the left
union {
	#declare i = 0;
	#while(i < Count/2-1)
		union {
			#if(i+1 >= Count/2-1)
				BookFlip(DefaultBook)
			#else
				Book(DefaultBook)
			#end
			rotate < 90, 0, 0 >
			translate < -BX/2, BZ, -BY/2 >
			rotate < 0, (30/Count)*i+(rand(Rand3)*2), 0 >
			#if(i+1 >= Count/2-1)
			rotate < 0, 10, 0 >
			#end
			translate < -BX/1.5, BZ*i, -BY/2 >
		}
		#declare i = i + 1;
	#end
	rotate < 0, -15, 0 >
	translate < -.29, 0, BY>
}

#end
