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
    String currentMedicationsJson, {
    String? userFrequency,
    String? userInstructions,
    bool simpleMode = false,
  }) {
    // Construct user input section if provided
    String inputContext = '';
    if (userFrequency != null || userInstructions != null) {
      inputContext = '''
      User Provided Prescription Info (PRIORITY):
      Frequency: ${userFrequency ?? "Not provided"}
      Instructions: ${userInstructions ?? "Not provided"}
      INSTRUCTION: Use the above User Provided values for "frequency" and "instructions" fields if they are not null.
      If "Frequency" is not provided above, extract it from the label. If not found, provide a safe default (e.g. "As needed" or "Daily") based on the drug type. Set "isEstimatedFrequency" to true.
      ''';
    } else {
      inputContext =
          'INSTRUCTION: Frequency is not provided by user. Extract from label. If NOT present, provide a safe, logical default based on the drug type (e.g. "Take as needed for symptoms" or "Take 1 tablet daily" or "Anytime you feel pain" if appropriate). DO NOT return "Not provided". Set "isEstimatedFrequency" to true ONLY if you estimated it.';
    }

    // Add simplification instruction if simple mode is enabled
    String simplificationInstruction = '';
    if (simpleMode) {
      simplificationInstruction = '''
      
      IMPORTANT - SIMPLE LANGUAGE MODE ENABLED:
      You must generate TWO versions of descriptions:
      1. Standard fields (shortDescription, longDescription, etc.) = Normal adult medical language.
      2. Simplified fields (shortDescriptionSimplified, etc.) = Simple, friendly language for a 10-year-old. Use very simple words.
      
      DO NOT overwrite the standard fields with simple names. Keep them separate.
      ''';
    }

    return '''
      Analyze the provided image of a medication label.$simplificationInstruction
      
      Context - User Profile:
      $userProfileJson
      
      Context - Current Medications (Check for interactions):
      $currentMedicationsJson
      
      IMPORTANT - Existing Schedule Context:
      The user already has medications scheduled at certain times. When suggesting a frequency, try to space this new medication appropriately to avoid conflicts. Consider suggesting times that don't overlap with existing doses.
      
      $inputContext

      Extract the following information:
      1. Medication Name
      2. Dosage (e.g., "500mg"). If not visible, estimate it but mark 'isEstimatedDosage' as true.
      3. Frequency (e.g. "Take 1 tablet daily") - KEEP CONCISE (max 10 words). If user provided it, use that. If not, ESTIMATE the best frequency considering the user's current medication schedule. ALWAYS provide a value (like "As needed" or "Daily"). Do NOT return "Not provided". If specific times are implied (like "dinner" or "bedtime"), APPEND a hidden format at the end like "{8pm}" or "{morning}". Example: "Take at dinner {6pm}". Try to suggest times that work well with the existing schedule.
      4. Instructions - KEEP CONCISE. Use user text if provided. If not, ESTIMATE the best instructions. ALWAYS provide actionable instructions. Do NOT return "Not provided".
      5. Type (tablet, liquid, injection, inhaler, other)
      
      Analyze for the specific user (BE THOROUGH - THIS IS CRITICAL FOR SAFETY):
      6. Risks/Conflicts: Check against user's allergies, conditions, age, sex, pregnancy status.
         - If the user is allergic to this drug or a related compound, SET status to "conflict" and explain in userRisks.
         - If the user has a condition that contraindicates this drug, SET status to "caution" or "conflict".
         - If the user is pregnant and this drug is not safe for pregnancy, SET status to "conflict".
      7. Drug Interactions: Check against "Current Medications" for potential interactions.
         - Known dangerous combinations (e.g., blood thinners + NSAIDs, MAOIs + many drugs) MUST be flagged.
         - Rate severity as: "major" (dangerous, avoid) or "moderate" (use caution).
         - If there are ANY moderate/major interactions, you MUST SET status to "caution" (moderate) or "conflict" (major).
         - "Conflict" means specifically a dangerous interaction with ANOTHER medication or a severe profile contraindication.
      8. Status Reason: If status is NOT "safe", you MUST provide a clear explanation in "statusReason" field.
         - Be specific: name the interacting drug or condition.
         - Example: "Ibuprofen can increase bleeding risk when taken with Aspirin." (Use this format for interactions)
         - If you cannot provide a specific reason, DO NOT flag it - leave status as "safe".
      9. Short Description: 1 sentence summary of what the drug does (Adult version).
      10. Long Description: 2-3 sentences detailed description (Adult version).
      11. Common Side Effects: List of 3-5 common side effects (Adult version).
      
      CRITICAL STATUS RULES:
      - DEFAULT is "safe". Only change if you have a SPECIFIC, REAL reason.
      - "Conflict" = DANGEROUS interaction with OTHER medication OR severe contraindication (Allergy/Pregnancy).
      - "Caution" = Moderate interaction or general risk/condition warning.
      - DO NOT flag conflicts without a specific reason. When in doubt, leave as "safe".
      - statusReason is REQUIRED when status != "safe".
      
      Output ONLY valid JSON:
      {
        "name": "String",
        "dosage": "String",
        "frequency": "String",
        "instructions": "String",
        "type": "String",
        "isEstimatedDosage": boolean,
        "isEstimatedFrequency": boolean,
        "status": "safe" | "caution" | "conflict",
        "statusReason": "String or null",
        "userRisks": ["String"],
        "shortDescription": "String",
        "longDescription": "String",
        "commonSideEffects": ["String"],
        "shortDescriptionSimplified": "String (only if simple mode enabled or requested)",
        "longDescriptionSimplified": "String (only if simple mode enabled or requested)",
        "commonSideEffectsSimplified": ["String"],
        "statusReasonSimplified": "String",
        "conflictDescriptionSimplified": "String"
      }
      Type values: tablet, liquid, injection, inhaler, other
      Status values: safe, caution, conflict
      Do not output markdown code blocks.
    ''';
  }

  static String analyzeMedicationText(
    String query,
    String userProfileJson,
    String currentMedicationsJson, {
    bool simpleMode = false,
  }) {
    String simplificationInstruction = '';
    if (simpleMode) {
      simplificationInstruction = '''
      
      IMPORTANT - SIMPLE LANGUAGE MODE ENABLED:
      You must generate TWO versions of descriptions:
      1. Standard fields (shortDescription, longDescription) = Normal adult medical language.
      2. Simplified fields (shortDescriptionSimplified, etc.) = Simple, friendly language for a 10-year-old. Use very simple words.
      ''';
    }

    return '''
      Analyze the following medication search query/description:$simplificationInstruction
      "$query"
      
      Context - User Profile:
      $userProfileJson
      
      Context - Current Medications:
      $currentMedicationsJson

      Goal: Identify the medication and provide detailed information/estimation.

      Extract/Estimate the following:
      1. Medication Name: Identify the most likely medication from the query.
      2. Dosage: If specified in query, use it. If not, ESTIMATE standard dosage for adults (mark isEstimatedDosage: true).
      3. Frequency: If specified, use it. If not, ESTIMATE standard frequency (mark isEstimatedFrequency: true). ALWAYS provide a valid frequency (e.g. "Daily" or "As needed"). Do NOT return "Not provided".
      4. Instructions: If specified, use it. If not, ESTIMATE standard instructions based on drug type (e.g. "Take with water", "Apply to skin"). ALWAYS provide actionable instructions. Do NOT return "Not provided".
      5. Type: (tablet, liquid, injection, inhaler, other)

      Analyze for specific user (BE THOROUGH - THIS IS CRITICAL FOR SAFETY):
      6. Risks/Conflicts: Check against user profile.
         - If the user is allergic to this drug or a related compound, SET status to "conflict".
         - If the user has a condition that contraindicates this drug, SET status to "caution" or "conflict".
         - If the user is pregnant and this drug is not safe for pregnancy, SET status to "conflict".
      7. Drug Interactions: Check against current medications.
         - Known dangerous combinations (e.g., blood thinners + NSAIDs, MAOIs + many drugs) MUST be flagged.
         - If there are ANY moderate/major interactions, you MUST SET status to "caution" (moderate) or "conflict" (major).
         - "Conflict" = Dangerous interaction with OTHER med OR strict contraindication.
      8. Status Reason: If status is NOT "safe", you MUST provide a clear explanation in "statusReason" field.
         - If you cannot provide a specific reason, DO NOT flag it - leave status as "safe".
      9. Short/Long Descriptions, Side Effects (Adult versions).
      
      CRITICAL STATUS RULES:
      - DEFAULT is "safe". Only change if you have a SPECIFIC, REAL reason.
      - "Conflict" = DANGEROUS interaction with OTHER medication OR severe contraindication.
      - "Caution" = Moderate interaction or general risk.
      - DO NOT flag conflicts without a specific reason.
      - statusReason is REQUIRED when status != "safe", otherwise leave it null.

      Output ONLY valid JSON matching this structure:
      {
        "name": "String",
        "dosage": "String",
        "frequency": "String",
        "instructions": "String",
        "type": "String",
        "isEstimatedDosage": boolean,
        "isEstimatedFrequency": boolean,
        "status": "safe" | "caution" | "conflict",
        "statusReason": "String or null",
        "userRisks": ["String"],
        "shortDescription": "String",
        "longDescription": "String",
        "commonSideEffects": ["String"],
        "shortDescriptionSimplified": "String (only if simple mode enabled or requested)",
        "longDescriptionSimplified": "String (only if simple mode enabled or requested)",
        "commonSideEffectsSimplified": ["String"],
        "statusReasonSimplified": "String",
        "conflictDescriptionSimplified": "String"
      }
      Status values: safe, caution, conflict
      Do not output markdown code blocks.
    ''';
  }
}
