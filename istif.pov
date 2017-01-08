#declare viewz = -1;

#macro scene ()

camera {
	location < -bx*2.5, by*3, -by*3.5 >
	look_at < 0, 0, 0 >
	right x*outputaspect
}

// book()

union {
	#declare i = 0;
	#while(i < 10)
		union {
			book()
			translate < bz, 0, -bz >
			rotate < 0, -95, 0 >
			translate < bz*i, 0, 0 >
		}
		#declare i = i + 1;
	#end
}

union {
	#declare i = 0;
	#while(i < 5)
		union {
			book()
			translate < 0, -by, -bz*2 >
			rotate < 15, 0, 0 >
			translate < -bz/3*i, by-bz, -bz*i >
			// translate <0+i*.02,0,-i*bookthickness>
		}
		#declare i = i + 1;
	#end
	translate < bz, 0, 0 >
	rotate < 0, 20, 0 >
}

union {
	#declare i = 0;
	#while(i < 6)
		union {
			#if(i < 5)
				book()
			#else
				bookflip()
			#end
			rotate < 90, 0, 0 >
			translate < -bx, bz, 0 >
			rotate < 0, 8*i, 0 >
			translate < -bz*i/2, bz*i, 0 >
		}
		#declare i = i + 1;
	#end
	rotate < 0, -30, 0 >
	translate < -bx/4, 0, -bx/3 >
}

// union {
//     #declare i = 0;
//     #while(i <= 12)
//         union {
//             book()
//             rotate <3,0,0>
//             translate <0+i*-0.04,0,i*bz>
//         }
//         #declare i = i + 1;
//     #end
// }

// union {
//     #declare i = 0;
//     #while(i <= 8)
//         union {
//             bookflip()
//             rotate <3,0,0>
//             translate <0+i*-0.02,0,i*bz>
//         }
//         #declare i = i + 1;
//     #end
//     rotate <0,40,0>
//     translate <bx,0,bz*-4>
// }

// union {
//     #declare i = 0;
//     #while(i <= 6)
//         union {
//             book()
//             rotate <-90,130,00>
//             rotate <0,20+i*8,0>
//             translate <0-i*0.05,i*bz,-i*bz>
//         }
//         #declare i = i + 1;
//     #end
//     rotate <0,30,0>
//     translate <bx*2.2,0,-0.9>
//     rotate <0,40,0>
// }

// union {
//     #declare i = 0;
//     #while(i <= 4)
//         union {
//             bookflip()
//             rotate <-90,100,00>
//             rotate <0,20+i*12,0>
//             translate <0+i*0.01,i*bz,-i*bx*0.18>
//         }
//         #declare i = i + 1;
//     #end
//     rotate <0,20,0>
//     translate <bx*0.5,0,-bx>
// }

#end
