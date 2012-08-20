###
    Author:         Amsul - http://amsul.ca
    Version:        0.2.0
    Created on:     19/08/2012
    Last Updated:   19 August, 2012
###

###jshint debug: true, browser: true, devel: true, curly: false, forin: false, nonew: true, plusplus: false###



###
==========================================================================

    Load
    All
    The
    Things
    .js

==========================================================================
###

class Load

    self = {}


    ### Easy access for shizzle
    ###

    self.progress = 0
    self.things = 0
    self.thingsLoaded = 0



    ###
    Load all the things!
    ======================================================================== ###

    Load.allTheThings = ( options ) ->

        ## store the progress elem
        Load.elemProgress = if options.progressId then document.getElementById options.progressId else null
        Load.elemThings = if options.thingsId then document.getElementById options.thingsId else null
        Load.elemThingsLoaded = if options.thingsLoadedId then document.getElementById options.thingsLoadedId else null


        self.

            ## load all the images
            loadImages().

            ## load all the fonts
            loadFonts().

            ## do stuff after all the things have started loading
            loadingStarted()

        ###
        ## if it's an object
        if things and typeof things is 'object' and Object.prototype.toString.call( things ) is '[object Object]'
            
            ## try loading the things
            self.tryLoading things

        ## otherwise just return
        else
            console.log( things, 'not object' )
            return Load
        ###
        return Load
    #allTheThings



    ###
    Load all the images with `data-src`
    ======================================================================== ###

    self.loadImages = ->

        images = {}

        ## get all the images
        images.all = document.querySelectorAll 'img'

        ## filtered count
        images.count = 0


        ## filter the images to get only ones with `data-src`
        images.filter = ( image ) ->
            images.load image if image.dataset and image.dataset.src
            return images


        ## load each filtered image
        images.load = ( image ) ->

            ## event handlers
            onLoad = ( e ) ->
                removeHandlers()
                self.thingLoaded()
                return

            onReadyStateChange = ( e ) ->
                removeHandlers() if image.readyState is 'complete'
                console.log( 'onReadyStateChange', e )
                return

            onError = ( e ) ->
                removeHandlers()
                console.log( 'onError', e )
                return

            ## remove event handlers
            removeHandlers = ->
                self.
                    unbind( image, 'load', onLoad ).
                    unbind( image, 'readyStateChange', onReadyStateChange ).
                    unbind( image, 'error', onError )
                return


            ## update the filtered count
            images.count += 1

            ## bind event listeners
            self.
                bind( image, 'load', onLoad ).
                bind( image, 'readyStateChange', onReadyStateChange ).
                bind( image, 'error', onError )

            ## begin the loading
            image.src = image.dataset.src

            return images


        ## loop through and filter the images
        images.filter image for image in images.all


        ## update the things count based on filtered count
        self.things += images.count

        return self
    #loadImages



    ###
    Load all the fonts with `data-src`
    ======================================================================== ###

    self.loadFonts = ->

        fonts = {}

        ## get all the fonts
        fonts.all = document.querySelectorAll 'font'

        ## filtered count
        fonts.count = 0


        ##filter the fonts to get only ones with `data-src`
        fonts.filter = ( font ) ->
            fonts.load font if font.dataset and font.dataset.src
            return fonts


        ## load each filtered font
        fonts.load = ( font ) ->

            newFont = new Font()

            ## event handlers
            onLoad = ( e ) ->
                removeHandlers()
                self.thingLoaded()
                console.log( 'here', e, newFont )
                return

            onError = ( e ) ->
                removeHandlers()
                console.log( 'onError', e )
                return

            ## remove event handlers
            removeHandlers = ->
                newFont.onload = ->
                newFont.onerror = ->
                return

            ## update the filtered count
            fonts.count += 1

            ## bind event listeners
            newFont.onload = onLoad
            newFont.onerror = onError

            ## begin the loading
            newFont.fontFamily = font.dataset.family
            newFont.src = font.dataset.src

            ## set the font family and force the whitespace fix
            font.style.fontFamily = font.dataset.family.replace( /\ /g, '\\ ' )
            
            console.dir( font )

            return fonts


        ## loop through and filter the fonts
        fonts.filter font for font in fonts.all


        ## update the things count based on filtered count
        self.things += fonts.count

        return self
    #loadFonts





    ###
    Bind and unbind some events
    ======================================================================== ###

    self.bind = ( thing, listener, handler ) ->
        thing.addEventListener listener, handler, false
        return self

    self.unbind = ( thing, listener, handler ) ->
        thing.removeEventListener listener, handler
        return self



    ###
    Update the progress as things load
    ======================================================================== ###

    self.thingLoaded = ->

        ## update the counts
        self.thingsLoaded += 1
        self.progress = self.thingsLoaded / self.things * 100

        ## update the UI
        if Load.elemProgress then Load.elemProgress.innerHTML = self.progress
        if Load.elemThingsLoaded then Load.elemThingsLoaded.innerHTML = self.thingsLoaded

        return self



    ###
    After all the things have started loading
    ======================================================================== ###

    self.loadingStarted = ->

        # put in all the initial counts
        if Load.elemThings then Load.elemThings.innerHTML = self.things
        if Load.elemThingsLoaded then Load.elemThingsLoaded.innerHTML = self.thingsLoaded
        if Load.elemProgress then Load.elemProgress.innerHTML = self.progress

        return self







    ###
    Try loading the things passed
    ======================================================================== ## #

    self.tryLoading = ( things ) ->

        doTrial = ( type, thing ) ->

            try
                Load.get[ type ] thing
            
            catch error
                #console.log error, ' .. warning bro. there\'s no \'' + type + '\' loader'


        ## try loading the thing based on type
        doTrial type, thing for own type, thing of things

        return self

    #checkThings



    ## #
    Load in things
    ======================================================================== ## #

    Load.get =

        ## load some images
        images: ( thing ) ->


            ## if the thing is an array

            if thing and typeof thing is 'object' and Object.prototype.toString.call thing is '[object Array]'
                console.log 'this is an array', thing


            ## if the thing is a string

            else if typeof thing is 'string'
                self.loadImage thing


            else console.log 'some other thing', thing

    #get



    ## #
    Load images
    ======================================================================== ## #

    self.loadImage = ( url ) ->

        console.log 'url', url

        return self
    ###


    



    ###
    Intialize the loading
    ======================================================================== ###

    Load.initialize = (->

        ## create a global reach
        window.Load = Load


        Load.allTheThings({
            'asdf': ['asdfasdf',333,'lol']
            'images': 'homer.png'
            'fonts': ['asfd.ttf','loler.woff']
            'progressId': 'progress'
            'thingsId': 'things'
            'thingsLoadedId': 'things_loaded'
        })

        return Load
    )()
    #initialize







###
`
/ * ==========================================================================

    APP stuff begins

========================================================================== * /

(function($, window, document, undefined) {

    'use strict';

    var

        / *
            Globals
        ======================================================================== * /

        $window = $( window ),
        $APP = $( '#APP' ),


        / *
            APP
        ======================================================================== * /

        APP = (function app() {

            var self = {}



            / *
                Do stuff with the app
            ======================================================================== * /

            app.do_something = function() {

                

                return app
            }





            / *
                Start up the app
            ========================================================================== * /

            self.start = function() {



                return self
            } // start



            return app
        })() // APP






    / *
        Start 'er up!
    ======================================================================== * /

    APP.start()


})(jQuery, window, document)`
###