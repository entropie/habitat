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
        app: './apps/web/assets/javascripts/application.js',
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


// if (process.env.INBUILT_WEBPACK_DEV_SERVER) {

//     var merge = require("webpack-merge");

//     var dev_server_config = {
//         devServer: {
//             port: devServerPort,
//             headers: {
//                 "Access-Control-Allow-Origin": "*",
//             }
//         }
//     };

//     var dev_server_output = {
//         output: {
//             publicPath: "//" + devServerHost + ":" + devServerPort + "/"
//         }

//     };
//     module.exports = merge(module.exports, dev_server_config, dev_server_output);
// }



