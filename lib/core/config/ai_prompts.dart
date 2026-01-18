class AIPrompts {
  static String parseMedicalProfile(String notes, String languageName) {
    return '''
        Analyze the following medical notes:
        "$notes"
        
        Extract specific allergies and medical conditions.
        Return ONLY a valid JSON object with two keys: "allergies" and "conditions".
        Both values should be lists of strings.
        Output everything in $languageName.
        Simplify the terms (e.g., "type 2 diabetes" -> "Diabetes Type 2").
        Rules:
        1. Correct obvious typos (e.g., "pneuts" -> "peanuts", "diabetis" -> "Diabetes").
        2. If a word is ambiguous (e.g. "penits"), inferred context. "penits allergy" -> "Peanut Allergy".
        3. DO NOT hallucinate drugs like "Penicillin" unless explicitly mentioned or strongly implied by context (e.g. "antibiotic allergy").
        4. If unsure or if text is empty/irrelevant, return empty lists.
        5. Do not output markdown code blocks, just raw JSON.
    ''';
  }

  static String transcribeMedicalNotes(String languageName) {
    return '''
      Can you please transcribe this audio?
      The user is speaking about their medical history, allergies, or conditions.
      Transcribe exactly what they say, but fix any obvious stuttering or filler words.
      The output should be the raw text of what they said, suitable for a text input field about their medical profile.
      Output everything in $languageName.
    ''';
  }

  static String analyzeMedicationLabel(
    String userProfileJson,
    String currentMedicationsJson,
  ) {
    return '''
      Analyze the provided image of a medication label.
      
      Context - User Profile:
      $userProfileJson
      
      Context - Current Medications (Check for interactions):
      $currentMedicationsJson

      Extract the following information:
      1. Medication Name
      2. Dosage (e.g., "500mg"). If not visible, estimate it but mark 'isEstimatedDosage' as true.
      3. Frequency (e.g. "Take 1 tablet daily") - KEEP CONCISE (max 10 words).
      4. Instructions - KEEP CONCISE (max 15 words).
      5. Type (tablet, liquid, injection, inhaler, other)
      
      Analyze for the specific user:
      6. Risks/Conflicts: Check against user's allergies, conditions, age, sex, pregnancy status.
      7. Drug Interactions: Check against "Current Medications".
      8. Short Description: 1 sentence summary of what the drug does.
      9. Long Description: 2-3 sentences detailed description.
      10. Common Side Effects: List of 3-5 common side effects.
      
      Output ONLY valid JSON:
      {
        "name": "String",
        "dosage": "String",
        "frequency": "String",
        "instructions": "String",
        "type": "String",
        "isEstimatedDosage": boolean,
        "userRisks": ["String", "String"],
        "conflictDescription": "String or null",
        "shortDescription": "String",
        "longDescription": "String",
        "commonSideEffects": ["String", "String"],
        "status": "String"
      }
      Type values: tablet, liquid, injection, inhaler, other
      Status values: safe, caution, conflict
      Do not output markdown code blocks.
    ''';
  }
}
