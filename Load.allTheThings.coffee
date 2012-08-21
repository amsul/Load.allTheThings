###
     __                           __                ___    ___  ______  __              ______  __
    /\ \                         /\ \              /\_ \  /\_ \/\__  _\/\ \            /\__  _\/\ \      __
    \ \ \        ___      __     \_\ \         __  \//\ \ \//\ \/_/\ \/\ \ \___      __\/_/\ \/\ \ \___ /\_\    ___      __     ____
     \ \ \  __  / __`\  /'__`\   /'_` \      /'__`\  \ \ \  \ \ \ \ \ \ \ \  _ `\  /'__`\ \ \ \ \ \  _ `\/\ \ /' _ `\  /'_ `\  /',__\
      \ \ \L\ \/\ \L\ \/\ \L\.\_/\ \L\ \  __/\ \L\.\_ \_\ \_ \_\ \_\ \ \ \ \ \ \ \/\  __/  \ \ \ \ \ \ \ \ \ \/\ \/\ \/\ \L\ \/\__, `\
       \ \____/\ \____/\ \__/.\_\ \___,_\/\_\ \__/.\_\/\____\/\____\\ \_\ \ \_\ \_\ \____\  \ \_\ \ \_\ \_\ \_\ \_\ \_\ \____ \/\____/
        \/___/  \/___/  \/__/\/_/\/__,_ /\/_/\/__/\/_/\/____/\/____/ \/_/  \/_/\/_/\/____/   \/_/  \/_/\/_/\/_/\/_/\/_/\/___L\ \/___/
                                                                                                                         /\____/
                                                                                                                         \_/__/
    ==================================================================================================================================
    ----------------------------------------------------------------------------------------------------------------------------------
###
###!
    Load.allTheThings v0.4.0 - 21 August, 2012

    (c) Amsul Naeem, 2012 - http://amsul.ca
    Licensed under MIT ("expat" flavour) license.
    Hosted on http://github.com/amsul/Load.allTheThings

    This library creates a Load object which can be used to
    preload things before they are needed on your page. It can
    load images, fonts, stylesheets, scripts, and html.

    To invoke the loader, use Load.allTheThings()
    For more documentation, check http://github.com/amsul/Load.allTheThings
###

###jshint debug: true, browser: true, devel: true, curly: false, forin: false, nonew: true, plusplus: false###


## TODO: add a method to clean up after a thing is loaded


