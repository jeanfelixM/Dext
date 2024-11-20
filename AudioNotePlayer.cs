using Godot;
using System;
using System.Text.RegularExpressions;

public partial class AudioNotePlayer : Node
{
	private AudioStreamPlayer audioPlayer;
	private AudioStreamGenerator audioStream;
	private AudioStreamGeneratorPlayback playback;
	private float sampleRate = 44100f;

	public override void _Ready()
	{
		// Créer un AudioStreamPlayer et l'ajouter comme enfant
		audioPlayer = new AudioStreamPlayer();
		AddChild(audioPlayer);

		// Configurer l'AudioStreamGenerator
		audioStream = new AudioStreamGenerator();
		audioStream.MixRate = sampleRate;

		audioPlayer.Stream = audioStream;
		audioPlayer.Play();

		playback = audioPlayer.GetStreamPlayback() as AudioStreamGeneratorPlayback;
	}

	public void jouer_note(float frequency)
	{
		// Générer la note avec la fréquence spécifiée
		GenerateTone(frequency, 0.5f); // Durée de 0.5 secondes
	}
	
	public void jouer_note_string(string noteName, float duree)
	{
		float frequency = NoteToFrequency(noteName);
		if (frequency > 0f)
		{
			GD.Print($"jouer_note appelé avec fréquence : {frequency} Hz");
			GenerateTone(frequency, duree);
		}
		else
		{
			GD.PrintErr($"Note invalide : {noteName}");
		}
	}

	public void jouer_accord(string[] notes, float dureeParNote)
	{
		float[] freqs = new float[notes.Length];
		for (int i = 0; i < notes.Length; i++)
		{
			float frequency = NoteToFrequency(notes[i]);
			if (frequency > 0f)
			{
				freqs[i] = frequency;
				GD.Print($"Note {notes[i]} correspond à la fréquence : {frequency} Hz");
			}
			else
			{
				GD.PrintErr($"Note invalide : {notes[i]}");
				freqs[i] = 0f;
			}
		}
        GenerateChords(freqs, dureeParNote);

    }

        public void jouer_note_int(int note, float duree)
	{
		float frequency = GetFrequency(note);
		if (frequency > 0f)
		{
			GD.Print($"jouer_note appelé avec fréquence : {frequency} Hz");
			GenerateTone(frequency, duree);
		}
		else
		{
			GD.PrintErr($"Note invalide : {note}");
		}
	}
	
	private float NoteToFrequency(string noteName)
	{
		// Mapping des notes aux demi-tons par rapport à C
		var noteOffsets = new System.Collections.Generic.Dictionary<string, int>
		{
			{"C", 0},
			{"C#", 1}, {"Db", 1},
			{"D", 2},
			{"D#", 3}, {"Eb", 3},
			{"E", 4},
			{"F", 5},
			{"F#", 6}, {"Gb", 6},
			{"G", 7},
			{"G#", 8}, {"Ab", 8},
			{"A", 9},
			{"A#", 10}, {"Bb", 10},
			{"B", 11}
		};

		// Expression régulière pour extraire la note et l'octave
		var regex = new Regex(@"^([A-Ga-g][#b]?)(-?\d+)$");
		var match = regex.Match(noteName);

		if (match.Success)
		{
			string note = match.Groups[1].Value.ToUpper();
			int octave = int.Parse(match.Groups[2].Value);

			if (noteOffsets.ContainsKey(note))
			{
				int noteOffset = noteOffsets[note];
				// Calculer n, où A4 correspond à n = 49
				int n = (octave + 1) * 12 + noteOffset;
				// Utiliser la formule pour calculer la fréquence
				float freq = GetFrequency(n);
				return freq;
			}
		}

		// Si la note est invalide, retourner 0
		return 0f;
	}

	private float GetFrequency(int n) {
		double frequency = 440.0 * Math.Pow(2, ((n - 49) / 12.0) - 2);
		return (float)frequency;
	}

