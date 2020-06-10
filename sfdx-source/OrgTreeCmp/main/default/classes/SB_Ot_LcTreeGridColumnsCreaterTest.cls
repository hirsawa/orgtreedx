/**
 *  SB_Ot_LcTreeGridColumnsCreaterTest
 *    SB_Ot_LcTreeGridColumnsCreater テストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1    2019.05.xx  項目API名に基づかずに識別する
 *
 **/
@isTest
private class SB_Ot_LcTreeGridColumnsCreaterTest {

  @isTest
  static void test_createColumnDatas_Lead() {
    List<String> fields = new List<String>();
    Map<String, Schema.SObjectField> fieldMap = Lead.getSObjectType().getDescribe().fields.getMap();
    for(String f : fieldMap.keySet()) {
      Schema.DescribeFieldResult dfr = fieldMap.get(f).getDescribe();
      if (dfr.isNameField() || !dfr.isCreateable()) {
        continue;
      }
      fields.add(dfr.getName());
    }
    List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(null, fields, Lead.getSObjectType());
    System.assertEquals(fields.size(), cols.size());
  }

  @isTest
  static void test_createColumnDatas_Contact() {
    List<String> fields = new List<String>();
    Map<String, Schema.SObjectField> fieldMap = Contact.getSObjectType().getDescribe().fields.getMap();
    for(String f : fieldMap.keySet()) {
      Schema.DescribeFieldResult dfr = fieldMap.get(f).getDescribe();
      if (dfr.isNameField() || !dfr.isCreateable()) {
        continue;
      }
      fields.add(dfr.getName());
    }
    List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(null, fields, Contact.getSObjectType());
    System.assertEquals(fields.size(), cols.size());
  }

  @isTest
  static void test_createColumnDatas_Lead_Contact() {
    List<String> leadFields = new List<String>{ 'Title', 'Phone', 'MobilePhone', 'Address', 'EMail', null, 'OwnerId' };
    List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(null, leadFields, Lead.getSObjectType());
    System.assertEquals(leadFields.size(), cols.size());
    List<String> contFields = new List<String>{ 'Title', 'Phone', 'MobilePhone', null, 'EMail', 'Department', 'OwnerId' };
    cols = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(cols, contFields, Contact.getSObjectType());
    System.assertEquals(contFields.size(), cols.size());
  }

  @isTest
  static void test_createColumnDatas_Lead_InvalidField() {
    List<String> leadFields = new List<String>{ 'Department', 'OwnerId' };
    Boolean sucess;
    try {
      List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(null, leadFields, Lead.getSObjectType());
      sucess = true;
    }
    catch(Exception e) {
      sucess = false;
    }
    System.assertEquals(false, sucess);
  }

  @isTest
  static void test_Creater_create_Contact() {
    List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.create(Contact.getSObjectType(), null);
    System.assertEquals(false, cols.isEmpty());
  }

  @isTest
  static void test_Creater_create_Contact_hide() {
    List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.create(Contact.getSObjectType(), new Set<String> { 'contactrole' });
    System.assertEquals(false, cols.isEmpty());
  }


  @isTest
  static void test_Creater_create_Lead() {
    List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> cols = SB_Ot_LcTreeGridColumnsCreater.create(Lead.getSObjectType(), null);
    System.assertEquals(false, cols.isEmpty());
  }

  // @isTest
  // static void test_MultiColumnDataListBuilder_all_default() {
  //   // カスタム設定を初期化
  //   // 複数オブジェクト関連、デフォルトから変更
  //   OrgTreeConfig__c config = new OrgTreeConfig__c();
  //   // config.MultiObject__c = 'Lead,Account,Contact,SmartViscaf__NameCard__c';
  //   // // 5.複数オブジェクトのTreeGridでの表示項目1
  //   // config.MultiObjectTreeGridColumns1__c = 'Title, Phone, MobilePhone, EMail, SmartViscaf__NameCard__c, OwnerId, sobject';
  //   insert config;

  //   List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> columnDatas = SB_Ot_LcTreeGridColumnsCreater.create(null);
  //   if (Schema.getGlobalDescribe().containsKey('SmartViscaf__NameCard__c')) {
  //     System.assertEquals(8, columnDatas.size());
  //     System.assertEquals('url', columnDatas.get(0).type);
  //     System.assertEquals('text', columnDatas.get(1).type);
  //     System.assertEquals('phone', columnDatas.get(2).type);
  //     System.assertEquals('phone', columnDatas.get(3).type);
  //     System.assertEquals('email', columnDatas.get(4).type);
  //     System.assertEquals('url', columnDatas.get(5).type);
  //     System.assertEquals('url', columnDatas.get(6).type);
  //     System.assertEquals('text', columnDatas.get(7).type);
  //   }
  //   else {
  //     System.assertEquals(7, columnDatas.size());
  //     System.assertEquals('url', columnDatas.get(0).type);
  //     System.assertEquals('text', columnDatas.get(1).type);
  //     System.assertEquals('phone', columnDatas.get(2).type);
  //     System.assertEquals('phone', columnDatas.get(3).type);
  //     System.assertEquals('email', columnDatas.get(4).type);
  //     System.assertEquals('url', columnDatas.get(5).type);
  //     System.assertEquals('text', columnDatas.get(6).type);
  //   }
  // }

