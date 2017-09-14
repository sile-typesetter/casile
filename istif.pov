#declare ViewZ = -1;

#macro Scene ()

camera {
	location < -BX*2.5, BY*3, -BY*3.5 >
	look_at < -BX/4, BY/2, 0 >
	right x/OutputAspect
	angle 35
}

union {
	#declare i = 0;
	#while(i < 10)
		union {
			Book(DefaultBook)
			translate < BZ, 0, -BZ >
			rotate < 0, -95, 0 >
			translate < BZ*i, 0, 0 >
		}
		#declare i = i + 1;
	#end
}

union {
	#declare i = 0;
	#while(i < 5)
		union {
			Book(DefaultBook)
			translate < 0, -BY, -BZ*2 >
			rotate < 15, 0, 0 >
			translate < -BZ/3*i, BY-BZ, -BZ*i >
			// translate <0+i*.02,0,-i*bookthickness>
		}
		#declare i = i + 1;
	#end
	translate < BZ, 0, 0 >
	rotate < 0, 20, 0 >
}

union {
	#declare i = 0;
	#while(i < 6)
		union {
			#if(i < 5)
				Book(DefaultBook)
			#else
				BookFlip(DefaultBook)
			#end
			rotate < 90, 0, 0 >
			translate < -BX, BZ, 0 >
			rotate < 0, 8*i, 0 >
			translate < -BX*i/10, BZ*i, 0 >
		}
		#declare i = i + 1;
	#end
	rotate < 0, -25, 0 >
	translate < -BX/6, 0, -BX/8 >
}

// union {
//     #declare i = 0;
//     #while(i <= 12)
//         union {
//             Book(DefaultBook)
//             rotate <3,0,0>
//             translate <0+i*-0.04,0,i*BZ>
//         }
//         #declare i = i + 1;
//     #end
// }

// union {
//     #declare i = 0;
//     #while(i <= 8)
//         union {
//             BookFlip(DefaultBook)
//             rotate <3,0,0>
//             translate <0+i*-0.02,0,i*BZ>
//         }
//         #declare i = i + 1;
//     #end
//     rotate <0,40,0>
//     translate <BX,0,BZ*-4>
// }

// union {
//     #declare i = 0;
//     #while(i <= 6)
//         union {
//             Book(DefaultBook)
//             rotate <-90,130,00>
//             rotate <0,20+i*8,0>
//             translate <0-i*0.05,i*BZ,-i*BZ>
//         }
//         #declare i = i + 1;
//     #end
//     rotate <0,30,0>
//     translate <BX*2.2,0,-0.9>
//     rotate <0,40,0>
// }

// union {
//     #declare i = 0;
//     #while(i <= 4)
//         union {
//             BookFlip(DefaultBook)
//             rotate <-90,100,00>
//             rotate <0,20+i*12,0>
//             translate <0+i*0.01,i*BZ,-i*BX*0.18>
//         }
//         #declare i = i + 1;
//     #end
//     rotate <0,20,0>
//     translate <BX*0.5,0,-BX>
// }

#end
