/*global module:false*/
module.exports = function(grunt) {
  // Project configuration.
  grunt.initConfig({
    pkg: '<json:package.json>',
    coffee: {
      all: {
        src: "**/*.coffee",
        options: {
          bare: false,
          preserve_dirs: true
        }
      }
    },
    jasmine: {
      src: [
        'spec/vendor/lodash*.js',
        'spec/vendor/backbone*.js',
        'lib/**/*.js'
      ],
      helpers: 'spec/helpers/*.js',
      specs: 'spec/**/*spec.js'
    },
    watch: {
      files: ['<config:coffee.all.src>'],
      tasks: 'travis'
    }
  });

  // Lib tasks.
  grunt.loadNpmTasks('grunt-jasmine-runner');
  grunt.loadNpmTasks('grunt-coffee');

  // Travis CI task.
  grunt.registerTask('travis', 'coffee jasmine');

  // Default task.
  grunt.registerTask('default', 'travis');
};
