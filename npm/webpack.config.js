'use strict';

var path = require('path'),
	root = __dirname,
	node_modules = path.resolve(__dirname, 'node_modules');

module.exports = {
    entry: {
//		topmenu: root + '/containers/topmenu.jsx',
		filetree: root + '/containers/filetree.jsx',
	},
    output: {
        filename: "../public/js/built/djet.js",
        chunkFilename: '[id].chunk.js'
    },
    module: {
        loaders: [
            {
                test: /.jsx?$/,
                loader: 'babel-loader',
                exclude: /node_modules/,
                query: {
                    presets: ['es2015', 'react']
                }
            }
        ]
    }
};
