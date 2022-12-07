# BR41N.IO Hackathon: Decoding hand movement from ECoG data
The following project is part of the BR41N.IO Hackathon organized by Gtec medical engineering during the BCI & Neurotechnology Spring School. 
In this project, the idea is to decode rest, rock, paper and scissors using ECoG data from an epileptic subject.

# Paradigm
90 trials of rock-paper-scissors gestures following a cue on a presentation screen. 
The gesture cue, a photograph of a rock, paper or scissors gesture, was presented for 2s, followed by a black screen for 2-3s.
The subjects were instructed to form the requested gesture with their hand once the stimulus appeared, and to return into a relaxed hand position once the distractor showed up.

The data matrix description (channel x time) is as follows: 

* CH1: sample time 
* CH2-61: ECoG (raw and DC-coupled; recorded from right sensorimotor cortex) 
* CH62: paradigm info (0...relax, 1...fist movement, 2...peace movement, 3...open hand) 
* CH63: data glove thumb 
* CH64: data glove index 
* CH65: data glove middle CH66: data glove ring 
* CH67: data glove little

The following figure shows the position of the electrodes.
<p align="center">
    <img width="400" src="https://github.com/MariaGoniIba/BR41N.IO-Hackathon-ECoG-Epilepsy/blob/main/Electrodes.png">
</p>

The aim is to distinguish between all possible 4 moves using the ECoG recordings.

# Steps

## Preprocessing
Data was CAR (common average reference) filtered to eliminate common mode interference, such as line noise and prevent from leaking noise from noisy channels. 
Second, a notch-filtered cascade was applied to notch out integer multiples of the power line frequency (50 Hz).
Third, data was band-pass filtered between 50 and 300 Hz. 
Filter response was evaluated for different filter order and transition width values to choose the best parameters.

<p align="center">
    <img width="600" src="https://github.com/MariaGoniIba/BR41N.IO-Hackathon-ECoG-Epilepsy/blob/main/Filter.png">
</p>

## Trial and feature extraction
During the trials extraction, 1 second was considered starting at 1 second after the stimulus.

3 features were extracted, including the log power of the frequency bands 60-90 Hz, 110-140 Hz and 160-190 Hz.

## Classification
Two classification paradigms were considered:
* Classification 1: rest vs hand movement.
* Classification 2: fist vs peace vs open hand.

A random forest with 10 fold cross-validation process was applied.

# Results
<p align="center">
    <img width="1000" src="https://github.com/MariaGoniIba/BR41N.IO-Hackathon-ECoG-Epilepsy/blob/main/Results.png">
</p>

# Papers
* [Time-Variant Linear Discriminant Analysis Improves Hand Gesture and Finger Movement Decoding for Invasive Brain-Computer Interfaces](https://www.frontiersin.org/articles/10.3389/fnins.2019.00901/full)
