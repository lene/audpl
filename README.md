Hi. My name is Lene Preuss, you can reach me at lene.preuss@gmx.net and find some code of mine at 
[GitHub](https://github.com/lene).

This program solves the trains assignment in Python3.


##Usage
`
$ python3 main.py -f|--file <graph definition file>
`
e.g.
`
$ python3 main.py -f graph.txt
`
to solve for the example data supplied with the problem.
 
 
###Data format
The graph is given as a list of edges which is separated by whitespace (and optionally commas).
Each edge is a string of at least three characters of the form `<first vertex><second vertex><length>`,
where `first vertex` and `second vertex` are a single character, and `length` must be parsable as a
number by Python. 

Basically this is the format you used in the assignment, except that I made commas optional.


##Assumptions and limitations
I assume that the input is reasonably well behaved. You can easily find input that breaks the program, if
you are so inclined. Don't do that. :-)

Since vertices are defined by a single character, the number of vertices is somewhat limited by the charset
you use. (Giving the vertices Unicode names works, but do you really want to go there?). Due to the small 
size of the graphs, I did not give performance optimization more than cursory thoughts.

##Design



