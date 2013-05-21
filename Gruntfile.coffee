fs = require("fs")

module.exports = (grunt) ->
  minifiedFiles = "min/jquery-thingy-picker.js": ["javascript/jquery-thingy-picker.js"]
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    uglify:
      my_target:
        files: minifiedFiles

      options:
        fromString: true
        mangle: true
        compress:
          dead_code: false

        output:
          ascii_only: true

    coffee:
      glob_to_multiple:
        expand: true
        cwd: "src"
        src: '**/*.coffee'
        dest: 'build/'
        ext: '.js'
        rename: (base, path) ->
          return base + path.replace(/coffeescript/g, 'javascript')

    copy:
      files:
        expand: true
        cwd: 'src'
        src: "**/*.js"
        dest: 'build/'

    jasmine:
      src: "build/main/javascript/jquery-thingy-picker.js"
      options:
        vendor: 'build/spec/lib/*.js'
        specs: "build/spec/javascript/*.js"

    watch:
      coffee:
        files: 'src/**/*.coffee'
        tasks: 'coffee'
      haml:
        files: "src/example/*.haml"
        tasks: ["haml"]
      specs:
        files: ["<config:jasmine.specs>", "javascript/*.(js|js.coffee|coffee)"]
        tasks: "jasmine"

      less:
        files: "src/less/*.less"
        tasks: ["less"]

    haml:
      dist:
        files:
          "build/example/index.html": "src/example/index.html.haml"

    less:
      options:
        yuicompress: true

      files:
        src: "src/less/jquery-thingy-picker.less"
        dest: "build/css/jquery-thingy-picker.css"

  
  # These plugins provide necessary tasks.
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-contrib-haml"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.registerTask 'symlink', 'Creates symlinks', ->
    relink = (src, dest) ->
      if fs.existsSync(dest) then fs.unlinkSync(dest)
      fs.symlink src, dest

    console.log "creating symlinks ..."
    relink '../css', 'build/example/css'
    relink '../main/javascript', 'build/example/js'
  
  # Default task.
  grunt.registerTask "default", ["watch"]