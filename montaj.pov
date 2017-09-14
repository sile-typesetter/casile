#declare ViewZ = -1;

#macro Scene ()

#local SZ = 0;

union {
  #for (BookNo,0,BookCount-1)
    union {
      Book(Books[BookNo])
      #local SZ = SZ + BZ;
      translate < 0, 0, -SZ >
      // rotate < 5*BookNo, 0, 0 >
    }
  #end
}

#end
