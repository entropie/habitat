const webpack = require('webpack');

const path = require('path');

const ExtractTextPlugin = require('extract-text-webpack-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const UglifyJsPlugin = require("uglifyjs-webpack-plugin");


var devServerPort = process.env.WEBPACK_DEV_SERVER_PORT,
    devServerHost = process.env.WEBPACK_DEV_SERVER_HOST,
    publicPath = process.env.WEBPACK_PUBLIC_PATH;

const env = process.env.NODE_ENV

const config = {
    mode: env || 'development',
    
    entry: {
        app: [
            './apps/web/assets/javascripts/application.js',
            './vendor/gems/habitat/plugins/galleries/src/gallery.js',
        ],
        be: [
            './vendor/gems/habitat/plugins/galleries/src/gallery.js',
            './vendor/gems/habitat/plugins/backend/src/combined.js'
        ],
    },

    output: {
        path: path.resolve(__dirname + '/media/assets'),
        filename: 'bundle-[name].js',
        publicPath: './public'
    },

    resolve: {
        symlinks: false,
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
            }
            ,
            {
                test: /\.sass|\.css$/,
                use: [
                    // fallback to style-loader in development
                    process.env.NODE_ENV !== 'production' ? 'style-loader' : MiniCssExtractPlugin.loader,
                    "css-loader",
                    "sass-loader"
                ]
            }
            ,
            { test: /\.(png|woff|woff2|eot|ttf|svg)$/, loader: 'url-loader?limit=100000' }


        ]
    }
    , plugins: [
        new MiniCssExtractPlugin({
            filename: "screen.css",
        })
        ,
        new webpack.ProvidePlugin({
            $: "jquery",
            jQuery: "jquery"
        })
    ]
};

module.exports = config



