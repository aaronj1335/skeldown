#!/usr/bin/env node

var path = require('path'),
    coffeescript = require('coffee-script'),
    srcPath = path.join(__dirname, '../skeldown'),
    skeldown = require(srcPath);

skeldown.run();