class Load

    self = {}



    ###
    Load all the things!
    ======================================================================== ###

    Load.allTheThings = ( options ) ->

        ## begin loading things based on options
        self.beginLoading( options )

        return Load
    #allTheThings


    ###
    When loading begins, do some things
    ======================================================================== ###

    self.beginLoading = ( options ) ->

        ## keep a private counts of things
        self.PROGRESS = 0
        self.THINGS = 0
        self.THINGS_LOADED = 0


        ## in case no options are passed
        options = options || {}

        ## store the options
        Load.options = options


        ## default options
        self.defaults =
            thingsToLoad:           ['images', 'fonts', 'css', 'js', 'html']
            progressId:             null
            thingsId:               null
            thingsLoadedId:         null
            onError:                ( thing ) -> return Load
            onLoad:                 ( thing ) -> return Load
            onComplete:             -> return Load


        ## check the options and merge with the defaults
        for own key, value of self.defaults
            Load.options[ key ] = options[ key ] || value


        ## store the elements that will need UI updates
        Load.elemProgress = if Load.options.progressId then document.getElementById Load.options.progressId else null
        Load.elemThings = if Load.options.thingsId then document.getElementById Load.options.thingsId else null
        Load.elemThingsLoaded = if Load.options.thingsLoadedId then document.getElementById Load.options.thingsLoadedId else null


        # put in all the initial counts
        if Load.elemThingsLoaded then Load.elemThingsLoaded.innerHTML = self.THINGS_LOADED
        if Load.elemProgress then Load.elemProgress.innerHTML = self.PROGRESS


        ## go through the things and begin loading
        self.loadThings thingType for thingType in Load.options.thingsToLoad


        ## update the UI with the final count of things
        if Load.elemThings then Load.elemThings.innerHTML = self.THINGS

        return self




    ###
    Load things based on type of things
    ======================================================================== ###

    self.loadThings = ( type ) ->

        things = {}

        ## create a selector
        selector = ( ->
            switch type
                when 'images' then 'img'
                when 'fonts' then 'font'
                when 'css' then 'link'
                when 'js' then 'script'
                when 'html' then 'section'
                else throw 'Thing type \'' + type + '\' is unknown'
        )()

        ## get things of this type
        things.all = document.querySelectorAll selector

        ## filtered count
        things.count = 0


        ## filter the things to only get ones with `data-src`
        things.filter = ( thing ) ->
            things.load thing if thing.dataset and thing.dataset.src
            return things


        ## load each filtered thing
        things.load = ( thing ) ->

            ## update the filtered count
            things.count += 1


            ## if type is fonts
            if type is 'fonts'

                font = new Font()

                ## add the handlers based on type
                self.addHandlers font, type

                font.fontFamily = thing.dataset.family
                font.src = thing.dataset.src


            ## for things other than fonts
            else

                ## add the handlers based on type
                self.addHandlers thing, type

                if type is 'css' then thing.href = thing.dataset.src
                else thing.src = thing.dataset.src

            return things


        ## loop through and filter the things
        things.filter thing for thing in things.all


        ## update the things count based on filtered count
        self.THINGS += things.count

        return self




    ###
    Update the progress as things load
    ======================================================================== ###

    self.thingLoaded = ( thing, type, content ) ->

        ## update the counts
        self.THINGS_LOADED += 1
        self.PROGRESS = self.THINGS_LOADED / self.THINGS * 100


        ## update the UI
        Load.elemProgress.innerHTML = self.PROGRESS if Load.elemProgress
        Load.elemThingsLoaded.innerHTML = self.THINGS_LOADED if Load.elemThingsLoaded

        thing.innerHTML = content if type is 'html'


        ## do stuff when this thing is loaded
        Load.options.onLoad thing

        ## do stuff when all the things are loaded
        self.loadComplete() if self.THINGS_LOADED is self.THINGS

        return self




    ###
    Update the progress as things load
    ======================================================================== ###

    self.loadComplete = ->

        ## invoke the oncomplete option
        Load.options.onComplete()

        return self





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
    Add and remove handlers
    ======================================================================== ###

    self.addHandlers = ( thing, type ) ->

        if type is 'images' or type is 'css' or type is 'js'
            self.commonHandlers thing, type

        else if type is 'fonts'

            ## event handlers
            onLoad = ->
                self.
                    removeHandlers( thing, type ).
                    thingLoaded( thing, type )
                return

            onError = ->
                self.removeHandlers thing, type
                Load.options.onError( thing )
                return

            thing.onload = onLoad
            thing.onerror = onError

        else if type is 'html'

            ## create a doc request
            request = new XMLHttpRequest()

            request.onload = (e) ->
                self.
                    removeHandlers(request, type).
                    thingLoaded( thing, type, request.responseText )
                return

            request.onreadystatechange = (e) ->
                if request.readyState is 4 and request.status is 200
                    self.
                        removeHandlers(request, type).
                        thingLoaded( thing, type, request.responseText )
                return

            request.onerror = ->
                self.removeHandlers request, type
                console.log( 'onerror', thing, type )
                return


            request.open 'GET', thing.dataset.src, true
            request.send()

        else
            console.log( 'no add handler', thing, type )

        return self

    self.removeHandlers = ( thing, type ) ->

        if type is 'images' or type is 'css' or type is 'js'
            self.
                unbind( thing, 'load', thing.onLoad ).
                unbind( thing, 'readyStateChange', thing.onReadyStateChange ).
                unbind( thing, 'error', thing.onError )

        else if type is 'fonts'
            thing.onload = ->
            thing.onerror = ->

        else if type is 'html'
            thing.onload = ->
            thing.onreadystatechange = ->
            thing.onerror = ->

        else
            console.log( 'no remove handler', thing, type )

        return self

    self.commonHandlers = ( thing, type ) ->

        onLoad = ( e ) ->
            self.
                removeHandlers( thing, type ).
                thingLoaded( thing, type )
            return

        onReadyStateChange = ( e ) ->
            if thing.readyState is 'complete'
                self.
                    removeHandlers( thing, type ).
                    thingLoaded( thing, type )
            console.log( 'onReadyStateChange', e )
            return

        onError = ( e ) ->
            self.removeHandlers thing, type
            Load.options.onError( thing )
            return

        self.
            bind( thing, 'load', onLoad ).
            bind( thing, 'readyStateChange', onReadyStateChange ).
            bind( thing, 'error', onError )

        return self




    ###
    Intialize the loading
    ======================================================================== ###

    self.initialize = (->

        ## check if Load.fonts has been attached
        if not window.Font or not window.Font::isLoadDotFonts
            throw 'Load.fonts is required for Load.allTheThings to work.'

        ## create a global reach
        window.Load = Load

        return self
    )()
    #initialize









