use Rack::Static,
    root: 'example', urls: %w(/js /css)

run lambda { |env|
  [
      200,
      {
          'Content-Type'  => 'text/html',
          'Cache-Control' => 'no-cache'
      },
      File.open('example/index.html', File::RDONLY)
  ]
}