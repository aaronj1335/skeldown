# `skeldown(1)`

[skeleton css](www.getskeleton.com/) + markdown = `skeldown`

skeldown is a utility to make html docs from markdown w/ skeleton css embedded.
it provides hooks to:

 - add syntax highlighting via
   [highligh.js](http://softwaremaniacs.org/soft/highlight/en/)
   
 - add your own css

 - perform transforms on the generated html document in jQuery

so say you want to make a github project page from your `README.md`.
`skeldown(1)` will render the html w/ the skeleton css inlined, add syntax
highlighting, and give you hooks to, say, add 'id' attributes to each bullet
point for easy linking, or maybe generate a table of contents.

it can be executed on the command line or programatically.
