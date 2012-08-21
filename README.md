![Load.allTheThings](http://i.imgur.com/PdbF7.png)

Load.allTheThings
=================

Load resources before they are needed on your page with just one simple invocation:

```
Load.allTheThings();

// or the shorthand
LaTT();
```
<br>
Current build: _alpha_ v0.3.0 – 21 August, 2012

<br>

## Things you can load

- <big>**Images**</big> ([more info](#Images))
- <big>**Fonts**</big> ([more info](#Fonts))
- <big>**Stylesheets**</big> ([more info](#Stylesheets))
- <big>**Scripts**</big> ([more info](#Scripts))
- <big>**Html**</big> ([more info](#Html))


<br>
<div id="API"></div>
## The API

There are a few options available to be passed into your loader:

```
options = {
	thingsToLoad: [ <list_of_things> ],
	progressId: <element_ID>,
	thingsId: <element_ID>,
	thingsLoadedId: <element_ID>
}
```



<br>
<div id="Images"></div>
## Images


To have any image preload, simply change it's `src` to `data-src`. For example:

```
<img src="http://www.google.com/images/srpr/logo3w.png">
```

Changes to:

```
<img data-src="http://www.google.com/images/srpr/logo3w.png">
```



<br>
<div id="Images"></div>
## More coming soon

...


<br><br>

---
This code is (c) Amsul Naeem, 2012 – Licensed under the MIT ("expat" flavor) license.





