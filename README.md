Hi. My name is Lene Preuss, you can reach me at lene.preuss@gmx.net and find some code of mine at 
[GitHub](https://github.com/lene).

This program solves the trains assignment in Python3.


##Usage

`$ python3 main.py -f|--file <graph definition file>`

e.g.

`$ python3 main.py -f graph.txt`

to solve for the example data supplied with the problem. The program will print the questions asked
in the assignment along with their answers (for the graph you pass it, of course).
 
###Data format
The graph is given as a list of edges which is separated by whitespace (and optionally commas).
Each edge is a string of at least three characters of the form `<first vertex><second vertex><length>`,
where `first vertex` and `second vertex` are a single character, and `length` must be parsable as a
number by Python. 

Basically this is the format you used in the assignment, except that I made commas optional.

Example:

`AB1 AC2 BC2`


##Assumptions and limitations

I assume that the input is reasonably well behaved. You can easily find input that breaks the program, if
you are so inclined. Don't do that. ;-)

Since vertices are defined by a single character, the number of vertices is somewhat limited by the charset
you use. (Giving the vertices Unicode names works, but do you really want to use thousands of single  
unicode characters to represent your graph?). Due to the small size of the graphs, I did not give performance 
optimization more than cursory thoughts.

I am developing on a Linux system. I don't see why my code should break on another OS, but I have not tested
that.


##Design and development process

###Motivation
I chose this problem because I wanted to implement Dijkstra's shortest path algorithm. Due to the supposedly
small problem size I believe I could easily have gotten away with a more naive algorithm.

While Dijkstra's algorithm sounds simple and elegant in theory, it is less so in practice due to the bookkeeping 
needed and the fact that Python's implementation of a priority queue does not allow changing the priority of an
item easily. I hope my implementation is still readable enough to figure out what's going on.

Other than that, I think it is super useful to have some implementation of graph algorithms in my personal 
code library.

###Design considerations
I chose Python because it is the language I currently work with and I am most familiar with it at the moment, 
but also because I like it as a language that is very good for rapidly writing concise code, especially for
small applications such as this.

I basically have only two classes: `Edge` and `DirectedGraph`. I could easily have added more classes (a better 
implementation of a priority queue come to mind, as well as a class that solves Dijkstra's algorithm instead 
of a global function). In the Python community using classes for every data structure is somewhat discouraged
though (if native types are sufficient), so I stuck with that.

The decision to implement some of the assignment's solutions as methods on DirectedGraph and others as global
functions was somewhat arbitrary. How much I consider something a core property of a graph played a role, aversion
to long source files and long argument lists another.

As per Python conventions, I do not define getters and setters but access properties directly, if needed.


###Testing
`$ python3 run_tests.py`

The tests resemble my development process. As a result, there are many tests that may seem redundant.
 
I prioritize the DRY principle over the "Tests should test one thing and one thing only"-principle.

Again, I assume reasonably well behaved input and don't test many pathological or border cases.


##Thanks
I had fun with this assignments. I hope you like my submission!

Lene