public with sharing class ContactTriggerHandler extends TriggerHandler {
  private static final List<String> PHONE_FIELDS = new List<String>{
    'Phone',
    'MobilePhone',
    'HomePhone',
    'OtherPhone',
    'AssistantPhone'
  };

  protected override void beforeInsert() {
    standardizePhones((List<Contact>) Trigger.new, null);
  }

  protected override void beforeUpdate() {
    standardizePhones(
      (List<Contact>) Trigger.new,
      (Map<Id, Contact>) Trigger.oldMap
    );
  }

  private void standardizePhones(
    List<Contact> records,
    Map<Id, Contact> oldMap
  ) {
    String ddd = PhoneStandardizerContext.getDefaultDDD();
    for (Contact c : records) {
      if (c.IsPersonAccount)
        continue;
      Contact oldRec = oldMap == null ? null : oldMap.get(c.Id);
      for (String fld : PHONE_FIELDS) {
        normalizeField(c, oldRec, fld, ddd);
      }
    }
  }

  private void normalizeField(
    Contact rec,
    Contact oldRec,
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
