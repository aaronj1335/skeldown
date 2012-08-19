#!/usr/bin/env node

var path = require('path'),
    coffeescript = require('coffee-script'),
    srcPath = path.join(__dirname, 'lib/skeldown.coffee'),
    skeldown = require(srcPath);

skeldown.run();
