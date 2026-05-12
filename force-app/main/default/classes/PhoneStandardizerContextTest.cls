@isTest
private class PhoneStandardizerContextTest {
  @isTest
  static void cache_returnsInjectedValue() {
    PhoneStandardizerContext.setCachedDDD('99');
    System.assertEquals('99', PhoneStandardizerContext.getDefaultDDD());
  }

  @isTest
  static void resolve_fromUserPhone_takesPriority() {
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    u.Phone = '(31) 98888-7777';
    update u;

    PhoneStandardizerContext.resetCache();
    System.assertEquals('31', PhoneStandardizerContext.getDefaultDDD());
  }

  @isTest
  static void resolve_fallsBackToMetadata_whenUserPhoneEmpty() {
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    u.Phone = null;
    update u;

    PhoneStandardizerContext.resetCache();
    System.assertEquals('21', PhoneStandardizerContext.getDefaultDDD());
  }

  @isTest
  static void resolve_fallsBackToMetadata_whenUserPhoneIsInternational() {
    User u = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    u.Phone = '+14155551234';
    update u;

    PhoneStandardizerContext.resetCache();
    System.assertEquals('21', PhoneStandardizerContext.getDefaultDDD());
  }

  @isTest
  static void getDefaultDDD_hitsResolverOnce_thenCaches() {
    PhoneStandardizerContext.resetCache();
    String first = PhoneStandardizerContext.getDefaultDDD();
    Integer queriesBefore = Limits.getQueries();
    String second = PhoneStandardizerContext.getDefaultDDD();
    Integer queriesAfter = Limits.getQueries();

    System.assertEquals(first, second);
    System.assertEquals(
      queriesBefore,
      queriesAfter,
      'second call should not issue SOQL'
    );
  }
}
