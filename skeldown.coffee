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
  _.each pipeline, (fn) -> fn($head, $body)
  # _.compose.apply(_, pipeline)($head = $(head), $body = $(body))
  templates.index head: markup($head), body: markup($body)

skeletonCss = exports.skeletonCss = (() ->
  filenames = for f in ["base", "layout", "skeleton"]
    join dirname(require.resolve("skeleton-css")), "stylesheets", f + ".css"
  (read filename for filename in filenames).join "\n")()

templates = exports.templates =
  index: _.template read(join(thisDir, "templates/index.mtpl"))
  head: _.template read(join(thisDir, "templates/head.mtpl"))
  body: _.template read(join(thisDir, "templates/body.mtpl"))

pipeline = exports.pipeline = [
  ($head, $body) ->
    $('<style>')
      .text(argv.extracss.map((filename) -> read(filename)).join("\n"))
      .appendTo($head)
]

prettify = ($head, $body) ->
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
    
    .option "out",
      alias: "o"
      description: "output file.  defaults to stdout."

    .option "extracss",
      alias: "e"
      description: "css files to insert.  comma separated if multiple"

    .option "noprettify",
      alias: "n"
      description: "DON'T use code prettifier"

    .option "prettifytheme",
      alias: "t"
      "default": "ascetic"
      description: "prettify theme: http://softwaremaniacs.org/media/soft/highlight/test.html"

    .argv

  argv.extracss = argv.extracss?.split(",") or []

  pipeline.unshift prettify if not argv.noprettify

  text = read if argv._.length then argv._[0] else "/dev/stdin"

  if argv.out
    fs.writeSync fs.openSync(argv.out, "w"), skeldown(text)
  else
    process.stdout.write skeldown(text)
