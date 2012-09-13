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
    Load.allTheThings v0.7.2 - 12 September, 2012

    (c) Amsul Naeem, 2012 - http://amsul.ca
    Licensed under MIT ("expat" flavour) license.
    Hosted on http://github.com/amsul/Load.allTheThings

    This library creates a Load object which can be used to
    preload things before they are needed on your page. It can
    load images, fonts, stylesheets, scripts, and html.

    To invoke the loader, use Load.allTheThings()
    For more documentation, check http://github.com/amsul/Load.allTheThings


    * Note: Load.fonts is required to load fonts (http://github.com/amsul/Load.fonts)
###

###jshint debug: true, browser: true, devel: true, curly: false, forin: false, nonew: true, plusplus: false###


class Load


    ## create a global reach
    window.Load = Load

    ## for private methods
    self = {}

    ## for querying the dom
    dom =
        get: ( selector ) ->
            if selector and typeof selector is 'string'
                if selector.match /^#/ then return document.getElementById selector.replace /^#/, ''
                else if selector.match /^\./ then return document.getElementsByClassName selector.replace /^\./, ''
                else return document.querySelectorAll selector
            return null




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
            thingsToLoad:           [ 'images', 'fonts', 'css', 'js', 'html', 'data' ]
            within:                 null
            progressId:             null
            progressBarId:          null
            thingsId:               null
            thingsLoadedId:         null
            cleanUp:                false
            onError:                ( thing ) -> return Load
            onLoad:                 ( thing ) -> return Load
            onComplete:             -> return Load


        ## check the options and merge with the defaults
        for own key, value of self.defaults
            Load.options[ key ] = options[ key ] || value


        ## check if fonts are being requested
        if Load.options.thingsToLoad.indexOf 'fonts' isnt -1

            ## check if Load.fonts has been attached
            if not window.Font or not window.Font::isLoadDotFonts
                throw 'Load.fonts (http://github.com/amsul/Load.fonts) is required for Load.allTheThings to work with fonts.'


        ## store the elements that will need UI updates
        Load.elemProgress = dom.get '#' + Load.options.progressId
        Load.elemProgressBar = dom.get '#' + Load.options.progressBarId
        Load.elemThings = dom.get '#' + Load.options.thingsId
        Load.elemThingsLoaded = dom.get '#' + Load.options.thingsLoadedId


        # put in all the initial counts
        Load.elemThingsLoaded.innerHTML = self.THINGS_LOADED if Load.elemThingsLoaded
        Load.elemProgress.innerHTML = self.PROGRESS if Load.elemProgress


        ## figure out the context
        context = ( ->
            selector = dom.get Load.options.within
            return selector || document
        )()


        ## collect all the required things within the context
        self.loadAllThingsWithin context if context


        ## update the UI with the final count of things
        Load.elemThings.innerHTML = self.THINGS if Load.elemThings
        Load.elemProgressBar.style.width = 0 + '%' if Load.elemProgressBar

        return self
    #beginLoading




    ###
    Add things to a collection to be loaded
    ======================================================================== ###

    self.loadAllThingsWithin = ( context ) ->

        ## collection for context nodes
        collectionOfNodes = []

        ## collection of all the things found
        collectionOfThings = []


        ## check if the context is a nodelist
        if context.constructor.name is 'NodeList'

            ## push all the context elements into a collection
            collectionOfNodes.push node for node in context


        ## if it's not a nodelist, just pass into collection
        else collectionOfNodes.push context


        ## go through the type of things to load, and find them
        thingsToLoad = Load.options.thingsToLoad
        thingsToLoad = if typeof thingsToLoad is 'string' then [ thingsToLoad ] else thingsToLoad
        self.findThings collectionOfNodes, collectionOfThings, type for type in thingsToLoad


        ## update the count of things
        self.THINGS += collectionOfThings.length

        return self
    #loadAllThingsWithin




    ###
    Find things to load in a collection
    ======================================================================== ###

    self.findThings = ( collectionNodes, collectionThings, type ) ->

        ## filter things with `data-src` out of a list of things
        filterThenLoad = ( things, type ) ->

            ## go through the things and filter out ones with `data-src`
            for thing in things

                ## if there is a `data-src`
                if thing.dataset and thing.dataset.src

                    ## begin loading the thing
                    self.load thing, type

                    ## put the thing in the collection
                    collectionThings.push thing

            return self


        ## create a selector based on type
        selector = ( ->
            switch type
                when 'images' then 'img'
                when 'fonts' then 'font'
                when 'css' then 'link'
                when 'js' then 'script'
                when 'html' then 'section'
                when 'data' then 'code'
                else throw 'Thing type \'' + type + '\' is unknown'
        )()


        ## get things of this type within the collection
        for node in collectionNodes

            ## find the things of this type in this node
            things = node.querySelectorAll selector

            ## if there are matching things
            filterThenLoad things, type if things.length


        return self
    #findThings




    ###
    Load things based on type of things
    ======================================================================== ###

    self.load = ( thing, type ) ->


        ## if type is fonts
        if type is 'fonts'

            font = new Font()

            ## add the handlers based on type
            self.addHandlers font, type

            ## set the font family and start to load
            font.fontFamily = thing.dataset.family
            font.src = thing.dataset.src


        ## for things other than fonts
        else

            request = thing.dataset.src

            ## add the handlers based on type
            self.addHandlers thing, type

            if type is 'css' then thing.href = request
            else thing.src = request


        ## do cleanup on the thing element
        self.doCleanUp thing, type

        return self
    #load




    ###
    Do a clean up of the thing data-src
    ======================================================================== ###

    self.doCleanUp = ( thing, type ) ->

        ## remove the data binding
        thing.removeAttribute 'data-src'


        ## only for data and fonts
        if type is 'data' or type is 'fonts'

            ## if a total clean up is required, remove thing from the dom
            if Load.options.cleanUp then thing.outerHTML = ''

            ## otherwise hide the thing
            else thing.style.display = 'none'


        return self
    #doCleanup




    ###
    Update the progress as things load
    ======================================================================== ###

    self.thingLoaded = ( thing, type, request ) ->

        ## update the counts
        self.THINGS_LOADED += 1
        self.PROGRESS = self.THINGS_LOADED / self.THINGS * 100


        ## update the UI
        Load.elemProgress.innerHTML = self.PROGRESS if Load.elemProgress
        Load.elemProgressBar.style.width = self.PROGRESS + '%' if Load.elemProgressBar
        Load.elemThingsLoaded.innerHTML = self.THINGS_LOADED if Load.elemThingsLoaded


        ## do final stuff depending on type
        if type is 'html'
            thing.innerHTML = request.responseText

        else if type is 'data'
            self.addToCache thing, type, request.responseText


        ## do stuff when this thing is loaded
        Load.options.onLoad thing, type

        ## do stuff when all the things are loaded
        self.loadComplete() if self.THINGS_LOADED is self.THINGS

        return self
    #thingLoaded




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
                Load.options.onError thing, type
                return

            thing.onload = onLoad
            thing.onerror = onError

        else if type is 'html' or type is 'data'

            ## create a doc request
            request = new XMLHttpRequest()

            request.onload = (e) ->
                self.
                    removeHandlers(request, type).
                    thingLoaded( thing, type, request )
                return

            request.onreadystatechange = (e) ->
                if request.readyState is 4 and request.status is 200
                    self.
                        removeHandlers( request, type ).
                        thingLoaded( thing, type, request )
                return

            request.onerror = ->
                self.removeHandlers request, type
                return


            request.open 'GET', thing.dataset.src, true
            request.send()

        else
            console.log( 'no add handler', thing, type )

        return self
    #addHandlers


    self.removeHandlers = ( thing, type ) ->

        if type is 'images' or type is 'css' or type is 'js'
            self.
                unbind( thing, 'load', thing.onLoad ).
                unbind( thing, 'readyStateChange', thing.onReadyStateChange ).
                unbind( thing, 'error', thing.onError )

        else if type is 'fonts'
            thing.onload = ->
            thing.onerror = ->

        else if type is 'html' or type is 'data'
            thing.onload = ->
            thing.onreadystatechange = ->
            thing.onerror = ->

        else
            console.log( 'no remove handler', thing, type )

        return self
    #removeHandlers


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
            return

        onError = ( e ) ->
            self.removeHandlers thing, type
            Load.options.onError thing, type
            return

        self.
            bind( thing, 'load', onLoad ).
            bind( thing, 'readyStateChange', onReadyStateChange ).
            bind( thing, 'error', onError )

        return self
    #commonHandlers




    ###
    Add a thing to the cache
    ======================================================================== ###

    self.addToCache = ( thing, type, content ) ->

        self.cache = self.cache || {}

        if type is 'data'

            ## parse it as json
            item = JSON.parse content

            if thing.dataset and thing.dataset.name
                self.cache[ thing.dataset.name ] = item

            else
                throw 'No name given to this type \'' + type + '\''

        return self
    #addToCache



    ###
    Get a thing from cache
    ======================================================================== ###

    Load.getCached = ( name ) ->
        cachedThing = self.cache[ name ]
        if cachedThing then return cachedThing












