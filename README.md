# Playing with SwiftData

This is play code, probably wrong in many ways.

Playing with Swift Data, iCloud, and discovering the many ways to break an
app at run time by doing things that compile, but won't work.

So far I've found two ways to cause a program hang and one way to
make the search bar disappear.

## Update

I've turned this into something I use. My build does two things that make
it different from what might be considered a "normal" SwiftUI program.

1. I use my simplified UDF data flow as the source of truth. See the UDF
   package README for more info.

2. I separate Swift Data from SwiftUI. All Swift Data functions are triggered
    by UDF state changes which call functions contained in BookDB.swift. At
    no time will UI code directly modify a database item.
