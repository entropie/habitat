const webpack = require('webpack');

const path = require('path');

const StatsPlugin = require("stats-webpack-plugin");

const ManifestPlugin = require('webpack-manifest-plugin');


var devServerPort = process.env.WEBPACK_DEV_SERVER_PORT,
    devServerHost = process.env.WEBPACK_DEV_SERVER_HOST,
    publicPath = process.env.WEBPACK_PUBLIC_PATH;

const env = process.env.NODE_ENV

module.exports = {
    mode: env || 'development',
    
    entry: {
        bundle: [
            './src/index.js',
        ]
    },

    output: {
        path: path.resolve(__dirname, 'public'),
        filename: '[name].js',
    },

    plugins: [
        new StatsPlugin("webpack_manifest.json"),
    ],

    resolve: {
        modules: [
            "node_modules",
            path.resolve(__dirname, "app")
        ],
    },

    module: {
    }
};


if (process.env.INBUILT_WEBPACK_DEV_SERVER) {

    var merge = require("webpack-merge");

    var dev_server_config = {
        devServer: {
            port: devServerPort,
            headers: {
                "Access-Control-Allow-Origin": "*",
            }
        }
    };

    var dev_server_output = {
        output: {
            publicPath: "//" + devServerHost + ":" + devServerPort + "/"
        }

    };
    module.exports = merge(module.exports, dev_server_config, dev_server_output);
}

console.log(module.exports);
