skeldown(1) -- convert markdown to html with skeleton.css
=========================================================

## SYNOPSIS

  `skeldown` &lt; _file_

  `skeldown` _file_

## DESCRIPTION

given a markdown file (first command line argument or stdin), skeldown will
convert it to HTML and insert it into a full HTML document.  it will add
[`skeleton.css`][skeletoncss] and [a syntax highlighter][highlight].  skeldown
also provides hooks to add more css and run transformations on the resulting
markup via jquery.

## ADDITIONAL CSS

css may be added with the `--extracss` option. simply specify any desired
files:

    $ skeldown --extracss foo.css,bar.css < README.md > docs.html

## ADDITIONAL PROCESSING STEPS

extra js files to process the resulting html.  this is really useful if you
want to do dynamic things like generate unique, linkable id's for each bullet
point, or maybe add a table of contents.  the cool thing is that you just need
to provide a functioni that takes a `$head` and `$body` parameter and performs
any changes. jquery is used to make DOM manipulation easy. say you want to add
a word count at the end of your body.  you would run `skeldown` with the
following command:

    $ skeldown -j wordcount.js < README.md > docs.html

and the contents of `wordcount.js` would look something like this:

    exports.pipeline = function($head, $body) {
        var count = $body.text().match(/S+/g).length;
        $('<span class=wordcount>')
            .text('Word count: ' + count)
            .appendTo($body);
    }

and that would add the following (dynamically generated) HTML to the resulting
document:

    <span class=wordcount>Word count: 1042</span>

## OPTIONS

   * `-o`, `--out`:
     output file.  defaults to stdout.          

   * `-e`, `--extracss`:
     css files to insert. see [ADDITIONAL CSS][]

   * `-j`, `--jspipeline`:
     see [ADDITIONAL PROCESSING STEPS][]        

   * `-n`, `--noprettify`:
     DON'T use code prettifier                  

   * `-t`, `--prettifytheme`:
     [prettify theme][themes]                     [default: "ascetic"]

   * `-h`, `--help`:
     display this help message                  
 
[skeletoncss]: http://getskeleton.com         "beutiful responsive boilerplate"
[highlight]: http://github.com/andris9/highlight.git             "highlight.js"
[themes]: http://softwaremaniacs.org/media/soft/highlight/test.html    "themes"
