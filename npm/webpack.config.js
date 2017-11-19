'use strict';

var path = require('path'),
	root = __dirname,
	node_modules = path.resolve(__dirname, 'node_modules');

module.exports = {
    entry: {
//		filetree: root + '/containers/filetree.jsx',
		nodetree: root + '/containers/nodetree.jsx',
//		topmenu: root + '/containers/topmenu.jsx',
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
                   presets: ['env', 'react', "stage-0"]
               }
            }
        ]
    }
};
