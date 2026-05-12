/**
 * Camada de domínio: normaliza strings de telefone para E.164.
 * Stateless, sem DML, sem SOQL, sem dependência de SObject.
 *
 * Regras: ver spec PhoneStandardizer §1.4.
 */
public with sharing class PhoneFormatter {
  private static final String RAMAL_REGEX = '(?i)\\s*(?:ramal|ext\\.?|r\\.|r\\s+|,|;).*$';
  private static final String NON_DIGIT_REGEX = '[^0-9]';
  private static final Integer INTL_MIN_DIGITS = 8;
  private static final Integer INTL_MAX_DIGITS = 15;

  public class Result {
    public String value;
    public Boolean changed;
    public Boolean recognized;
    public String errorMessage;
  }

  public static Result standardize(String raw, String defaultDDD) {
    Result r = new Result();
    r.changed = false;
    r.recognized = true;

    if (String.isBlank(raw)) {
      r.value = null;
      return r;
    }

    String cleaned = raw.replaceFirst(RAMAL_REGEX, '').trim();
    Boolean startsWithPlus = cleaned.startsWith('+');
    String digits = cleaned.replaceAll(NON_DIGIT_REGEX, '');

    if (digits.length() == 0) {
      if (String.isBlank(cleaned)) {
        r.value = null;
        r.changed = true;
        return r;
      }
      r.recognized = false;
      r.errorMessage = 'Telefone em formato não reconhecido: ' + raw;
      return r;
    }

    String canonical;

    if (startsWithPlus && !digits.startsWith('55')) {
      if (
        digits.length() < INTL_MIN_DIGITS ||
        digits.length() > INTL_MAX_DIGITS
      ) {
        r.recognized = false;
        r.errorMessage =
          'Telefone internacional fora do intervalo aceito (8 a 15 dígitos): ' +
          raw;
        return r;
      }
      canonical = '+' + digits;
    } else {
      canonical = classifyBR(digits, defaultDDD);
      if (canonical == null) {
        r.recognized = false;
        r.errorMessage = 'Telefone em formato não reconhecido: ' + raw;
        return r;
      }
    }

    r.value = canonical;
    r.changed = (canonical != raw);
    return r;
  }

  public static String extractDDD(String raw) {
    if (String.isBlank(raw))
      return null;

    String cleaned = raw.replaceFirst(RAMAL_REGEX, '').trim();
    Boolean startsWithPlus = cleaned.startsWith('+');
    String digits = cleaned.replaceAll(NON_DIGIT_REGEX, '');

    if (digits.length() == 0)
      return null;
    if (startsWithPlus && !digits.startsWith('55'))
      return null;

    if (
      digits.startsWith('55') &&
      (digits.length() == 12 ||
      digits.length() == 13)
    ) {
      return digits.substring(2, 4);
    }
    if (digits.length() == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length() == 10 || digits.length() == 11) {
      return digits.substring(0, 2);
    }
    return null;
  }

  private static String classifyBR(String digits, String defaultDDD) {
    Integer len = digits.length();

    if (len == 13 && digits.startsWith('55'))
      return '+' + digits;
    if (len == 12 && digits.startsWith('55'))
      return '+' + digits;
    if (len == 11 && digits.startsWith('0'))
      return classifyBR(digits.substring(1), defaultDDD);
    if (len == 11)
      return '+55' + digits;
    if (len == 10)
      return '+55' + digits;
    if (len == 9)
      return defaultDDD == null ? null : '+55' + defaultDDD + digits;
    if (len == 8) {
      if (defaultDDD == null)
        return null;
      String first = digits.substring(0, 1);
      if ('6789'.contains(first))
        return '+55' + defaultDDD + '9' + digits;
      if ('2345'.contains(first))
        return '+55' + defaultDDD + digits;
    }
    return null;
  }
}
