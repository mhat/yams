Homework
======

Create this somewhat simple rails application.  Create functional code in the most efficient manner and with your best workmanship. Do not worry about how long this takes you; focus on showing us clear logic, best practices and your
methodologies/design patterns – your choice of these is part of the review process. Don't try and future proof the app either.  We're fans of simple, concise code.  Security, as always, is an issue.

Part 1
Architect a rails app that has users, projects, events, and groups. The app has a simple invitation system. Any user can be part of a project, an event, or a group. Users, Projects, events, and groups don't need to contain any information and could just be a primary key (keep things very basic). Come up with a way to model this in the database and in your model. Keep it simple and try to abstract your logic since the method of inviting a user to a (project, event, group) is the same. 

Question: How would the database look if there was a way for users to accept an invite to a group, event, project?

Part 2
Add the ability to send a note along with an invitation (the note is attached to the invitation). Set up some test data for users, projects, events, and groups then create control logic for a user to invite another user to projects, events, and groups. The output of the invite could be as simple as 'user 5 has invited user 1 to project 3 – “this is my test note”' or 'user 2 has invited user 3 to event 1 – “hey join my project”'.

I'm not asking you to create any front ends of views for this at all.  It can be something that one interacts with completely at the script console.   Views take longer than anything else, but are the least important for the work you'll be doing.    If it's easier, feel free, but its not required.

You can use whatever gems or plugins you want.  When you're done send, or put on github the rails app I can run.   Include a readme on the basics of how to use it.


LOL
======
(I put this here to see if Adam had a sense of humor)

Owner: Take this code, but beware it carries a terrible curse!

Homer: [worried] Ooooh, that's bad.

Owner: But it comes with a free Frogurt!

Homer: [relieved] That's good.

Owner: The Frogurt is also cursed.

Homer: [worried] That's bad.

Owner: But you get your choice of topping!

Homer: [relieved] That's good.

Owner: The toppings contains Potassium Benzoate.

Homer: [stares]

Owner: That's bad.
