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
This is a possible definition, as taken from Wikipedia.
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

# Abstraction is the (media) key

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

# The architecture

\centerline{\includegraphics[scale=0.18]{images/hermes_architecture.png}}

------------------

# What about data storage?

Fine, but RabbitMQ doesn't give you data storage...

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

# The importance of being immutable

\center{
Easy concurrency and parallelism!
}

\centerline{\includegraphics[scale=0.36]{images/video_products.png}}

------------------

# What about scalability?

Fine, but RabbitMQ doesn't give you scalability...

1. We stood once again on the shoulder of giants - namely AWS' Auto Scaling Groups
2. Our very first naive scaling algorithm used AWS' builtin alarms and looked like:
    + ~ Scaling up: Based on CPU% over time
    + ~ Scaling down: Based on CPU% over time

It kept us going for a while...

------------------

# Reviewing the scaling experience

1. Scaling up was too conservative and slow
    + ~ It could take up to 15 mins to spawn a new worker
2. Scaling down suffered similar problems
3. The result was suboptimal for customers (due to the
slow turnaround time) and suboptimal for us (due to the additional
costs incurring from poor scaling down)

------------------

# Scaling up, revisited

* •Scaling up is easy: all we care about is the total number of
    jobs in RabbitMQ's **Ready** state;
    + ~ In RMQ jargon those are jobs waiting for a "transcoding slot"

\centerline{\includegraphics[scale=0.5]{images/rabbit.png}}

* •We periodically monitor those figures and kick off a "ScaleUP" action
    whenever `ready_jobs >= 0`
    + ~ AWS's ASG allows us to put an upper bound to the total number of
      spawnable machines, to keep costs at bay.

------------------

# Scaling down

1. More interesting is the scaling down. Ideally we want to kill a
   worker if the following is true:
    + ~ That worker didn't receive any new jobs within a  `starvation_time` period (say, 5 minutes)
2. At the same time, we would like to optimise the time it stays around
3. Last but not least, it needs to commit suicide alone (I know it sounds sad..), taking a
   local decision, as it doesn't know its peers (SN architecture - remember?)

------------------

# Scaling down - The Reaper

``` haskell
type HeartBeat = TBQueue ()
type Toggle = TMVar ()
type PoisonFlask = TMVar ()

data Reaper = Reaper {
    _rr_timeout :: Maybe Int
  -- ^ The timeout to use for this `Reaper`. Setting this to
  -- Nothing means no timeout at all. This is useful for those transcoders
  -- not associated with jobs (e.g. dual-view, discovery-kit, notifications,..)
  , _rr_reapCondition :: IO Bool
  -- ^ If True, will trigger the reaping. If False, the Reaper will be
  -- permissive.
  , _rr_reapAction :: IO ()
  , _rr_heartbeat :: HeartBeat
  , _rr_toggle :: Toggle
  -- ^ When filled, inform the listeners they can carry on with their
  -- activities (i.e. fetch another job from the queue)
  , _rr_poisonFlask :: PoisonFlask
  }
```

------------------

# Scaling down - Reaper timeout

```
data ReaperPoisoned = ReaperPoisoned ()
type ReaperResponse = Either ReaperPoisoned (Maybe ())

-- | peek the next value from a TBQueue or timeout
peekTBQueueTimeout :: Maybe Int
                   -> HeartBeat
                   -> PoisonFlask
                   -> IO ReaperResponse
peekTBQueueTimeout Nothing heartbeat fsk =
    atomically $ Right . Just <$> peekTBQueue heartbeat <|>
                 Left  . ReaperPoisoned <$> takeTMVar fsk
peekTBQueueTimeout (Just timeoutAfter) heartbeat fsk = do
  delay <- registerDelay timeoutAfter
  atomically $ (Right . Just <$> peekTBQueue heartbeat) <|>
               (pure (Right Nothing) <* untilTimeout delay) <|>
               (Left . ReaperPoisoned <$> takeTMVar fsk)
```

\note{
In case someone asks why using `peek` and not doing the `read`,
say that reason being the value will be read by transcoders job,
in a sort of token-fashion.
}

------------------

# Scaling down, STM to the rescue

``` haskell
reap :: Reaper -> IO ReaperResponse
reap (Reaper t cond _ hb tgl pp) = do
  r <- peekTBQueueTimeout t hb pp
  case r of
    Left _ -> return r -- If we have been poisoned, honour the poisoning and die.
    v@(Right Nothing) -> do
      condT <- cond
      -- If the reaping condition is True, we need to die.
      -- If not, we simulate a state toggle to induce listeners to unlock
      -- and wait for the next batch of events.
      if condT then return v else toggle tgl >> return (Right $ Just ())
    Right s -> return . Right $ s
```

