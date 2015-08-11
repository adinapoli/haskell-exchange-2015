## Scalable and Reliable Video Transcoding in Haskell

At Iris Connect we are developing a video sharing platform that is
being deployed in over a thousand schools worldwide. As part of this process,
the hundreds of gigabytes of videos uploaded from customers every day are
a central part of our business.

In this talk I will present our approach to video transcoding, and how we are
using Haskell to meet our business needs. I will explain how our distributed
architecture - inspired to FP desirable properties - allows
us to reliably process hundreds of videos every day, dealing with high volume traffic
and scaling at need, whilst keeping costs at bay.
