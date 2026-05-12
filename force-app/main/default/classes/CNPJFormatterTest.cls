@isTest
private class CNPJFormatterTest {
  // CNPJs válidos para teste (verificados contra algoritmo da Receita)
  private static final String VALID_RAW = '11222333000181';
  private static final String VALID_MASKED = '11.222.333/0001-81';
  private static final String VALID_OTHER = '33014556000196';

  @isTest
  static void blankInputs_returnNullValue_recognizedTrue() {
    for (String input : new List<String>{ null, '', '   ', '\t' }) {
      CNPJFormatter.Result r = CNPJFormatter.standardize(input);
      System.assertEquals(
        null,
        r.value,
        'expected null for blank input: [' + input + ']'
      );
      System.assertEquals(
        true,
        r.recognized,
        'blank should not be flagged invalid'
      );
      System.assertEquals(false, r.changed, 'blank should not be changed');
    }
  }

  @isTest
  static void validCNPJ_unmasked_isIdempotent() {
    CNPJFormatter.Result r = CNPJFormatter.standardize(VALID_RAW);
    System.assertEquals(VALID_RAW, r.value);
    System.assertEquals(false, r.changed);
    System.assertEquals(true, r.recognized);
  }

  @isTest
  static void validCNPJ_masked_isNormalized() {
    CNPJFormatter.Result r = CNPJFormatter.standardize(VALID_MASKED);
    System.assertEquals(VALID_RAW, r.value);
    System.assertEquals(true, r.changed);
    System.assertEquals(true, r.recognized);
  }

  @isTest
  static void validCNPJ_otherKnown_passes() {
    CNPJFormatter.Result r = CNPJFormatter.standardize(VALID_OTHER);
    System.assertEquals(VALID_OTHER, r.value);
    System.assertEquals(true, r.recognized);
  }

  @isTest
  static void cpfLength_rejectedWithSpecificMessage() {
    CNPJFormatter.Result r = CNPJFormatter.standardize('12345678901');
    System.assertEquals(false, r.recognized);
    System.assert(
      r.errorMessage != null && r.errorMessage.contains('CPF'),
      'expected CPF-specific message, got: ' + r.errorMessage
    );
  }

  @isTest
  static void cpfMasked_rejected() {
    CNPJFormatter.Result r = CNPJFormatter.standardize('123.456.789-01');
    System.assertEquals(false, r.recognized);
    System.assert(r.errorMessage.contains('CPF'));
  }

  @isTest
  static void wrongLength_rejected() {
    for (
      String input : new List<String>{
        '1',
        '123',
        '123456',
        '12345678901234567890'
      }
    ) {
      CNPJFormatter.Result r = CNPJFormatter.standardize(input);
      System.assertEquals(false, r.recognized, 'input: ' + input);
      System.assertNotEquals(null, r.errorMessage, 'input: ' + input);
    }
  }

  @isTest
  static void repeatedDigits_rejected() {
    for (
      String input : new List<String>{
        '00000000000000',
        '11111111111111',
        '22222222222222',
        '99999999999999'
      }
    ) {
      CNPJFormatter.Result r = CNPJFormatter.standardize(input);
      System.assertEquals(false, r.recognized, 'input: ' + input);
      System.assert(
        r.errorMessage != null &&
        r.errorMessage.contains('dígitos verificadores'),
        'expected DV message, got: ' + r.errorMessage
      );
    }
  }

  @isTest
  static void invalidDV_rejected() {
    // CNPJ sintaticamente válido (14 dígitos, não-repetidos) mas com DV errado
    CNPJFormatter.Result r = CNPJFormatter.standardize('11222333000182');
    System.assertEquals(false, r.recognized);
    System.assert(r.errorMessage.contains('dígitos verificadores'));
  }

  @isTest
  static void invalidSecondDV_rejected() {
    // DV1 correto (8), DV2 errado (3 em vez de 1)
    CNPJFormatter.Result r = CNPJFormatter.standardize('11222333000183');
    System.assertEquals(false, r.recognized);
  }

  @isTest
  static void garbageInput_rejected() {
    for (
      String input : new List<String>{ 'abc', 'sem nada de número', '!!!' }
    ) {
      CNPJFormatter.Result r = CNPJFormatter.standardize(input);
      System.assertEquals(false, r.recognized, 'input: [' + input + ']');
    }
  }

  @isTest
  static void changedFlag_reflectsTransformation() {
    CNPJFormatter.Result canonical = CNPJFormatter.standardize(VALID_RAW);
    System.assertEquals(false, canonical.changed);

    CNPJFormatter.Result transformed = CNPJFormatter.standardize(VALID_MASKED);
    System.assertEquals(true, transformed.changed);
    System.assertEquals(VALID_RAW, transformed.value);
  }

  @isTest
  static void mixedPunctuation_isStripped() {
    Map<String, String> cases = new Map<String, String>{
      '11.222.333/0001-81' => VALID_RAW,
      '11 222 333 0001 81' => VALID_RAW,
      '11/222/333/0001/81' => VALID_RAW,
      '11-222-333-0001-81' => VALID_RAW
    };
    for (String input : cases.keySet()) {
      CNPJFormatter.Result r = CNPJFormatter.standardize(input);
      System.assertEquals(cases.get(input), r.value, 'input: ' + input);
      System.assertEquals(true, r.recognized, 'input: ' + input);
    }
  }
}
