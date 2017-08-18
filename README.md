## CourseGraph

CourseGraph is a website that displays Georgia Tech's courses as an interwoven tree. It is designed to help current and prospective students visualize what classes they will need in order to take upper-level classes that interest them.

Inspired by my passion for graph theory and desire to learn basic Javascript, CSS, and HTML, I hope the Georgia Tech community will find this website useful.

I used the [visjs](visjs.org) library to display the graphs and the [Grouch](https://github.com/gttools/Grouch) API to get course data from OSCAR. Bootstrap was used to help design the website and the [jsonlab](https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files) MATLAB suite to parse the results from Grouch.

Most of the Javascript can be found in /resources/js, the CSS in /resources/css, and the raw JSON data in /resources/json.

MATLAB scripts that I wrote to generate the nodes and edges can be found in /resources/json/jsonlab-1.1, although they aren't working for me in Octave.
