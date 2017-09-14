#declare ViewZ = -1;

#macro Scene ()

#local SZ = 0;

union {
  #for (BookNo,0,BookCount-1)
    union {
      Book(Books[BookNo])
      #local SZ = SZ + BZ + CoverThickness;
      translate < 0, 0, -SZ >
    }
  #end
}

camera {
	location < -(BX+SZ)*2, BY*2, -BY*4 >
	angle 35
	look_at < BX/2, BY/2, -SZ/3 >
}

#end
