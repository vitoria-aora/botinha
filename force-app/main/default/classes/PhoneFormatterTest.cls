@isTest
private class PhoneFormatterTest {
  private static final String DDD_DEFAULT = '21';

  @isTest
  static void blankInputs_returnNullValue_recognizedTrue() {
    for (String input : new List<String>{ null, '', '   ', '\t' }) {
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals(
        null,
        r.value,
        'expected null value for blank input: [' + input + ']'
      );
      System.assertEquals(
        true,
        r.recognized,
        'blank should not be flagged invalid'
      );
      System.assertEquals(
        false,
        r.changed,
        'blank input should not be changed'
      );
    }
  }

  @isTest
  static void onlyPunctuation_unrecognized() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '(((--))',
      DDD_DEFAULT
    );
    System.assertEquals(false, r.recognized);
    System.assertNotEquals(null, r.errorMessage);
  }

  @isTest
  static void brCelularE164_isIdempotent() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '+5521988815471',
      DDD_DEFAULT
    );
    System.assertEquals('+5521988815471', r.value);
    System.assertEquals(false, r.changed);
    System.assertEquals(true, r.recognized);
  }

  @isTest
  static void brFixoE164_isIdempotent() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '+552133334444',
      DDD_DEFAULT
    );
    System.assertEquals('+552133334444', r.value);
    System.assertEquals(false, r.changed);
  }

  @isTest
  static void thirteenDigitsStartingWith55_addsPlus() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '5521988815471',
      DDD_DEFAULT
    );
    System.assertEquals('+5521988815471', r.value);
    System.assertEquals(true, r.changed);
  }

  @isTest
  static void twelveDigitsStartingWith55_addsPlus() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '552133334444',
      DDD_DEFAULT
    );
    System.assertEquals('+552133334444', r.value);
  }

  @isTest
  static void elevenDigitsStartingWith0_legacyTrunk_stripsAndReclassifies() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '02133334444',
      DDD_DEFAULT
    );
    System.assertEquals('+552133334444', r.value);
  }

  @isTest
  static void elevenDigitsWithDDD_celular_prefixes55() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '21988815471',
      DDD_DEFAULT
    );
    System.assertEquals('+5521988815471', r.value);
  }

  @isTest
  static void tenDigitsWithDDD_fixo_prefixes55() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '2133334444',
      DDD_DEFAULT
    );
    System.assertEquals('+552133334444', r.value);
  }

  @isTest
  static void nineDigitsCelular_appliesDefaultDDD() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '988815471',
      DDD_DEFAULT
    );
    System.assertEquals('+5521988815471', r.value);
  }

  @isTest
  static void nineDigitsWithoutDefaultDDD_unrecognized() {
    PhoneFormatter.Result r = PhoneFormatter.standardize('988815471', null);
    System.assertEquals(false, r.recognized);
    System.assertNotEquals(null, r.errorMessage);
  }

  @isTest
  static void eightDigitsLegacyCelular_addsNineAndDDD() {
    for (String firstDigit : new List<String>{ '6', '7', '8', '9' }) {
      String input = firstDigit + '8881547';
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals(
        '+5521' + '9' + input,
        r.value,
        'first digit ' + firstDigit
      );
    }
  }

  @isTest
  static void eightDigitsFixo_addsDDD() {
    for (String firstDigit : new List<String>{ '2', '3', '4', '5' }) {
      String input = firstDigit + '3334444';
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals(
        '+5521' + input,
        r.value,
        'first digit ' + firstDigit
      );
    }
  }

  @isTest
  static void formattedBR_normalizes() {
    Map<String, String> cases = new Map<String, String>{
      '(21) 98881-5471' => '+5521988815471',
      '(21) 9888-15471' => '+5521988815471',
      '21 98881-5471' => '+5521988815471',
      '+55 (21) 98881-5471' => '+5521988815471',
      '+55 21 98881 5471' => '+5521988815471',
      '21.9888.15471' => '+5521988815471'
    };
    for (String input : cases.keySet()) {
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals(cases.get(input), r.value, 'input: ' + input);
    }
  }

  @isTest
  static void international_preservesCountryCode() {
    Map<String, String> cases = new Map<String, String>{
      '+1 (415) 555-1234' => '+14155551234',
      '+44 20 7946 0958' => '+442079460958',
      '+33 1 23 45 67 89' => '+33123456789',
      '+49 30 12345678' => '+493012345678'
    };
    for (String input : cases.keySet()) {
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals(cases.get(input), r.value, 'input: ' + input);
      System.assertEquals(true, r.recognized, 'input: ' + input);
    }
  }

  @isTest
  static void internationalTooShort_unrecognized() {
    PhoneFormatter.Result r = PhoneFormatter.standardize('+1234', DDD_DEFAULT);
    System.assertEquals(false, r.recognized);
  }

  @isTest
  static void internationalTooLong_unrecognized() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      '+1234567890123456',
      DDD_DEFAULT
    );
    System.assertEquals(false, r.recognized);
  }

  @isTest
  static void ramalPatterns_areStripped() {
    List<String> inputs = new List<String>{
      '(21) 98881-5471 ramal 4321',
      '(21) 98881-5471 r. 4321',
      '(21) 98881-5471 r 4321',
      '(21) 98881-5471 r.4321',
      '(21) 98881-5471, 4321',
      '(21) 98881-5471;4321',
      '(21) 98881-5471 ext 4321',
      '(21) 98881-5471 ext. 4321',
      '(21) 98881-5471 ext.4321',
      '(21) 98881-5471 RAMAL 4321'
    };
    for (String input : inputs) {
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals('+5521988815471', r.value, 'input: ' + input);
    }
  }

  @isTest
  static void garbageInput_unrecognized() {
    for (
      String input : new List<String>{
        'abc',
        'fone do joão',
        '12345',
        '1',
        '+'
      }
    ) {
      PhoneFormatter.Result r = PhoneFormatter.standardize(input, DDD_DEFAULT);
      System.assertEquals(false, r.recognized, 'input: [' + input + ']');
      System.assertNotEquals(null, r.errorMessage, 'input: [' + input + ']');
    }
  }

  @isTest
  static void onlyRamal_emptiesValue() {
    PhoneFormatter.Result r = PhoneFormatter.standardize(
      'ramal 4321',
      DDD_DEFAULT
    );
    System.assertEquals(null, r.value);
    System.assertEquals(true, r.recognized);
  }

  @isTest
  static void extractDDD_e164_returnsCode() {
    System.assertEquals('21', PhoneFormatter.extractDDD('+5521988815471'));
    System.assertEquals('11', PhoneFormatter.extractDDD('+551133334444'));
  }

  @isTest
  static void extractDDD_unformattedBR_returnsCode() {
    System.assertEquals('21', PhoneFormatter.extractDDD('21988815471'));
    System.assertEquals('11', PhoneFormatter.extractDDD('1133334444'));
    System.assertEquals('21', PhoneFormatter.extractDDD('(21) 98881-5471'));
  }

  @isTest
  static void extractDDD_legacyTrunk_stripsZero() {
    System.assertEquals('21', PhoneFormatter.extractDDD('02133334444'));
  }

  @isTest
  static void extractDDD_international_returnsNull() {
    System.assertEquals(null, PhoneFormatter.extractDDD('+14155551234'));
  }

  @isTest
  static void extractDDD_blankOrShort_returnsNull() {
    System.assertEquals(null, PhoneFormatter.extractDDD(null));
    System.assertEquals(null, PhoneFormatter.extractDDD(''));
    System.assertEquals(null, PhoneFormatter.extractDDD('988815471'));
    System.assertEquals(null, PhoneFormatter.extractDDD('99'));
  }

  @isTest
  static void changedFlag_reflectsTransformation() {
    PhoneFormatter.Result canonical = PhoneFormatter.standardize(
      '+5521988815471',
      DDD_DEFAULT
    );
    System.assertEquals(false, canonical.changed);

    PhoneFormatter.Result transformed = PhoneFormatter.standardize(
      '(21) 98881-5471',
      DDD_DEFAULT
    );
    System.assertEquals(true, transformed.changed);
    System.assertEquals('+5521988815471', transformed.value);
  }
}
