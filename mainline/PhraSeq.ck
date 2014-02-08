/*
    Copyright (c) 2014 Nuclear Heart Games

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

///
///@brief   Phrase Sequencer. Facilitates synchronization and
///         SndBuf rate adjustment, to a given tempo, and the
///         tracking of beats.
///
public class    PhraSeq
{
    static int  _signature;
    static dur  _beat;

    static int  _isStarted;
    static int  _numBeats;
    static time _start;
    
    ///
    ///@return  The signature - number of beats in a bar.
    ///
    fun static int signature()
    {
        return _signature;
    }
    
    ///
    ///@return  The length of a beat.
    ///
    fun static dur beat()
    {
        return _beat;
    }
    
    ///
    ///@return  The lenght of bar - signature times beat. 
    ///
    fun static dur bar()
    {
        return _beat * _signature;
    }
    
    ///
    ///@brief Sets the tempo to @a sig beats of duration @b
    ///
    fun static void setTempo(int sig, dur b)
    {
        sig => _signature;
        b => _beat;
    }
    
    ///
    ///@brief Sets the tempo based on the lenght and rate of
    /// the sample @a buf.
    ///
    fun static void setTempo(SndBuf @ buf, int sig)
    {
        sig => _signature;
        buf.length() * buf.rate() * sig => _beat;
    }
    
    ///
    ///@brief   Lapses time till the next beat.
    ///@note    It's more than enough to do this once
    ///         before the start of your phrase.
    ///
    fun static void syncBeat()
    {
        _beat - ((now - _start) % _beat) => now;
    }

    ///
    ///@brief   Lapses time till the next bar.    
    ///@note    It's more than enough to do this once
    ///         before the start of your phrase.
    ///
    fun static void syncBar()
    {
        bar() => dur b;
        b - ((now - _start) % b) => now;
    }
    
    ///
    ///@brief   Lapses time till the next beat.
    ///@note    It's more than enough to do this once
    ///         before the start of your phrase.
    ///
    fun static void syncBeats(float n)
    {
        beat() * n => dur beats;
        beats - ((now - _start) % beats) => now;
    }

    ///
    ///@brief   Lapses time till the next @a numBars bar.    
    ///@note    It's more than enough to do this once
    ///         before the start of your phrase.
    ///
    fun static void syncBars(float n)
    {
        bar() * n => dur b;
        b - ((now - _start) % b) => now;
    }
    
    ///
    ///@return  The amount to scale the rate of a sample
    ///         of length @a t to make it match the beat.
    ///
    fun static float calculateBeatRatio(dur t)
    {
        return t / _beat;
    }
    
    ///
    ///@return  The amount to scale the rate of a sample
    ///         of length @a t to make it match the bar.
    ///
    fun static float calculateBarRate(dur t)
    {
        return t / bar();
    }
    
    ///
    ///@return  Starts PhraSeq and the tick updates. The number
    ///         of numBeats are reset beforehand.
    ///@note    You'll want to dedicate a shred to doing this.
    ///
    fun static void start()
    {
        1 => _isStarted;
        0 => _numBeats;
        now => _start;
        while(_isStarted)
        {
            beat() => now;
            ++_numBeats;
        }
    }
    
    ///
    ///@return  The number of beats since the last start()
    ///         of PhraSeq.
    ///
    fun static int numBeats()
    {
        return _numBeats;
    }
    
    ///
    ///@return  The number of bars since the last start()
    ///         of PhraSeq.
    ///
    fun static int numBars()
    {
        return _numBeats / _signature;
    }
    
    ///
    ///@brief   Stops PhraSeq and the beat updates.
    ///
    fun static void stop()
    {
        0 => _isStarted;
    }
}
