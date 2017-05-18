path= require "path"

env   = process.env
host  = env.npm_package_config_host ? "localhost"
port  = env.npm_package_config_port ? "30000"
env   = env.NODE_ENV ? "development"

module.exports=
  entry: switch env
    when "development"  then ["./index.coffee"]
    when "production"   then ["./pager.coffee"]

  output:
    switch env
      when "development"
        filename: "index.js", path: path.resolve( __dirname,"bundled"), publicPath: "http://#{host}:#{port}/assets/"
      when "production"
        filename: "index.min.js", path: path.resolve( __dirname,"dist")
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

  plugins: do ->
    html= new (require "html-webpack-plugin")
      template: "index.html.pug"
      filename: "index.html"
      inject: "head"
    uglifyjs= new (require "uglifyjs-webpack-plugin")
    if env is "production"
      [uglifyjs]
    else
      [html]
  devServer:
    contentBase: path.join __dirname, "bundled"
    host: host, port: port, quiet: off, noInfo: off, stats:off
  devtool: "source-map" unless env is "production"
