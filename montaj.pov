#declare ViewZ = -1;

#macro Scene ()

#local SZ = 0;

union {
  #for (BookNo,0,BookCount-1)
    union {
      Book(Books[BookNo])
      translate < 0.5, 0, SZ >
      #local SZ = SZ + BZ;
      // rotate < 5*BookNo, 0, 0 >
    }
  #end
}

#end
