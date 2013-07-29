module.exports = (grunt) ->
  version = ->
    grunt.file.readJSON("package.json").version
  version_tag = ->
    "v#{version()}"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    minified_comments: "/* Octopus #{version_tag()} | (c) 2011-2013 by Rex Sheng */\n"

    concat:
      jquery:
        src: ["public/octopus.js"]
        dest: "public/octopus.js"

    coffee:
      options:
        join: true
      compile:
        files:
          'public/octopus.js': ['backbone/models/models.coffee', 'backbone/main.coffee', 'backbone/views/*.coffee']

    uglify:
      options:
        mangle:
          except: ['jQuery', 'App', 'Parse']
        banner: "<%= minified_comments %>"
      minified_chosen_js:
        files:
          'public/octopus.min.js': ['public/octopus.js']

    cssmin:
      minified_chosen_css:
        options:
          banner: "<%= minified_comments %>"
        src: ['public/css/code-editor.css', 'public/css/elements.css', 'public/css/icons.css', 'public/css/layout.css', 'public/css/compiled/*.css']
        dest: 'public/octopus.min.css'

    watch:
      scripts:
        files: ['backbone/**/*.coffee']
        tasks: ['build']

    copy:
      dist:
        files: [
          { cwd: "public", src: ["img/**", "font/**", "lib/**", "index.html", "css/bootstrap/*.css", "css/lib/**", "octopus.min.js", "octopus.min.css"], dest: "dist/", expand: true, flatten: false, filter: 'isFile' }
          { src: ["chosen/public/chosen.min.css", "chosen/public/chosen.jquery.min.js", "chosen/public/chosen-sprite*.png"], dest: "dist/chosen/", expand: true, flatten: true, filter: 'isFile' }
          { src: ["node_modules/parse/build/parse-latest.js"], dest: "dist/parse/", expand: true, flatten: true, filter: 'isFile' }
        ]

    clean:
      dist: ["dist/"]
      chosen_zip: ["*.zip"]

    build_gh_pages:
      gh_pages: {}

    dom_munger:
      download_links:
        src: 'public/index.html'
        options:
          callback: ($) ->
            $("#latest_version").attr("href", version_url()).text("Stable Version (#{version_tag()})")

    zip:
      chosen:
        cwd: 'public/'
        src: ['public/**/*']
        dest: "chosen_#{version_tag()}.zip"

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-build-gh-pages'
  grunt.loadNpmTasks 'grunt-zip'
  grunt.loadNpmTasks 'grunt-dom-munger'

  grunt.registerTask 'default', ['build']
  grunt.registerTask 'build', ['coffee', 'concat', 'uglify', 'cssmin']
  grunt.registerTask 'gh_pages', ['clean', 'copy:dist', 'build_gh_pages:gh_pages']
