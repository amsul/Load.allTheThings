![Load.allTheThings](http://i.imgur.com/PdbF7.png)

Load.allTheThings
=================

Current build: _beta_ v0.7.2 – 12 September, 2012

A simple JavaScript library to load resources as they are needed on your page with just one simple invocation:

```
Load.allTheThings()
```


<br>

### Things you can load

- <big>**Images**</big> ([more info](#images))
- <big>**Fonts**</big> ([more info](#fonts))
- <big>**Stylesheets**</big> ([more info](#stylesheets))
- <big>**Scripts**</big> ([more info](#scripts))
- <big>**HTML**</big> ([more info](#html))
- <big>**JSON**</big> ([more info](#json))


<br>
#### Options

There are a few options available to be passed into your loader. [Read the API](#the-api) for more details on how to use.

```
options = {
	thingsToLoad: [ <list_of_things> ],
	within: <css_selector>,
	progressId: <element_ID>,
	progressBarID: <element_ID>,
	thingsId: <element_ID>,
	thingsLoadedId: <element_ID>,
	onError: <function>,
	onLoad: <function>,
	onComplete: <function>
}

Load.allTheThings( options )
```





<br>
## The Markup


### Images


To have any image preload, simply change it's `src` to `data-src`. For example:

```
<img src="http://www.google.com/images/srpr/logo3w.png">
```

Becomes:

```
<img data-src="http://www.google.com/images/srpr/logo3w.png">
```

<br>
### Fonts

To fetch fonts, use the `font` element as follows:

```
<font data-family="My Family Name" data-src="media/myfont.ttf"></font>
```

Both the `data-family` and `data-src` are required attributes.

Once the font has loaded, all elements targeted with your CSS to have `font-family: "My Family Name"` will have your typeface.


<sub>__PS:__ Yes, the `font` element has deprecated with HTML5 - but all browsers support it and that's why it's perfect (less elements to traverse through).</sub>


<br>
### Stylesheets

Loading stylesheets is similar to loading images. Just change the `href` to `data-src`. Example:

```
<link data-src="http://html5boilerplate.com/css/_normalize.css">
```

When the stylesheet is done loading, it is immediately applied to the page.


<br>
### Scripts

JavaScript files can also be loaded similarly. Example:

<pre>
&lt;script data-src="http://code.jquery.com/jquery-1.8.0.js"&gt;&lt;/script&gt;
</pre>

The script is immediately invoked once it is loaded.


<br>
### HTML

To load HTML, specify a `data-src` to a `section` element where you want the content to be printed to. Example:

```
<section data-src="media/ajaxed_page.htm"></section>
```

Once the page has loaded, it will be inserted into this `section` element.


<br>
### JSON

JSON data can be loaded through the `code` element. Example:

```
<code data-name="myJsonData" data-src="media/data.json"></code>
```

Both the `data-name` and `data-src` are required attributes.

Once the data has loaded, you can use the `Load.getCached` method to retrieve this data depending on the `data-name` you provided:

```
Load.getCached( 'myJsonData' )    // outputs your JSON data
```

<br><br>

===


<br>
## The API

### options.thingsToLoad

An array of things you would like to load.

```
thingsToLoad: [ 'images', 'fonts', 'css', 'js', 'html', 'data' ]
```

By default, it will load all of the things. You can pick and choose the things you want to load and [markup your document accordingly](#Markup).

The `data` thing is for fetching JSON data. Once the loader has completed, a `Load.getCached` method is available to retrieve this stored JSON. More on this in the [JSON](#JSON) section.


<br>
### options.within

You can give context to your search of things to load with a CSS selector. By default, it will search the entire document. Example:

```
within: '#content'

// or
within: '.preload'

// or
within: 'section'
```

<br>
### options.progressId

The `ID` of the element that will display the loading progress in numbers. Example:

<pre>
&lt;!-- the html -->
Progress:
&lt;span id="progress_count"&gt;&lt;/span&gt;%
</pre>

```
// the javascript
progressId: 'progress_count'
```

<br>
### options.progressBarId

The `ID` of the element that will display as a progress bar. Example:

<pre>
&lt;!-- the html -->
Progress bar:
&lt;div id="progress_bar"&gt;&lt;/div&gt;
</pre>

```
// the javascript
progressBarId: 'progress_bar'
```

<br>
### options.thingsId

The `ID` of the element that will display the total number of things there are to load. Similar format as needed for `options.progressId`.

<br>
### options.thingsLoadedId

The `ID` of the element that will display a live count on the number of things that have loaded. Similar format as needed for `options.progressId`.


<br>
### options.onError and options.onLoad

__options.onError__ is called if something goes wrong in loading any thing. __options.onLoad__ is called as each individual thing is loaded. Example:

```
onError: function( thing, type ) {
    console.error( 'There was an error loading a thing of ' + type + '.', thing )
},
onLoad: function( thing, type ) {
    console.log( 'Done loading a thing of ' + type + '.', thing )
}
```

<br>
### options.onComplete

This is called when the loader has finished loading all the things.

```
options.onComplete = function() {
    alert( 'All the things have loaded!' )
}
```




<br><br>

---
This code is (c) Amsul Naeem, 2012 – Licensed under the MIT ("expat" flavor) license.