``` haskell
instance Alternative STM where
  empty = retry
  (<|>) = orElse

-- orElse: Compose two alternative STM actions. If the first action completes
-- without retrying then it forms the result of the orElse.
-- Otherwise, if the first action retries, then the second action is tried
-- in its place. If both actions retry then the orElse as a whole retries.
```

------------------

# Scaling down, a typical Transcoder

```haskell
newtype Transcoder a = Transcoder { transcode :: StateT TranscoderState IO a }
  deriving (MonadState TranscoderState, Monad, Functor, Applicative, MonadIO)
```

```haskell
transcoder :: Transcoder ()
transcoder = do
  ctx@TranscoderCtx{..} <- getContext
  newTranscoder $ \_ hb tgl -> NewRabbitConsumer <$> do
    consumeTranscodingJobsIO _tr_channelConfig $ \(msg, env) -> void $ forkIO $
      withIncomingPacket msg $
      \job@(PendingJob key HermesOptions{..} _ (RetryWindow _ _)) -> do
        sendHeartBeat hb -- puts a 'token' into the heartbeat queue
        -- Do here transcoding stuff...
        signalDone hb -- reads from the heartbeat queue
        toggle tgl    -- puts a token (unit) inside the toggle
```

```haskell
newTranscoder :: (PoisonFlask -> HeartBeat -> Toggle -> IO NonBlockingAction)
              -> Transcoder ()
```

The purpose of that `NonBlockingAction` type will be clear soon.

\note{
Also say that due to the fact transcoders are just a State monad in disguise,
we can have different transcoders, with different behaviours, listening on
different queues.
}

------------------

# Scaling down, first results

* •When we deployed the code, we didn't find a sensible difference in costs...
* •... reason being Amazon doesn't bill you for fractional hours
    + ~ Even if you spawn a machine 5 mins, you are billed the full hour!
* •We needed workers to stay around as much as possible, maximising their
    billing hour, without crossing the next-hour mark, if possible!

------------------

# RabbitMQ Consumer Priorities

\center {\textit{
"Consumer priorities allow you to ensure that high priority consumers receive messages
while they are active, with messages only going to lower priority consumers when the
high priority consumers block."
}}

------------------

# RabbitMQ Consumer Priorities (cntd.)

\centerline{\includegraphics[scale=0.8]{images/consumer_priorities.png}}

* •Each worker can transcode 1 job at time, before "blocking"

* •The priority is set to be `60 - (uptime % 60)`

* •A newly spawned machine gets max priority

* •A machine close enough to the next billing hours (e.g. priority <= 10)
  **if starving**, gets evicted!

------------------

# RabbitMQ Consumer Priorities (cntd.)

* •A consumer priority cannot be updated dynamically

* •The easiest way we found was - after a successful heartbeat - to simply cancel the old consumer
  and create a new one, with updated priority

``` haskell
data NonBlockingAction = VoidAction ()
                       | NewRabbitConsumer ConsumerTag
```

* •We used the `ConsumerTag` returned by `NewRabbitConsumer` to cancel
  the old one, compute the updated priority and start a new transcoder

------------------

# Putting everything together

``` haskell
newTranscoderState :: HeartBeat
                   -> TranscoderType
                   -> TranscoderCtx
                   -> IO TranscoderState
newTranscoderState hb ttype tctx = do
  let config = tctx ^. tr_config
  pp <- newPoisonFlask
  rpr <- case ttype of
    JobTranscoder (Production _) ->
      newReaper pp hb (Just twoMinutes) closeToNextBillingHour (reapFromAWS config)
    JobTranscoder Devel ->
      newReaper pp hb (Just oneMinute) (return True) reapLocally
    JobTranscoder _     ->
      newReaper pp hb Nothing (return True) (return ())
    AuxiliaryTranscoder ->
      newReaper pp hb Nothing (return True) (return ())
  return TranscoderState {
           _ts_transitions = singleton 50 WaitingForJob
         , _ts_poisonFlask = pp
         , _ts_reaper = rpr
         , _ts_ctx    = tctx
         }
```

------------------

# The new scaling algorithm: results

\centerline{\includegraphics[scale=0.34]{images/ec2_costs_june.png}}

------------------

\centerline{\includegraphics[scale=0.34]{images/ec2_costs_sep.png}}

\center{\textbf{
We shaved almost 50\% of the costs!
}}

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
