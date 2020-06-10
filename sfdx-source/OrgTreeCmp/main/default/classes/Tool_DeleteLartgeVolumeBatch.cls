/*
  Tool_DeleteLartgeVolumeBatch

    大量のレコードを削除する用

    テスト用のツール パッケージには含めない！！

    String reqTime = Datetime.now().addSeconds(10).format('s m H d M ? yyyy');
    System.debug('@@ reqTime =' + reqTime);
    String batchName = 'Tool_DeleteLartgeVolumeBatch' + Datetime.now().format();
    Tool_DeleteLartgeVolumeBatch b = new Tool_DeleteLartgeVolumeBatch('Account');  // 注意！！ 全レコード削除
    Tool_DeleteLartgeVolumeBatch b = new Tool_DeleteLartgeVolumeBatch('Account', 'CreatedDate=TODAY');  // WHERE 句の条件を指定して 削除
    Tool_DeleteLartgeVolumeBatch b = new Tool_DeleteLartgeVolumeBatch('Account', 'Name LIKE \'株式会社テスト%\'');  // WHERE 句の条件を指定して 削除
    Tool_DeleteLartgeVolumeBatch b = new Tool_DeleteLartgeVolumeBatch('Account', 'Site != \'テスト本社\'');  // WHERE 句の条件を指定して 削除
    System.schedule(batchName, reqTime, b);    // スケジュール

*/
public with sharing class Tool_DeleteLartgeVolumeBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

  String query;
  SObjectType otype;

  public Tool_DeleteLartgeVolumeBatch(SObjectType otype) {
    this.otype = otype;
    this.query = 'SELECT Id, Name FROM ' + otype.getDescribe().getName();
  }

  public Tool_DeleteLartgeVolumeBatch(String objName) {
    this.otype = otype;
    this.query = 'SELECT Id, Name FROM ' + objName;
  }

  public Tool_DeleteLartgeVolumeBatch(SObjectType otype, String condition) {
    this.otype = otype;
    this.query = 'SELECT Id, Name FROM ' + otype.getDescribe().getName();
    this.query += String.isNotBlank(condition) ? ' WHERE ' + condition : '';
  }

  public Tool_DeleteLartgeVolumeBatch(String objName, String condition) {
    this.otype = otype;
    this.query = 'SELECT Id, Name FROM ' + objName;
    this.query += String.isNotBlank(condition) ? ' WHERE ' + condition : '';
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug(this.query);
    return Database.getQueryLocator(this.query);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    System.debug('execute scioe size: ' + scope.size());
    CrudFls.sdelete(scope);  // Code Scan対策
  }

  //public void execute(Database.BatchableContext BC, List<sObject> scope) {
  //  System.debug('execute scioe size: ' + scope.size());
  //  for (SObject obj : scope) {
  //    obj.put('Site', 'テスト本社');
  //  }
  //  update scope;
  //}

  public void finish(Database.BatchableContext BC) {

  }
  // スケジュール用メソッド
  public void execute(SchedulableContext sc) {
    Id batchProcessId = Database.executeBatch(this);
  }

}