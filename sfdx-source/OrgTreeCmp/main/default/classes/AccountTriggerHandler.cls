public with sharing class AccountTriggerHandler
{
public static final String ORG_NAME = 'Sunbridge Inc.';
public static final Integer MAX_LIMIT = 1000;

  public static boolean firstBeforeInsert = true; // .trigger で この値を参照して初回起動か判断して更新

  public void onBeforeInsert(List<Account> newObjs) {
    for (Account next : newObjs) {
      if (String.isBlank(next.Site)) {  // この場合は入力規則にすべき。
        next.addError('未入力不可');
      }
    }
  }

  public void onBeforeUpdate(List<Account> newObjs, Map<Id, Account> oldMap) {
    for (Account next : newObjs) {
      Account prev = oldMap.get(next.id);
      if (next.Site != prev.Site) {
        // 値が変わったら、、
      }
    }
  }

  public void onAfterInsert(List<Account> newObjs) {

  }

  public void onAfterUpdate(List<Account> newObjs, Map<Id, Account> oldMap) {

  }
}