  // @isTest
  // static void test_MultiColumnDataListBuilder_all_custom() {
  //   // カスタム設定を初期化
  //   // 複数オブジェクト関連、デフォルトから変更
  //   OrgTreeConfig__c config = new OrgTreeConfig__c();
  //   config.MultiObject__c = 'Account, Contact, Lead, SmartViscaf__NameCard__c';
  //   config.MultiObjectTreeGridColumns1__c = 'Department, Title, Phone, MobilePhone, Email, Contact.EMail; Lead.Email; SmartViscaf__NameCard__c.SmartViscaf__email__c';
  //   config.MultiObjectTreeGridColumns2__c = ', SmartViscaf__NameCard__c, OwnerId';
  //   insert config;


  //   List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> columnDatas = SB_Ot_LcTreeGridColumnsCreater.create(null);
  //   if (Schema.getGlobalDescribe().containsKey('SmartViscaf__NameCard__c')) {
  //     System.assertEquals(9, columnDatas.size());
  //     System.assertEquals('url', columnDatas.get(0).type);
  //     System.assertEquals('text', columnDatas.get(1).type);
  //     System.assertEquals('text', columnDatas.get(2).type);
  //     System.assertEquals('phone', columnDatas.get(3).type);
  //     System.assertEquals('phone', columnDatas.get(4).type);
  //     System.assertEquals('email', columnDatas.get(5).type);
  //     System.assertEquals('email', columnDatas.get(6).type);
  //     System.assertEquals('url', columnDatas.get(7).type);
  //     System.assertEquals('url', columnDatas.get(8).type);
  //   }
  //   else {
  //     System.assertEquals(8, columnDatas.size());
  //     System.assertEquals('url', columnDatas.get(0).type);
  //     System.assertEquals('text', columnDatas.get(1).type);
  //     System.assertEquals('text', columnDatas.get(2).type);
  //     System.assertEquals('phone', columnDatas.get(3).type);
  //     System.assertEquals('phone', columnDatas.get(4).type);
  //     System.assertEquals('email', columnDatas.get(5).type);
  //     System.assertEquals('email', columnDatas.get(6).type);
  //     System.assertEquals('url', columnDatas.get(7).type);
  //   }
  // }

  // @isTest
  // static void test_MultiColumnDataListBuilder_invalidField() {
  //   // カスタム設定を初期化
  //   // 複数オブジェクト関連、デフォルトから変更
  //   OrgTreeConfig__c config = new OrgTreeConfig__c();
  //   config.MultiObject__c = 'Account, Contact, Lead, SmartViscaf__NameCard__c';
  //   config.MultiObjectTreeGridColumns1__c = 'Title, Phone, MobilePhone, EMail, AAAAA, SmartViscaf__NameCard__c, OwnerId, sobject';
  //   insert config;

  //   List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> columnDatas = SB_Ot_LcTreeGridColumnsCreater.create(null);
  //   if (Schema.getGlobalDescribe().containsKey('SmartViscaf__NameCard__c')) {
  //     System.assertEquals(8, columnDatas.size());
  //     System.assertEquals('url', columnDatas.get(0).type);
  //     System.assertEquals('text', columnDatas.get(1).type);
  //     System.assertEquals('phone', columnDatas.get(2).type);
  //     System.assertEquals('phone', columnDatas.get(3).type);
  //     System.assertEquals('email', columnDatas.get(4).type);
  //     System.assertEquals('url', columnDatas.get(5).type);
  //     System.assertEquals('url', columnDatas.get(6).type);
  //     System.assertEquals('text', columnDatas.get(7).type);
  //   }
  //   else {
  //     System.assertEquals(7, columnDatas.size());
  //     System.assertEquals('url', columnDatas.get(0).type);
  //     System.assertEquals('text', columnDatas.get(1).type);
  //     System.assertEquals('phone', columnDatas.get(2).type);
  //     System.assertEquals('phone', columnDatas.get(3).type);
  //     System.assertEquals('email', columnDatas.get(4).type);
  //     System.assertEquals('url', columnDatas.get(5).type);
  //     System.assertEquals('text', columnDatas.get(6).type);
  //   }
  // }

  // @isTest
  // static void test_MultiColumnDataListBuilder_sub() {
  //   SB_Ot_MultiObjectConfig multiConfig = SB_Ot_MultiObjectConfig.getInstance();
  //   List<SB_Ot_LcTreeGridColumnsCreater.ColumnData> columnDatas;
  //   for (SObjectType otype : multiConfig.otype2Fields.keySet()) {
  //     List<String> fields = multiConfig.otype2Fields.get(otype);
  //     columnDatas = SB_Ot_LcTreeGridColumnsCreater.createColumnDatas(columnDatas, fields, otype);
  //   }
  //   System.assert(columnDatas.size() > 0);
  // }

}