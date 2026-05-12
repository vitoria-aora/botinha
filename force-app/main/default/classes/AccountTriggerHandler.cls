public with sharing class AccountTriggerHandler extends TriggerHandler {
  private static final List<String> BUSINESS_PHONE_FIELDS = new List<String>{
    'Phone',
    'Fax'
  };

  private static final List<String> PERSON_PHONE_FIELDS = new List<String>{
    'PersonMobilePhone',
    'PersonHomePhone',
    'PersonOtherPhone'
  };

  protected override void beforeInsert() {
    standardizePhones((List<Account>) Trigger.new, null);
    standardizeCNPJ((List<Account>) Trigger.new, null);
  }

  protected override void beforeUpdate() {
    standardizePhones(
      (List<Account>) Trigger.new,
      (Map<Id, Account>) Trigger.oldMap
    );
    standardizeCNPJ(
      (List<Account>) Trigger.new,
      (Map<Id, Account>) Trigger.oldMap
    );
  }

  private void standardizePhones(
    List<Account> records,
    Map<Id, Account> oldMap
  ) {
    String ddd = PhoneStandardizerContext.getDefaultDDD();
    for (Account a : records) {
      Account oldRec = oldMap == null ? null : oldMap.get(a.Id);
      for (String fld : BUSINESS_PHONE_FIELDS) {
        normalizeField(a, oldRec, fld, ddd);
      }
      if (a.IsPersonAccount) {
        for (String fld : PERSON_PHONE_FIELDS) {
          normalizeField(a, oldRec, fld, ddd);
        }
      }
    }
  }

  private void standardizeCNPJ(List<Account> records, Map<Id, Account> oldMap) {
    for (Account a : records) {
      if (a.IsPersonAccount)
        continue;
      Account oldRec = oldMap == null ? null : oldMap.get(a.Id);
      String newVal = a.CNPJ__c;
      String oldVal = oldRec == null ? null : oldRec.CNPJ__c;
      if (newVal == oldVal)
        continue;
      if (String.isBlank(newVal))
        continue;

      CNPJFormatter.Result r = CNPJFormatter.standardize(newVal);
      if (!r.recognized) {
        a.addError('CNPJ__c', r.errorMessage);
        continue;
      }
      if (r.changed) {
        a.CNPJ__c = r.value;
      }
    }
  }

  private void normalizeField(
    Account rec,
    Account oldRec,
    String fieldName,
    String ddd
  ) {
    String newVal = (String) rec.get(fieldName);
    String oldVal = oldRec == null ? null : (String) oldRec.get(fieldName);
    if (newVal == oldVal)
      return;
    if (String.isBlank(newVal))
      return;

    PhoneFormatter.Result r = PhoneFormatter.standardize(newVal, ddd);
    if (!r.recognized) {
      rec.addError(fieldName, r.errorMessage);
      return;
    }
    if (r.changed) {
      rec.put(fieldName, r.value);
    }
  }
}
