___
#Eureka: A Non-Technical Introduction
___

Eureka! is a library to create dynamic table-view forms from a DSL specification in Swift...

___
###Whoa, you said, "Non-Technical" Introduction!
___

Okay, yeah, I did.

___
###What's a DSL specification?
___

Most popular computer programming languages are designed to be versatile- they can be used for a large variety of tasks.  Ideally, anything the programmer can think up.

That same versatility can make them cumbersome for more specific tasks.  It may take a dozen lines of code to perform a simple operation, or the programming language may require the programmer to specify several options before getting the result he or she wants.

A DSL specification is typically a smaller language designed to address this issue.  It's more focused and as a result can clean out some of the headway needed to accomplish its specific goal.

___
###I've never programmed.  Can you explain that a little more?
___

Let's look at the following text,

![Color_Text](http://i.imgur.com/xdyeOXF.jpg)



In HTML to get that result a programmer has to:
- Define the color of the text (red or blue)
- Define the text size (24 or 14)
- Define the line spacing (100% or 0)
- Do  this for *every* line

It looks like this:

	<p style="color:red;font-size:24px;line-height:100%;">This sentence is red and uses a larger font</p>
	<p style= "color:blue;font-size:14px;line-height:0;">This sentence is blue and uses a smaller font</p>
	<p style="color:red;font-size:24px;line-height:100%;">This sentence is also red and uses a larger font</p>
	<p style= "color:blue;font-size:14px;line-height:0;">This sentence is also blue and uses a smaller font</p>
	<p style="color:red;font-size:24px;line-height:100%;">This sentence is the third red sentence that uses a larger font</p>
	<p style= "color:blue;font-size:14px;line-height:0;">This sentence is the third blue sentence that uses a smaller font</p>

If you can't read code, that's okay.  Just realize that's a lot of repeated syntax.  HTML does not have a built in way to say, *in a single phrase*, "Make this sentence red, with a larger font, and single line spacing."

The reason for this is that  need for versatility.  Your work may have patterns, but HTML is designed to give you control over every line.  As far as the programming language is concerned, you may want you third line purple, your fifth line orange, and your sixth line green.  HTML is designed to allow you to do that.

___
###You still haven't explained DSL protocols
___

A DSL protocol is a language designed to work inside a particular environment, including another language.  Going back to HTML, a popular DSL protocol is CSS.  CSS's goal is to allow a programmer to define patterns in his or he code which can be reused to simplify and minimize code duplication.

So in CSS I could:
	- define "redline" as a paragraph or sentence where the text is the color red, the font-size is 24, and the line-height is 100%.
	- define "blueline" as a paragraph or sentence where the text is the color blue, the font-size is 14, and the line-height is 0.

Now our HTML code will look like this:

	<p class="redline">This sentence is red and uses a larger font</p>
	<p class= "blueline">This sentence is blue and uses a smaller font</p>

In essence **a DSL protocol is a language designed to simplify the execution of a more specific task.**

___
###That sort of makes sense.  Can you use a non-programming example?
___

Sure, take a look at this object here:

![Vacuum](http://i.imgur.com/rCh30L7m.png)

The bottom of the vacuum is fairly versatile.  It works for floors, stairs, technically and you could even use it on a couch or your bed (clean the bottom first if you decide you must do this).  If you move any objects in its path out of the way, there's no reason this vacuum can't reach room corners.

Let's say, however, you are in fact cleaning the stairs.

![Vacuum_Stairs](http://i.imgur.com/M9SKNDe.jpg)

Using the standard attachment you can accomplish this using the following steps:

- Drag heavy vacuum to the stairs
- Lift up bottom of vacuum
- Place on stair
- Turn heavy vacuum
- Swipe
- Lift up heavy vacuum one more stair
- Turn again
- Try to keep your balance
- Repeat for every stair

Think of the vacuum as your programming language, or if you'd like, your domain.  This particular language is designed to suck in air, pull up dirt and debris, and clean.

Due to it's versatile nature, you can certainly accomplish that result here, on these stairs.  If you had, say, some sort of DSL protocol, you may be able to accomplish this with much less effort.  In fact, look at the picture directly above.  Notice anything?

![Attachments](http://i.imgur.com/fvYBfbCm.jpg)

*Your DSL protocols.*

These attachments are the equivalent of a DSL.  They're designed for a more specific task.  With the small attachment you can:

- Place vacuum (your program) at the bottom the stairs.
- Swipe stair
- Lift light attachment to next stair.
- Swipe again
- Repeat

Your still using your original tool, but you've added a second, more focused and efficient tool as well.

**A DSL protocol is designed to make specific tasks within a domain more efficient.**

___
###About Eureka...
___

Eureka is designed for creating dynamic table view forms in Swift 2, the Apple programming language utilized for XCode, Apple iOS application development platform.  Here it is in action:

*Example 1:*

![Eureka](https://github.com/xmartlabs/Eureka/raw/master/Example/Media/EurekaAlertRow.gif)

*Example 2:*

![Eureka2](https://github.com/xmartlabs/Eureka/raw/master/Example/Media/EurekaLocationRow.gif)

Eureka does for tables in Swift 2 what the stair attachment does for that vacuum cleaner.  In short, **Eureka makes dynamic table creation more efficient**.

___
###How will Eureka benefit end-users?
___

Increased efficiency in code will lead to more applications, faster development times, more features, and less development costs.  *Every* end user benefits form this.
