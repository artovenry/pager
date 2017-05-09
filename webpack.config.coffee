path= require "path"
host= "192.168.1.104"
port= 30000
module.exports=
  entry: [
    "./index.coffee"
    "webpack-dev-server/client?http://#{host}:#{port}"
  ]
  output: filename: "bundled/index.js", path: path.resolve( __dirname,"devServer"), publicPath: "http://#{host}:#{port}/assets/"
  module:
    rules:[
      pug= 
        test: /\.pug$/
        use: ["pug-loader"]
      coffee=
        test: /\.coffee$/
        use: ["coffee-loader"]
    ]

  plugins: [
    new (require "html-webpack-plugin")
  ]

  devServer:
    contentBase: path.join __dirname, "devServer"
    host: host, port: port, quiet: off, noInfo: off, stats:{assets: off, colors: on, version: off, hash: off, timings: off, chunks: off, chunkModules: off}
  devtool: "source-map"
