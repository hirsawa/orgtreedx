/**
    Tool_UpdateDeliveryTypeBatch

 名刺の納品状態を更新してトリガを機能させます。

 Tool_UpdateDeliveryTypeBatch jb = new Tool_UpdateDeliveryTypeBatch('SmartViscaf__Parent__c=null AND CreatedDate=TODAY', '1');
 Database.executeBatch(jb, 20);

**/
public with sharing class Tool_UpdateDeliveryTypeBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

  private String query;
  private String newValue;

  private static String QUERY_FORMAT = 'SELECT Id, Name, SmartViscaf__delivery_type__c, SmartViscaf__Parent__c, SmartViscaf__company_name__c, SmartViscaf__division_name__c, SmartViscaf__division__c, SmartViscaf__title_name__c, SmartViscaf__email__c, SmartViscaf__card_exchange_date__c FROM SmartViscaf__NameCard__c {0} ORDER BY SmartViscaf__email__c';

  public Tool_UpdateDeliveryTypeBatch(String condition, String newValue) {
    String whereEx = String.isNotBlank(condition) ? ' WHERE ' + condition : '';
    this.query = String.format(QUERY_FORMAT, new String[] { whereEx });
    this.newValue = newValue;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug(this.query);
    return Database.getQueryLocator(this.query);
  }

  public void execute(Database.BatchableContext BC, List<SmartViscaf__NameCard__c> scope) {
    System.debug('execute scioe size: ' + scope.size());
    for (SmartViscaf__NameCard__c card : scope) {
      card.SmartViscaf__delivery_type__c = this.newValue;
    }
    update scope;
  }

  public void finish(Database.BatchableContext BC) {

  }
  // スケジュール用メソッド
  public void execute(SchedulableContext sc) {
    Id batchProcessId = Database.executeBatch(this);
  }

}