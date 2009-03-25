# Schema Documentation

# Tables

## Users

Each Users email, screen name, password and a unique id are stored here. The
unique id is used by other tables to reference a specific user. A User may 
have many Events, Groups, Projects and Invites associated with them.


## Events

Each Event has an owner, a flag to indicate if the event is public or private
and a unique id. The Event owner is associated directly to the Users table 
through the column: owner_user An Event may also have any number of member 
Users and Invites associated with it.  Member Users are associated through 
the Events_Users table while Invited Users are associated through Invites. 


## Events_Users

A join table that includes an Event's ID and a User's ID. To make a User a
member of an Event a record is inserted into Events_Users with the Users ID
and the Events ID. From there a simple join can be done to answer questions
like "show me all the members of this event". 


## Groups

Groups behave exactly like Events and Projects. Events, Groups and Projects
while presently similar would tend to be difference in practice. A Event may
have a Location and a Date while a Group would not.


## Groups_Users

A join table, works exactly like Events_Users and Projects_Users.


## Projects

Projects behave exactly like Events and Groups.


## Projects_Users

A join table, works exactly like Events_Users and Groups_Users.


## Invites

Each Invite has a invitee, inviter, note, status and two polymorphic fields
invitable_id, invitable_type used to connect an invite to a Event, Group or
Project. The polymorphic nature does not mesh especially with with database
normalization, for example foreign keys are not possible, but it makes the 
resulting ActiveRecord associations interesting. 

Invite references two Users, the first through invitee_user_id which is the
User that has been sent the invitation. The second through inviter_user_id 
which is the sender. An Invite can also have a short note from the inviter,
presumably the note explains to the invitee why they're being invited.

Finally invites have a status which will typically be one of three values:
0:Pending, 1:Accepted, 2:Ignored.



