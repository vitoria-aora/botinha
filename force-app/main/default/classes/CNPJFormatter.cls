/**
 * Camada de domínio: normaliza strings de CNPJ para 14 dígitos sem máscara.
 * Stateless, sem DML, sem SOQL, sem dependência de SObject.
 *
 * Regras:
 *  - Input vazio/null → recognized=true, value=null, changed=false (não bloqueia).
 *  - Após remover não-dígitos: length deve ser 14. CPF (11 dígitos) é rejeitado com mensagem específica.
 *  - Sequências repetidas (00000000000000, 11111111111111, ...) são rejeitadas.
 *  - Dígitos verificadores validados pelo algoritmo oficial da Receita Federal.
 *  - Canonical: 14 dígitos puros, sem máscara.
 */
public with sharing class CNPJFormatter {
  private static final String NON_DIGIT_REGEX = '[^0-9]';
  private static final Integer CNPJ_LENGTH = 14;
  private static final Integer CPF_LENGTH = 11;

  public class Result {
    public String value;
    public Boolean changed;
    public Boolean recognized;
    public String errorMessage;
  }

  public static Result standardize(String raw) {
    Result r = new Result();
    r.changed = false;
    r.recognized = true;

    if (String.isBlank(raw)) {
      r.value = null;
      return r;
    }

    String digits = raw.replaceAll(NON_DIGIT_REGEX, '');

    if (digits.length() == CPF_LENGTH) {
      r.recognized = false;
      r.errorMessage = 'Este campo aceita apenas CNPJ (14 dígitos). Para Pessoa Física, um campo CPF próprio será disponibilizado em breve.';
      return r;
    }

    if (digits.length() != CNPJ_LENGTH) {
      r.recognized = false;
      r.errorMessage = 'CNPJ deve ter 14 dígitos: ' + raw;
      return r;
    }

    if (isRepeatedDigit(digits)) {
      r.recognized = false;
      r.errorMessage = 'CNPJ inválido (dígitos verificadores): ' + raw;
      return r;
    }

    if (!hasValidDV(digits)) {
      r.recognized = false;
      r.errorMessage = 'CNPJ inválido (dígitos verificadores): ' + raw;
      return r;
    }

    r.value = digits;
    r.changed = (digits != raw);
    return r;
  }

  private static Boolean isRepeatedDigit(String digits) {
    String first = digits.substring(0, 1);
    for (Integer i = 1; i < digits.length(); i++) {
      if (digits.substring(i, i + 1) != first) {
        return false;
      }
    }
    return true;
  }

  private static Boolean hasValidDV(String digits) {
    List<Integer> w1 = new List<Integer>{ 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
    List<Integer> w2 = new List<Integer>{
      6,
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2
    };

    Integer dv1 = computeDV(digits.substring(0, 12), w1);
    if (dv1 != Integer.valueOf(digits.substring(12, 13))) {
      return false;
    }
    Integer dv2 = computeDV(digits.substring(0, 13), w2);
    if (dv2 != Integer.valueOf(digits.substring(13, 14))) {
      return false;
    }
    return true;
  }

  private static Integer computeDV(String partial, List<Integer> weights) {
    Integer sum = 0;
    for (Integer i = 0; i < partial.length(); i++) {
      sum += Integer.valueOf(partial.substring(i, i + 1)) * weights[i];
    }
    Integer mod = Math.mod(sum, 11);
    return mod < 2 ? 0 : 11 - mod;
  }
}