	private void GenerateTone(float frequency, float duration)
	{
        audioPlayer.Stop();
        audioPlayer.Play();
		playback = audioPlayer.GetStreamPlayback() as AudioStreamGeneratorPlayback;
        int numSamples = (int)(sampleRate * duration);
		float increment = frequency / sampleRate;
		float phase = 0f;

        float time = 0f;
        float deltaTime = 1f / sampleRate;

        for (int i = 0; i < numSamples; i++)
		{
			float sample = GenerateHarmonicSample(phase, time);
			playback.PushFrame(new Vector2(sample, sample));

			phase += increment;
			if (phase >= 1f)
				phase -= 1f;

            time += deltaTime;
           
        }
	}

    private void GenerateChords(float[] freqs, float duration)
    {
        audioPlayer.Stop();
        audioPlayer.Play();

        playback = audioPlayer.GetStreamPlayback() as AudioStreamGeneratorPlayback;

        int numSamples = (int)(sampleRate * duration);

        float[] phases = new float[freqs.Length];
        float[] increments = new float[freqs.Length];
        for (int i = 0; i < freqs.Length; i++)
        {
            increments[i] = freqs[i] / sampleRate;
            phases[i] = 0f; 
        }

        float time = 0f;
        float deltaTime = 1f / sampleRate;

        for (int i = 0; i < numSamples; i++)
        {
            float combinedSample = 0f;

            // Combiner les signaux des différentes fréquences
            for (int j = 0; j < freqs.Length; j++)
            {
                combinedSample += GenerateHarmonicSample(phases[j], time);

                phases[j] += increments[j];
                if (phases[j] >= 1f)
                    phases[j] -= 1f;
            }

            combinedSample /= freqs.Length;
            playback.PushFrame(new Vector2(combinedSample, combinedSample));

            time += deltaTime;
        }
    }


    private float GetADSRAmplitude(float time, float noteOnTime, float noteOffTime,
                       float attackTime, float decayTime, float sustainLevel, float releaseTime)
    {
        float amplitude = 0f;

        if (time < noteOnTime)
        {
            // Avant que la note ne soit déclenchée
            amplitude = 0f;
        }
        else if (time >= noteOnTime && time < noteOnTime + attackTime)
        {
            // Phase d'attaque
            float attackProgress = (time - noteOnTime) / attackTime;
            amplitude = attackProgress;
        }
        else if (time >= noteOnTime + attackTime && time < noteOnTime + attackTime + decayTime)
        {
            // Phase de décroissance
            float decayProgress = (time - (noteOnTime + attackTime)) / decayTime;
            amplitude = 1f - decayProgress * (1f - sustainLevel);
        }
        else if (time >= noteOnTime + attackTime + decayTime && time < noteOffTime)
        {
            // Phase de maintien
            amplitude = sustainLevel;
        }
        else if (time >= noteOffTime && time < noteOffTime + releaseTime)
        {
            // Phase de relâchement
            float releaseProgress = (time - noteOffTime) / releaseTime;
            amplitude = sustainLevel * (1f - releaseProgress);
            
        }
        else
        {
            //GD.PrintErr($"time : {time}");
            // Après la phase de relâchement
            amplitude = 0f;
        }
        
        return Mathf.Clamp(amplitude, 0f, 1f);
    }


    private float GenerateHarmonicSample(float phase, float time)
    {
        // Paramètres de l'enveloppe ADSR
        float attackTime = 0.1f;     
        float decayTime = 0.1f;      
        float sustainLevel = 0.5f;   
        float releaseTime = 0.1f;    

        // Temps de la note
        float noteOnTime = 0.01f;       // La note commence à t = 0
        float noteOffTime = 0.6f;      // La note est relâchée à t = 1s

        // Calcul de l'enveloppe ADSR
        float envelope = GetADSRAmplitude(time, noteOnTime, noteOffTime, attackTime, decayTime, sustainLevel, releaseTime);

        // Génération du signal avec les harmoniques
        float sample = 0f;
        int numHarmonics = 10; // Nombre d'harmoniques à inclure
        float decayFactor = 0.4f;

        for (int n = 1; n <= numHarmonics; n++)
        {
            float amplitude = Mathf.Pow(decayFactor, n - 1) / (n *n);
            sample += amplitude * Mathf.Sin(2f * Mathf.Pi * n *phase);
        }

        sample *= 0.5f*envelope;
        return sample;
    }

}
