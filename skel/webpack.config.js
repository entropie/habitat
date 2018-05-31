const webpack = require('webpack');

const path = require('path');

const ExtractTextPlugin = require('extract-text-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");

var devServerPort = process.env.WEBPACK_DEV_SERVER_PORT,
    devServerHost = process.env.WEBPACK_DEV_SERVER_HOST,
    publicPath = process.env.WEBPACK_PUBLIC_PATH;

const env = process.env.NODE_ENV

module.exports = {
    mode: env || 'development',
    
    entry: {
        app: './apps/blog/assets/javascripts/app.js',
    },

    output: {
        path: path.resolve(__dirname + '/media/assets'),
        filename: 'bundle.js',
        publicPath: './public'
    },

    resolve: {
        alias: {
        //'vue$': 'vue/dist/vue.esm.js'
        }
    },

    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                loader: 'babel-loader'
            },
            {
                test: /\.sass$/,
                use: [
                    // fallback to style-loader in development
                    process.env.NODE_ENV !== 'production' ? 'style-loader' : MiniCssExtractPlugin.loader,
                    "css-loader",
                    "sass-loader"
                ]
            }            

        ]
    }
    , plugins: [
        new MiniCssExtractPlugin({
            filename: "screen.css",
        })
    ]
};   
