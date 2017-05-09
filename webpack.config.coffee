path= require "path"
host= "localhost"
port= 30000
module.exports=
  entry: [
    "./index.coffee"
    "./index.sass"
    "webpack-dev-server/client?http://#{host}:#{port}"
  ]
  output: filename: "index.js", path: path.resolve( __dirname,"bundled"), publicPath: "http://#{host}:#{port}/assets/"
  module:
    rules:[
      pug=
        test: /\.pug$/
        use: ["pug-loader"]
      coffee=
        test: /\.coffee$/
        use: ["coffee-loader"]
      sass=
        test: /\.sass$/
        use: ["style-loader","css-loader","sass-loader"]
    ]

  plugins: [
    new (require "html-webpack-plugin")
      template: "index.html.pug"
      filename: "index.html"
      inject: "head"
  ]

  devServer:
    contentBase: path.join __dirname, "bundled"
    host: host, port: port, quiet: off, noInfo: off, stats:off
  devtool: "source-map"
