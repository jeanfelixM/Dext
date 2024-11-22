import uuid
from music21 import converter, note, chord
import json


def extract_notes_and_chords_with_octave(file_path):
    # Charger le fichier MIDI
    midi_stream = converter.parse(file_path)
    midi_stream = midi_stream.flatten() # Aplatir la partition pour avoir toutes les mains
    
    # Dictionnaire pour regrouper les notes/accords par offset
    notes_grouped_by_offset = {}
    
    # Parcourir tous les éléments de la partition flattn
    for element in midi_stream:
        if isinstance(element, note.Note):  # Si c'est une note simple
            offset = element.offset
            note_name = f"{element.nameWithOctave}"
            if offset not in notes_grouped_by_offset:
                notes_grouped_by_offset[offset] = []  # Créer une liste pour cet offset si elle n'existe pas
            notes_grouped_by_offset[offset].append(note_name)  # Ajouter le nom de la note
        elif isinstance(element, chord.Chord):  # Si c'est un accord
            chord_notes = [f"{n.nameWithOctave}" for n in element.notes]
            offset = element.offset
            if offset not in notes_grouped_by_offset:
                notes_grouped_by_offset[offset] = []  # Créer une liste pour cet offset si elle n'existe pas
            notes_grouped_by_offset[offset].extend(chord_notes)  # Ajouter toutes les notes de l'accord

    # Convertir le dictionnaire en une liste ordonnée par offset
    notes_array = [notes for _, notes in sorted(notes_grouped_by_offset.items())]
    return notes_array

def create_level_dataf(file_path, output_file,duration, level_id, name, rayon, mode, keys):
    # Extraire les notes du fichier MIDI
    notes_array = extract_notes_and_chords_with_octave(file_path)

    #generate unique level id now who need to be an INT
    if level_id is None:
        level_id = int(uuid.uuid4().int & (1<<31)-1)


    if keys is None:
        keys = ['A','Z','E','R','Q']
    if rayon is None:
        rayon = 50
    if mode is None:
        mode = 3
    if duration is None:
        duration = 30
    if name is None:
        #taking name of the midi file path
        name = file_path.split('/')[-1].split('.')[0]
    # Créer le dictionnaire de données du niveau
    level_data = {
        "id": level_id,
        "name": name,
        "rayon": rayon,
        "mode": mode,
        "duration": duration,
        "keys": keys,
        "notes": notes_array[0:180]
    }

    # Écrire le dictionnaire dans un fichier JSON
    with open(output_file, 'w') as f:
        json.dump(level_data, f, indent=4)
    print(f"Le fichier {output_file} a été créé avec succès.")
    return notes_array

def create_level_data(file_path, output_file,duration):
    return create_level_dataf(file_path, output_file,duration, None, None, None, None, None)

midi_file = "dadidoo.mid"
notes_array = create_level_data(midi_file, "level_data7.json", 80)
#print(notes_array)

