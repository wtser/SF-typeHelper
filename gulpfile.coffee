gulp    = require 'gulp'
path    = require 'path'
coffee  = require 'gulp-coffee'
compass = require 'gulp-compass'
changed = require 'gulp-changed'
minifyCSS = require 'gulp-minify-css'



gulp.task 'coffee2js',->
    gulp.src './src/*.coffee'
    .pipe coffee {bare: true}
    .pipe gulp.dest './dist/'

gulp.task 'scss',->
    gulp.src './src/*.scss'
    .pipe(compass({
            project: path.join(__dirname, ''),
            css: 'dist',
            sass: 'src'
        }))
    .pipe gulp.dest './dist/'

gulp.task 'watch', ->
    coffeeFile = gulp.watch './src/*.coffee',['coffee2js']
    coffeeFile.on 'change', (event) ->
        console.log('Event type: ' + event.type);
        console.log('Event path: ' + event.path);

    scssFile = gulp.watch './src/*.scss',['scss']
    scssFile.on 'change', (event) ->
        console.log('Event type: ' + event.type);
        console.log('Event path: ' + event.path);







gulp.task 'default', ['watch']

