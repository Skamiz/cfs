# Customisable formspecs [cfs]

## About
The purpose of this mod is to make it possible to define formspec style information and easily apply it to any fromspec of your choosing.

## How it works.
Once you have asembled a bare bones formspec you hand it to 'cfs.style_formspec'.

This function cuts the formspec up into it's individual components.

First, if it's requested, it blocks the players formspec_prepend from taking effect and
instead inserts the prepend of the specified style.

Then it starts calling the callbacks defined in a stlye, to modify the formspec.
Starting with the 'do_once' callback, for things that are only done once, like setting up backgrounds.

Then it iterates through each element of the formspec.
If the style provids a callback with the same name as the current element, it is called
and it has a chance to modify or add to the curent element.

Once it's gone through every element of the formspec, all the edits and additions
get assembled into a new formspec that is returned to the caller.

## Usage
**cfs.style_formspec(fs, style_name, force_prepend)**
fs - formspec to be styled, is a string
style_name - either a string, the name of a registered style or a player object
		in which case the players meta is queried for the 'formspec_style' key
force_prepend - if true instead of the players prepend use the prepend defined in the requested style

returns the modified formspec strging with all styling information applied

**cfs.set_player_style(player, style_name)**
sets the plyers 'formspec_style' meta to the given name
sets the players 'formspec_prepend' to the styles prepend


## Styles
For an example and explanation of how styles are defined see 'style_example.lua'

### Helper functions
Some helper functions for wrting styles

**cfs.slot_in_list(x, y, w, h)**
assumes that you give it position and size of an inventory list
returns an iterator that yields x and y positions for individual slots in the given list
uselfull for decoration inventory lists in a more fancifull way then the 'listcolors' element

**cfs.explode_fs_args(args)**
if given the argument list of a formspec element, it returns them as individual values,
if the given argument is a position or size, it's automatically converted to a vector
and it's w(idth) and h(eight) values are made equivalent to it's x and y values respectively

e.g.:
'0,0;2,1;button1;This Is Button'
gets converted into:
{x = 0, y = 0}, {w = 2, h = 1}, "button1", "This Is Button"
x,y and w,h are interchangable, the only purpose is to make
mental bookkeeping easier of what is a postions and what is a size

**cfs.tile_image(image, iw, ih, nx, ny)**
uses '[combine' to tille an image
image - image to tille
iw, ih - image width and height in pixels
nw, nh - width and height of the resulting tilled image, again in pixels

returns the whole [combine string

usefull when you want to fill an area in a repeating pattern, since minetest
in allmost all cases defaults to squishing and stretching images to fit a given area

## Setting
'soft_prepend'
if this is set to true, the players 'formspec_prepend' is never modified
and instead 'cfs.style_formspec' acts as if force_prepend was allways true

### prepend awkwardness
The player specific formspec_prepend is in an awkward spot.
The styling options it offers are limited ond once you exeed them and use more then one style,
you must constantly make sure that the prepend is synchronised with the sytle of any given
formspec the player is currently looking at, or things start looking odd, which kind of defeats the purpose of the prepend.

I suspect it might be best in such circumstances to activate the 'soft_prepend',
reserve the player prepend for affecting formspecs which are otherwise unreachable,
like the pause and death screens, and let 'style_formspec' add the style prepend to each individual formspec.


Additionally be carefull with the use of the 'formspec' field in a nodes meta, since, 
once it's set, you can't intercept the showing of the given forsmpec.
