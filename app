import streamlit as st
from transformers import pipeline

# ------------------------------
# Load Whisper Model
# ------------------------------
def load_whisper_model():
    
    #Load the Whisper model for audio transcription.
    
    whisper = pipeline("automatic-speech-recognition", model="openai/whisper-tiny", return_timestamps=True) # loading the whisper model, return_timestamps=True for 30 seconds limit
    return whisper

# ------------------------------
# Load NER Model
# ------------------------------
def load_ner_model():
    """
    Load the Named Entity Recognition (NER) model pipeline.
    """
    ner = pipeline("ner", model="dslim/bert-base-NER", grouped_entities=True) # loading the NER model
    return ner

# ------------------------------
# Transcription Logic
# ------------------------------
def transcribe_audio(uploaded_file):
    """
    Transcribe audio into text using the Whisper model.
    Args:
        uploaded_file: Audio file uploaded by the user.
    Returns:
        str: Transcribed text from the audio file.
    """
    whisper = load_whisper_model()
    transcription = whisper(uploaded_file.read())  # transcribing the audio file
    return transcription['text'] # returning the transcribed text

# ------------------------------
# Entity Extraction
# ------------------------------
def extract_entities(text, ner_pipeline):
    """
    Extract entities from transcribed text using the NER model.
    Args:
        text (str): Transcribed text.
        ner_pipeline: NER pipeline loaded from Hugging Face.
    Returns:
        dict: Grouped entities (ORGs, LOCs, PERs).
    """
    entities = ner_pipeline(text) # getting the entities
    grouped_entities = {"ORGs": [], "LOCs": [], "PERs": []}
    for entity in entities: # grouping the entities
        if entity['entity_group'] == "ORG":
            grouped_entities["ORGs"].append(entity['word'])
        elif entity['entity_group'] == "LOC":
            grouped_entities["LOCs"].append(entity['word'])
        elif entity['entity_group'] == "PER":
            grouped_entities["PERs"].append(entity['word'])

    for key in grouped_entities: # removing duplicates
        grouped_entities[key] = list(set(grouped_entities[key]))

    return grouped_entities


# ------------------------------
# Main Streamlit Application
# ------------------------------
def main():
    st.title("Meeting Transcription and Entity Extraction")

    # You must replace below
    STUDENT_NAME = "Gonca Kaplan"
    STUDENT_ID = "150220324"
    st.write(f"{STUDENT_ID} - {STUDENT_NAME}")

    st.subheader("Upload Audio File")
    uploaded_file = st.file_uploader("Choose a WAV file", type="wav")

    if uploaded_file is not None:
        st.info("Transcribing the audio file... This may take a minute.")

        ner_pipeline = load_ner_model() # loading NER model
 
        transcription = transcribe_audio(uploaded_file) # getting transcription

        # displaying transcription
        st.subheader("Transcription")
        st.write(transcription)

        st.info("Extracting entities...")

        entities = extract_entities(transcription, ner_pipeline) # extracting entities

        # displaying entities
        st.subheader("Extracted Entities")
        st.write("### Organizations (ORGs)")
        # st.write(entities["ORGs"])
        for org in entities["ORGs"]:
            st.write(f"- {org}")

        st.write("### Locations (LOCs)")
        for loc in entities["LOCs"]:
            st.write(f"- {loc}")

        st.write("### Persons (PERs)")
        for per in entities["PERs"]:
            st.write(f"- {per}")


if _name_ == "_main_":
    main()
 
