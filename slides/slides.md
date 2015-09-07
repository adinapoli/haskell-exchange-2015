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
Talk about the company. What we do. Mention the word
"Reflections" (use stats by Chris), which will serve as
a link to the next slide.
}


\centerline{\includegraphics[scale=0.2]{images/iris_logo.png}}

- ~ Present in over 1800 schools Worldwide
  (mostly UK, Europe, US & Australia)

- ~ Used by over 32000 teachers

------------------

# IRIS Connect (contd.)

\note {
I have mentioned the word reflection, and not by chance. A
reflection is a single feedback unit which can be formed by
one of more videos, which are uploaded by the teachers and
that other teachers (when invited) can watch and comment on.
}

\centerline{\includegraphics[scale=0.18]{images/athena.png}}

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

# All I want is a cluster

* ~ It's easy to see that what we want is a **cluster**, capable of scaling on
  demand
* ~ We need to transcode videos, which is a very stateful operation
* ~ A cluster typically implies machines talking to each other, which is
  also very stateful
* ~ **As good Haskell programmers**, we want to have components in our system to
  be **as stateless as possible**, and potentially treat videos as **persistent
  data structures**!

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

# What about data storage?

Fine, but RabbitMQ doesn't give you data persistence...

1. We use AWS' S3 for our storing needs
   + ~ A media key **uniquely identifies** an S3 location (it's like
   an **IP address for videos**!)
2. Upon upload the original file from the user is synced over S3 and
   we call this generation-0 file the **master file**
3. Such master file is **immutable**, and each product we transcode
   generates a brand new binary on S3

\center{\textbf{
We are treating videos as immutable data structures!
}}

------------------

# What about scalability?

Fine, but RabbitMQ doesn't give you scalability...

1. We stood once again on the shoulder of giants - namely AWS' Auto Scaling Groups
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

\centerline{\includegraphics[scale=0.14]{images/pan_cost_june.png}}

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

\begin{center}
Thank you!
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
