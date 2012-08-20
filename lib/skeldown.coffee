usage = """
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
        var count = $body.text().match(/\S+/g).length;
        $('<span class=wordcount>')
            .text('Word count: ' + count)
            .appendTo($body);
    }

and that would add the following (dynamically generated) HTML to the resulting
document:

    <span class=wordcount>Word count: 1042</span>
"""

links = """

[skeletoncss]: http://getskeleton.com         "beutiful responsive boilerplate"
[highlight]: http://github.com/andris9/highlight.git             "highlight.js"
[themes]: http://softwaremaniacs.org/media/soft/highlight/test.html    "themes"
"""

fs = require "fs"
{join, basename, resolve, normalize, dirname} = require "path"
marked = require "marked"
optimist = require "optimist"
_ = require "underscore"
$ = require "jQuery"
highlight = require("highlight").Highlight
read = (filename) -> fs.readFileSync filename, "utf8"
thisDir = dirname module.filename
argv = null

# like jQuery.fn.html except it includes the outer tags (and outer tag attrs)
# i would just use .outerHTML, but it adds speces that screw formatting up
markup = ($markup) ->
  attrs = (_.map($markup[0].attributes, (a) ->
    "#{a.name}=\"#{a.nodeValue}\"")).join(" ")
  tag = $markup[0].tagName.toLowerCase()
  "<#{tag} #{attrs}>#{$markup.html()}</#{tag}>"

skeldown = module.exports = (text) ->
  head = templates.head
    skeletonCss: skeletonCss
    description: module.exports.description
    title: module.exports.title
  body = templates.body
    content: marked text
  $head = $(head)
  $body = $(body)
  _.each pipeline, (fn) -> fn($, $head, $body)
  templates.index head: markup($head), body: markup($body)

skeletonCss = exports.skeletonCss = (() ->
  filenames = for f in ["base", "layout", "skeleton"]
    join dirname(require.resolve("skeleton-css")), "stylesheets", f + ".css"
  (read filename for filename in filenames).join "\n")()

templates = exports.templates =
  index: _.template read(join(thisDir, "../templates/index.mtpl"))
  head: _.template read(join(thisDir,  "../templates/head.mtpl"))
  body: _.template read(join(thisDir,  "../templates/body.mtpl"))

pipeline = exports.pipeline = [
  ($, $head, $body) ->
    $('<style>')
      .text(argv.extracss.map((filename) -> read(filename)).join("\n"))
      .appendTo($head)
]

prettify = ($, $head, $body) ->
  dir = join dirname(require.resolve("highlight")), "vendor/highlight.js/styles"
  $('<style>')
    .text(read(join(dir, "#{argv.prettifytheme}.css")))
    .appendTo($head)
  $body.find('pre > code').each (i, el) ->
    $(el).html(highlight($(el).text())).parent().addClass('add-bottom')

module.exports.description = ""

module.exports.title = ""

run = module.exports.run = () ->
  argv = require("optimist")

    .usage(usage)

    .option "out",
      alias: "o"
      description: "output file.  defaults to stdout."

    .option "extracss",
      alias: "e"
      description: "css files to insert. see [ADDITIONAL CSS][]"

    .option "jspipeline",
      alias: "j"
      description: "see [ADDITIONAL PROCESSING STEPS][]"

    .option "noprettify",
      alias: "n"
      description: "DON'T use code prettifier"

    .option "prettifytheme",
      alias: "t"
      "default": "ascetic"
      description: "[prettify theme][themes]"

    .option "help",
      alias: "h"
      description: "display this help message"

    .argv

  argv.extracss = argv.extracss?.split(",") or []

  for script in argv.jspipeline?.split(",") or []
    pipeline.push(require(resolve(script)).pipeline)
    # pipeline.push(require('/Users/astacy/code/skeldown/etc/skeldown/pipeline.js').pipeline)

  pipeline.unshift prettify if not argv.noprettify

  if argv.help
    console.log require("optimist").help()
      .replace(/Options:/g, '## OPTIONS')
      .replace(/\n(\s+)(--\S+), (-\S)\s*/g, '\n\n$1 * `$3`, `$2`:\n     '),
      links
    process.exit 0

  text = read if argv._.length then argv._[0] else "/dev/stdin"

  if argv.out
    fs.writeSync fs.openSync(argv.out, "w"), skeldown(text)
  else
    process.stdout.write skeldown(text)