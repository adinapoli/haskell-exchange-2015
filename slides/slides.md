---
title:  Scalable and Reliable Video Transcoding in Haskell
author: Alfredo Di Napoli
date:   Haskell Exchange 2015
---

# About me

\note{
Here I show three pictures:
- The missile (with the caption launchMissile :: IO ()
- The Manchester mill
- The Brighton sea
}

\begin{center}
Full story at: \textbf{http://goo.gl/qkKwKm}
\end{center}

\centerline{\includegraphics[scale=0.4]{images/about.png}}

------------------

# IRIS Connect

\note {
Talk about the company. What we do. Include Company logo.
}


\centerline{\includegraphics[scale=0.2]{images/iris_logo.png}}

- Market leader for CPD solutions

- Used by more than 1000 schools across UK, Europe, US & Australia

------------------

# IRIS Connect (contd.)

\note {
Include Athena screenshot
}

------------------

# IRIS' Greek Zoo

\note {
In this quite barebone diagram you can see at glance the components
of our system. At IRIS we have this recurring theme of greek gods &
titans, so we maintained the tradition upon creating more services.
We operate using AWS and its services, most notably EC2 & S3.
In the latter we store all our videos & customer data.
Today I will be telling you the story of Hermes.
}

\vspace{1em}
\centerline{\includegraphics[scale=0.4]{images/greek_zoo.png}}

------------------

# Hermes' evolution

\textbf{October, 2013}
\centerline{\includegraphics[scale=0.3]{images/hermes_before.png}}

\textbf{October, 2015}
\centerline{\includegraphics[scale=0.3]{images/hermes_after.png}}

------------------

# Hermes' challenges

Upon taking the lead on Hermes, I was asked for a couple of
requirements to be fullfilled, the most important one being that
the system needed to be deployed in a cluster, capable of scaling
according to demand.

------------------

# Hermes' challenges

More specifically, we wanted a system with these desirable properties:

* ~ Scalable

* ~ Fault tolerant

* ~ Distributed

------------------

# "Out of the tar pit" docet

\begin{center}
The classical ways to approach the difficulty of state include OOP
programming which tightly couples state together with related behaviour,
and functional programming which — in its pure form — eschews
state and side-effects all together. [..]
We argue that it is possible to take useful ideas from both and that
this approach offers significant potential for simplifying the construction of
large-scale software systems.
\end{center}

In the same fashion, we have 2 different worlds colliding:

* ~ We need to transcode videos, which is a very stateful operation
* ~ As good Haskell programmers, we want to have components in our system to
be as stateless as possible.

------------------

# A shared nothing architecture (SN)

\note{
Transcoded into Distributed jargon, what we want is a Shared Nothing Architecture.
This is a possible definition, as taking from Wikipedia. 
}

\begin{center}
\textit{A shared nothing architecture (SN) is a distributed computing architecture in which each node
is independent and self-sufficient, and there is no single point of contention across the system.}
\end{center}

------------------

\begin{center}
\textit{"All problems in computer science can be solved by another level of indirection."}
  - Butler Lampson
\end{center}

------------------

# RabbitMQ

1. RabbitMQ was just the right tool for the job at hand:
    + ~ Easy to setup
    + ~ Can be configured to operate in a federation of nodes
    + ~ Extremely reliable
    + ~ Good Haskell bindings for it (\textit{AMQP})
2. A question genuinely arise: it seems extremely costly to shuffle video as
binary blobs over the queues. Can we avoid that?

------------------

# Abstraction is the (media key)

\note{
Here I discuss the media key abstraction, aka an IP address for a video resource.
}

``` Bash
root__m-stg-main-2014_10_29_13_27_26-videos-1-2333-vid-smc-oxz8dmdi1lx7fong
    ^    ^   ^        ^                 ^   ^   ^   ^   ^        ^
    |    |   |        |                 |   |   |   |   |        |
comment  |   |        |                 |   |   |   |   |        |
         |   |        |                 |   |   |   |   |        |
host ----+   |        |                 |   |   |   |   |        |
             |        |                 |   |   |   |   |        |
database --- +        |                 |   |   |   |   |        |
                      |                 |   |   |   |   |        |
dataset version ------+                 |   |   |   |   |        |
                                        |   |   |   |   |        |
resource (video or image) --------------+   |   |   |   |        |
                                            |   |   |   |        |
user ID ------------------------------------+   |   |   |        |
                                                |   |   |        |
video ID -------------------------------------- +   |   |        |
                                                    |   |        |
channel type ---------------------------------------+   |        |
                                                        |        |
video products -----------------------------------------+        |
                                                                 |
MAC (avoids submission of bogus keys) ---------------------------+
```

To be fair, the media key abstraction was already present in Atlas when I choose
RabbitMQ, but it was the perfect fit for it!


------------------

# What about scalability?

Fine, but RabbitMQ doesn't give you scalability...

1. We stood on the shoulder of giants - namely AWS' Auto Scaling Groups
2. Our very first native scaling algorith looked like:
    + ~ Scaling up: Based on CPU% over time
    + ~ Scaling down: Based on CPU% over time

It kept us going for a while...

------------------

# The architecture

\centerline{\includegraphics[scale=0.18]{images/hermes_architecture.png}}

------------------

# Reviewing the scaling experience

1. Scaling up was too conservative and slow
    + ~ It could take up to 15 mins to spawn a new worker
2. Scaling down suffered similar problems
3. The result was unoptimal customer experience (due to the
slow turnaround time) and unoptimal for us (due to the additional
costs incurring from poor scaling down)


------------------

# The Elephant in the room

\begin{center}
\textbf{What's the elephant in the room?}
\end{center}

\centerline{\includegraphics[scale=0.6]{images/elephant.jpg}}

------------------

\begin{center}
\textbf{\huge{Why not use Cloud Haskell?}}
\end{center}

\note {
Discuss why we do have not used CH.
}

------------------

# Why not Cloud Haskell

1. CH encourages Erlang-style (i.e. actor based) communication, so nodes
should know each other
 - We do not want that!
2. Peer discovery would have been tricky in a dynamic environment where
new machines born and die frequently

3. It wasn't mature enough in 2013, if not for a handful of companies
using it


------------------

# Iris Connect's story

\centerline{\includegraphics[scale=0.3]{images/iris_logo.png}}

&nbsp;

A sharing and collaboration CPD platform for teachers via
   video recording, feedback and introspection.

------------------

&nbsp;

1. Initially build with RoR, it was rewritten from
   scratch in Haskell (backend) and RoR + Angular.js (frontend)
    a. Effort initially started by my colleage Chris Dornan and
       Well Typed

&nbsp;

2. The backend is composed by two main projects:
    a. The frontend-facing API server which holds the model and
       the business logic (**Atlas**)
    b. The video transcoding system (**Hermes**), a highly
       distributed and fault tolerant system, built on top of
       RabbitMQ.

------------------

# Why Haskell?

\centerline{\includegraphics[scale=0.4]{images/marathon.jpg}}

- Because software development is a marathon, not a sprint.

\note{
In my opinion, interpreted languages are great for prototyping,
because you can just express your ideas without worrying too
much about setting a build environment or that the compiler
will reject your program. But I truly believe that if you
want to build a software that will need to last for the next
10 years, that it will need to be scalable and extensible,
that I think a "functional approach" is the only way to
tame complexity.
}

------------------

\center{
  \textit{
  "It took me more time writing the specs that implementing
  the feature itself."
  }
}


\note{
This sentence was told from one of our Ruby programmers during
a standup, and I think it synthesize perfectly the message.
By having a strong type system, Haskell allow us to write the
business logic code AND its tests, without obsessively writing
specs that just emulate what a compiler does for you: caching
silly mistakes. For a business this is a great way to cut the
time to market.
}

------------------

\centerline{\includegraphics[scale=0.4]{images/painter.jpg}}

\center{
  Because we are like Shlemiel the painter.
}

------------------

\center{
  \textbf{
   "I can't help it," says Shlemiel. "Every day I get farther and farther away from the paint can!"
  }
}

\note{
   Shlemiel gets a job as a street painter, painting the dotted lines down the middle of the road.
   On the first day he takes a can of paint out to the road and finishes 300 yards of the road.
   "That's pretty good!" says his boss, "you're a fast worker!".
   The next day Shlemiel only gets 150 yards done. "Well, that's not nearly as good as yesterday,
   but you're still a fast worker."
   The next day Shlemiel paints 30 yards of the road. "Only 30!" shouts his boss.
   "That's unacceptable! On the first day you did ten times that much work! What's going on?"
}

------------------

1. The more time it pass, the farther we get from our "paint can", the mental model we built
   of the system.

2. In large scale systems, you can have parts that won't be touched for *years*!
    a. How do you defend yourself when the refactoring or feature time comes?

3. A rich, strong and expressive type system can be your ultimate ally against complexity
    a. Things like `newtype`s and `ADT`s can help you cure common "diseases" like
       _Boolean Blindness_

\center{
 \textbf {
   As universe expands, so does the entropy in your software: use types to keep it at bay!
 }
}

------------------

# Some "Pros" of working in Haskell

1. Refactoring is a dream
2. EDSLs are a piece of cake
3. Makes impossible states unrepresentable

------------------

# Refactoring is a dream

1. The type system naturally guides you
2. In Haskell we tend to write small and generic functions
    a. Cfr. Bob Martin's "Clean Code"
    b. Most of the time they don't even break as they are
       written to work on polimorphic types
    c. Code reuse = profit!

So ultimately is not just about the strong type system, is about
Haskell's (and Haskellers) natural tendency towards **composition**
and **parametricity**.

\note{
Say is not JUST the type system, is about composition and parametricity.
Lots of small, generic functions. But also that Haskellers like to
decompose everything.
}

------------------

# EDSLs are a piece of cake

``` haskell
fromPreset :: MediaFile -> MediaFile
           -> Maybe Atlas.VideoFilter
           -> VideoPreset -> Maybe VideoRotation
           -> LogLevel -> [T.Text]
fromPreset filename outFilePath flt vpres vi ll =
  let cli = ffmpegCLI $ mconcat [
              i $ toTextIgnore filename
            , loglevel ll
            , fromVideoPreset vpres
            , isVideoRotated vi <?> resetRotateMetadata
            , yuv420p
            , vf [rotateMb vi]
            , isJust flt <?> vf_technicolor
            , o_y_ext (toTextIgnore outFilePath) (Left vpres)
            ]
  in T.words cli
```

------------------

# Makes impossible states unrepresentable

Real world scenario:

``` haskell
-- | Creates a new Supervisor.
-- Maintains a map <ThreadId, ChildSpec>
newSupervisor :: IO Supervisor

-- | Start an async thread to supervise its children
supervise :: Supervisor -> IO ()

-- | forkIO-inspired function
forkSupervised :: Supervisor
               -> RestartStrategy
               -> IO ()
               -> IO ThreadId
```

------------------

Example usage:

``` haskell
main = do
  sup <- newSupervisor
  supervise sup
  _ <- forkSupervised sup OneForOne $ do
         threadDelay 1000000
         print "Done"
```

Can you spot a potential bug?

------------------

**Nothing in the types is forcing us to call `supervise` before actually
supervising some thread!
**

``` haskell
main = do
  sup <- newSupervisor
  -- Wrong! We forgot to start the supervisor...
  _ <- forkSupervised sup OneForOne $ do
         threadDelay 1000000
         print "Done"
```

As Haskellers, we can certainly do better!

------------------

# Phantom Types to the rescue!

Phantom Types allow us to "embed" constrain on our
types, together with smart constructors.

``` haskell
data Uninitialised
data Initialised

data Supervisor_ a = Supervisor_ {
      -- record fields (omitted)
      }

type SupervisorSpec = Supervisor_ Uninitialised
type Supervisor = Supervisor_ Initialised
```

------------------

Let's now slightly change our API to be this:

&nbsp;

``` haskell
-- | Creates a new Supervisor.
newSupervisor :: IO SupervisorSpec

-- | Start an async thread to supervise its children
supervise :: SupervisorSpec -> IO Supervisor
```

------------------

&nbsp;

What did we get? Let's try to run the "wrong"
snippet again...

&nbsp;

``` haskell
main = do
  sup <- newSupervisor
  _ <- forkSupervised sup OneForOne $ do
         threadDelay 1000000
         print "Done"
```
&nbsp;

. . .

GHC will complain:

&nbsp;

``` haskell
Couldn't match type Control.Concurrent.Supervisor.Uninitialised
         with Control.Concurrent.Supervisor.Initialised
Expected type: Supervisor
Actual type: Control.Concurrent.Supervisor.SupervisorSpec
```

------------------

1. This is because now we require a `Supervisor` to be initialised first
2. The type system prevented us making a silly mistake
    a. Failed with a very useful error message
3. Profit!

This is just a small example (this is only one of the possible solutions),
but the benefits are real.

&nbsp;

[https://github.com/adinapoli/threads-supervisor](https://github.com/adinapoli/threads-supervisor)

\note{
Funny fact: after this change, I spotted a bug in one of my tests!
}

------------------

# Snags of working in Haskell

1. Slow(ish) Compilation
2. Cabal Hell

------------------

# Slow(ish) compilation

\centerline{\includegraphics[scale=0.5]{images/compiling.png}}

------------------

# Slow compilation: the caveat

1. It's a problem all non-interpreted languages have to deal with
2. GHC indeed does incremental compilation, building only what's changed
3. It's even slower if..
    a. You have TH (Template Haskell) in your code
    b. You are building with profiling enabled

\center{
  \textbf {
  If you want faster feedback loop, consider using ghci
  }
}

------------------

# Cabal Hell

It's the aggregate of more than one problem, which most of the time results
in "I couldn't install package X (easily)"

&nbsp;

\begin{figure}[h!]
\centering
  \includegraphics[scale=0.5]{images/hell.png}
  \caption{\scriptsize Image courtesy of Well Typed Ltd}
\end{figure}

------------------

# Cabal Hell - the silver linings

1. Sandboxes mitigate the issue

```
cabal sandbox init
cabal install
```

2. "Package aggregates" can help
    - Stackage
    - HaskellLTS
    - Nix and NixOS


3. Broader solutions are in the pipeline
    - Edward Z. Yang's "Backpack"


------------------

\begin{center}
Thank you.
\end{center}

------------------

\begin{center}
Questions?
\end{center}

------------------

# External references

* **My road to Haskell**
  http://www.alfredodinapoli.com/posts/2014-04-27-my-road-to-haskell.html
* **Don Stewart - Haskell in the large**
  http://code.haskell.org/~dons/talks/dons-google-2015-01-27.pdf
* **Joel Spolsky - Back to Basics**
  http://www.joelonsoftware.com/articles/fog0000000319.html
