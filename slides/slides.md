---
title: Real World Cloud Computing with Haskell
author: Alfredo Di Napoli
---

# Quoting Steve Jobs..

\note{
  Hello everyone, and thanks for coming. We have
  a pretty thight schedule, but I'm trying to leave
  15 mins for Q&A. If you have question during the
  talk though, do not hesitate to interrupt me, as
  we'll take time from the final Q&A section.
}


Today, I'm gonna tell you three stories.

&nbsp;

\centerline{\includegraphics[scale=0.4]{images/steve.jpg}}

1. My story
2. My company story
3. Your story

\note{
 So, quoting Steve Jobs, today I'm gonna tell you three
 stories:
 - My story, or how I went to be an hobbyst to a
 professionally employed Haskell programmer in
 less than 2 years, sharing my experience on
 what worked (and what not).
 - The story of Iris Connect, the company I work for,
 telling you why we choose Haskell, the pro (and snags)
 of using it in production and overall show that it's a
 pragmatic programming language which can be used
 to solve real-world problems
 - The final one will be about you, but we'll get to that.
}


------------------

# Mid 2012

&nbsp;

\centerline{\includegraphics[scale=0.3]{images/meteor.jpg}}

&nbsp;

I started an internship with a company in the defense field, doing C++
in Rome. To hone my Haskell skills I tried to contribute to an Haskell
open source project, the [Snap](http://www.snapframework.com)
framework.

\note{
I knew that to get really proficient with a language there is no
better training ground that an open source project. I was lucky
enough to be mentored by Doug Beardsley, one of Snap's lead
engineers.
}

------------------

# Mid 2012 (contd.)

Being determined in earning a living with functional programming, I decided to
concentrate my efforts only on three languages, based on different criteria
(commercial users, personal preference, job offers abroad):

- Haskell
- OCaml
- Scala

\note {
And it was the last one, Scala, my kickstart to the FP job industry.
I sent the CV to a UK company in Manchester called Cake Solutions,
and after the usual interview dance I was on-board! So I resigned
from my internship, bought a one-way ticket to Manchester 2 weeks
from there, and prepared for the biggest leap into the dark of
my entire life.
}

------------------

# The Manchester era

\centerline{\includegraphics[scale=0.07]{images/cake_mill.jpg}}

\center {
  \textit{
    Scala programmer during the day, Haskell coder at night.
  }
}

\note {
When in Manchester, I was writing Scala for living but kept
spending my gloomy Mancunians evenings writing Haskell, the
language I wanted to use.
}

------------------

&nbsp;

\centerline{\includegraphics[scale=0.5]{images/smatters.png}}

&nbsp;

\centerline{\includegraphics[scale=0.5]{images/wt.png}}

\note {
Talk about the fact I met people from Well Typed, together with
Andres Loh, which later would remember me.
}

------------------

* After a couple of months (it was July 2013) Well Typed was
  hiring. I decided to take pot luck and I applied.
* To maximise my chances, I applied to a couple of other
  positions for Haskell jobs.
* Despite the rejections, **I was actually able to face an
  entire interview doing nothing but Haskell!**

\note {
Say this was an important turning point, where I switched from
an hobbyst to a professional applying for a job.
}

------------------

# August 2013, Vieste - Italy

\centerline{\includegraphics[scale=0.2]{images/vieste.jpg}}

\center {
Got rejected by WT, but they said "A client of us might be
searching soon..."
}

------------------

# Landing the tech job I loved

\centerline{\includegraphics[scale=0.06]{images/interview.jpg}}

On the 29th of August, I applied for a Haskell job @ Iris Connect.
Took a train to Brigthon, did the interview and was offered
the position. **I was officially an Haskeller!**

------------------

# Takehome lessons


1. Don't be afraid to take leaps into the dark
2. Life is about opportunities, seize them
3. Try to contribute to a "famous" Haskell OSS
4. Constantly "sharpen your saw"
5. Be receptive, do networking

\note{
Don't be afraid to take leaps into the dark: I turned down a job offer in the safe harbor of my home city for something totally new and scary. If I didn’t do that, today I probably wouldn’t be an Haskell programmer.

Life is about opportunities, seize them: Think about what would have happened if I was too shy to ask Cake Solutions about Skills Matter's courses. They would have never payed for the course, I would have never met Andres and probably never applied to WT. Duncan would have probably not even considered referring me to Iris.

Try to contribute to a "famous" Haskell OSS: I was able to land this job also because I had experience with web dev in Haskell. But I had experience mostly because I contributed to Snap. There is a substantial difference to say "I have used Snap", as opposed as "I used Snap and I have implemented feature X".

Constantly sharpen your saw: If I felt "realised", today I would still be working in Manchester. The burning desire I had to work as a professional Haskell dev caused me to spend my spare time programming and studying.

Be receptive, do networking: Having a strong network is vital. Try to actively contribute to the community, let other Haskeller know you. Let them think "I have already heard about John Doe". Even if just an handfull will do, you won't be a total stranger but someone into the community. I think this is the best thing which can happen to an Haskeller.
}

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
