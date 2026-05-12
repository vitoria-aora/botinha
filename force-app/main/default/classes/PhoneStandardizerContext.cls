/**
 * Resolve o DDD default a aplicar na padronização de telefones.
 *
 * Hierarquia:
 *   1. User.Phone do usuário logado (DDD extraído via PhoneFormatter.extractDDD)
 *   2. Phone_Standardizer_Settings__mdt, instância Default
 *
 * Cacheia o valor em variável estática durante a transação para evitar
 * leituras repetidas em operações bulk.
 */
public with sharing class PhoneStandardizerContext {
  @TestVisible
  private static String cachedDDD;
  @TestVisible
  private static Boolean cacheLoaded = false;

  public static String getDefaultDDD() {
    if (!cacheLoaded) {
      cachedDDD = resolve();
      cacheLoaded = true;
    }
    return cachedDDD;
  }

  private static String resolve() {
    List<User> users = [
      SELECT Phone
      FROM User
      WHERE Id = :UserInfo.getUserId()
      LIMIT 1
    ];
    if (!users.isEmpty()) {
      String fromUser = PhoneFormatter.extractDDD(users[0].Phone);
      if (fromUser != null)
        return fromUser;
    }
    Phone_Standardizer_Settings__mdt s = Phone_Standardizer_Settings__mdt.getInstance(
      'Default'
    );
    return s == null ? null : s.Default_DDD__c;
  }

  @TestVisible
  private static void resetCache() {
    cachedDDD = null;
    cacheLoaded = false;
  }

  @TestVisible
  private static void setCachedDDD(String ddd) {
    cachedDDD = ddd;
    cacheLoaded = true;
  }
}
