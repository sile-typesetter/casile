#declare ViewZ = -1;

#macro Scene ()

#local SZ = 0;

union {
  #for (BookNo,1,BookCount)
    #local SeriesNo = BookCount - BookNo;
    union {
      Book(Books[SeriesNo])
      #local SZ = SZ + BZ + CoverThickness;
      translate < 0, 0, -SZ >
    }
  #end
}

camera {
	location < -(BX+SZ)*2.1, BY*2, -BY*2.5 >
	angle 35
	look_at < BX/2, BY/2, -SZ/3 >
}

#end
