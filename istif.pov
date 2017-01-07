#declare viewz = -1;

#macro scene ()

union {
	#declare i = 0;
	#while(i <= 12)
		union {
			book()
			translate <0+i*0.00,0,i*bookthickness>
		}
		#declare i = i + 1;
	#end
}

// union {
//     #declare i = 0;
//     #while(i <= 3)
//         union {
//             book()
//             rotate <15,0,0>
//             translate <0,0,-0.3>
//             translate <0+i*.02,0,-i*bookthickness>
//         }
//         #declare i = i + 1;
//     #end
//     translate <-0.2,0,-0.05>
//     rotate <0,30,0>
// }

// union {
//     #declare i = 0;
//     #while(i <= 6)
//         union {
//             book()
//             rotate <-90,170,00>
//             rotate <0,20+i*6,0>
//             translate <0-i*0.03,i*bookthickness,0>
//         }
//         #declare i = i + 1;
//     #end
//     translate <-0.1,0,0.15>
// }

#end
