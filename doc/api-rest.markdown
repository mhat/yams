# YAMS REST API

## Users

There are two resources available, the first provides a searchable directory
of Users and the second reveals details about the current user.

    GET /users
    parameters
      required _query_ 
      
      returns a array of users
    
    GET /users/me
    parameters
      none
      
      returns the current user 

## Joinable [Events, Groups and Projects]

Note: The examples here use /joinable for simplicity, in practice you will
have to use one of /events, /groups or /projects. I'm using /joinable just
to avoid writing the same documentation three times. Think of /joinable as
an interface that /events, /groups and /projects each implement.

    GET /_joinable_
    parameters
      none
      
      returns an array with each _joinable_ owned by the current_user and
      any public _joinables_. Presently no query operations are supported
      because _joinables_ do not have a description field or really any 
      field to query. :|
    
    
    GET /_joinable_/<_joinable__id>
    parameters
      required _joinable_id_ must be part of the URI.
      
      returns a detailed information about the requested _joinable_ and its
      members provided that the current_user ownes, is a member of, has an 
      invite to the _joinable_ or if the _joinable_ is public.
    
    
    POST /_joinable_
    parameters
      none
      
      creates and returns the newly created event.
      
    DELETE /_joinable_/_joinable_id_
    parameters
      required _joinable_id_ must be part of the URI
      required __method_=DELETE unless your client supports HTTP DELETE.
      
      deletes the _joinable_ and members.
    

## Events

See above:Joinable

  
## Groups

See above:Joinable


## Projects

See above:Joinable


## Memberships

  GET /memberships
  parameters
    optional _type[]_ one of event, group or project
  
  returns an array enumerating the current_users memberships, that is each
  event, group and project they are a member of. By passing in one or more
  type[] parameter (e.g. type[]=event&type[]=group) the result set can be
  fine tuned.
  
  
  POST /memberships
  parameters
    required _type_ one of event, group or project
    required _id_   the id of the event, group or project
  
  allows the current user to join any public _joinable_. 
  
  DELETE /memberships
  parameters
    required _id_ the id of the event, group or project, must be in the URI,
                  this is a bug
    required _type_ the type, one of event, group or project
    required _member_id_ the id of the user to remove
    required __method_=DELETE unless your client supports HTTP DELETE.
    
    usage one:
    the current_user may remove themselves from any _joinable_ they are a 
    member of by passing their _user_id_ as _member_id_ as well as the 
    _joinable_ identifier. 
    
    usage two:
    the current_user may remove ANY user from a _joinable_ provided they are
    the owner of that _joinable_. for example, if i am the owner of a project
    i can remove any user from that project. i can not, however remove users
    from a project I do not own.
    
  
## Invites
  
  GET /invites
  parameters
    optional _kind[]_ zero or more of sent, or received
    optional _type[]_ zero or more of event, group, or project
    optional _status[]_ zero one or more of pending, accepted, or ignored
  
  return an array of invites meeting the search criteria
  
  
  GET /invites/_<invite_id_>_
  parameters
    required _invite_id_ must be part of the URI
    
    returns the requested invite, not especially useful but hey, who am I
    to judge. 
  
  
  POST /invites
  parameters
    required _invitee_user_id_ user_id of the user to send the invite to
    required _invitable_type_ one of event, group, or project
    required _invitable_id_ the id of the event, group or project
    optional _note_ a short note, to be friendly
    
    creates and sends an invite from the current_user to the invitee to some
    _joinable_ with a friendly note, or not, if you're not friendly.
  
  PUT /invites/_<invite_id>_
    required _invite_id_ must be part of the URI
    required _status_ must be one of ignored or accepted
    required __method_=PUT unless your client supports HTTP PUT
    
    accept or ignore the invite, accepting automatically adds the current_user
    to the _joinable_. ignore does the inverse if necessary.
  
  DELETE /invites/_invite_id_
    required _invite_id_ must be part of the URI
    required __method_=DELETE unless your client supports HTTP DELETE.
    
    current_user may delete any invitation they have sent.
