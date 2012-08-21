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
    Load.allTheThings v0.3.0 - 21 August, 2012

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



class Load

    self = {}



    ###
    Load all the things!
    ======================================================================== ###

    Load.allTheThings = ( options ) ->

        ## get things to load from options
        return Load if not options.thingsToLoad


        ## private counts of things
        self.PROGRESS = 0
        self.THINGS = 0
        self.THINGS_LOADED = 0


        ## store the progress elem
        Load.elemProgress = if options.progressId then document.getElementById options.progressId else null
        Load.elemThings = if options.thingsId then document.getElementById options.thingsId else null
        Load.elemThingsLoaded = if options.thingsLoadedId then document.getElementById options.thingsLoadedId else null


        ## go through the things to load
        self.loadThings thingType for thingType in options.thingsToLoad

        ## do stuff after all the things have started loading
        self.loadingStarted()

        return Load
    #allTheThings



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
                when 'doc' then 'section'
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
                    removeHandlers(thing, type).
                    thingLoaded()
                return

            onError = ->
                self.removeHandlers thing, type
                console.log( 'onError', thing, type )
                return

            thing.onload = onLoad
            thing.onerror = onError

        else if type is 'doc'

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

        else if type is 'doc'
            thing.onload = ->
            thing.onreadystatechange = ->
            thing.onerror = ->

        else
            console.log( 'no remove handler', thing, type )

        return self

    self.commonHandlers = ( thing, type ) ->

        onLoad = ( e ) ->
            self.
                removeHandlers(thing, type).
                thingLoaded()
            return

        onReadyStateChange = ( e ) ->
            if thing.readyState is 'complete'
                self.
                    removeHandlers(thing, type).
                    thingLoaded()
            console.log( 'onReadyStateChange', e )
            return

        onError = ( e ) ->
            self.removeHandlers thing, type
            console.log( 'onError', e )
            return

        self.
            bind( thing, 'load', onLoad ).
            bind( thing, 'readyStateChange', onReadyStateChange ).
            bind( thing, 'error', onError )

        return self





    ###
    Update the progress as things load
    ======================================================================== ###

    self.thingLoaded = ( thing, type, content ) ->

        ## update the counts
        self.THINGS_LOADED += 1
        self.PROGRESS = self.THINGS_LOADED / self.THINGS * 100

        ## update the UI
        if Load.elemProgress then Load.elemProgress.innerHTML = self.PROGRESS
        if Load.elemThingsLoaded then Load.elemThingsLoaded.innerHTML = self.THINGS_LOADED

        if type is 'doc' then thing.innerHTML = content

        return self




    ###
    After all the things have started loading
    ======================================================================== ###

    self.loadingStarted = ->

        # put in all the initial counts
        if Load.elemThings then Load.elemThings.innerHTML = self.THINGS
        if Load.elemThingsLoaded then Load.elemThingsLoaded.innerHTML = self.THINGS_LOADED
        if Load.elemProgress then Load.elemProgress.innerHTML = self.PROGRESS

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









