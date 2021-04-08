# What is DNS

## Server has ip address 1.2.3.4

## Humans prefer readable names

## DNS translates name -> ip address
* DNS is a distributed system with large number of servers belonging to different companies/entities
* These servers talk to one another, and the is no singe source of truth
* A server in the DNS system only know a piece of information which it is responsible for,
  and it keeps pointers to other parts of the system which have further information 


## Resolver - When you hit a URL like www.example.com
Request goes to the resolver which is generally provided by your Internet Service Provider.  

## Root Domain Server
1) It knows about mappings of the root domain i.e. last parts of the domain like ".com", ".ca", ".io" etc.


