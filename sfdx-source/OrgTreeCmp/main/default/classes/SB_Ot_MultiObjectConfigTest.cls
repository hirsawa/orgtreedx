/**
 * SB_Ot_MultiObjectConfigTest
 *    SB_Ot_MultiObjectConfigのテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx 初版 複数オブジェクト構成対応
 *
 **/
@isTest
private class SB_Ot_MultiObjectConfigTest {

  @isTest
  static void test_getSObjectType() {
    System.assertEquals(Account.getSObjectType(), SB_Ot_MultiObjectConfig.getSObjectType('Account'));
    System.assertEquals(Contact.getSObjectType(), SB_Ot_MultiObjectConfig.getSObjectType('Contact'));
    if (Schema.getGlobalDescribe().containsKey('SmartViscaf__NameCard__c')) {
      System.assertEquals(Schema.getGlobalDescribe().get('SmartViscaf__NameCard__c'), 
              SB_Ot_MultiObjectConfig.getSObjectType('SmartViscaf__NameCard__c'));
    }
    else {
      System.assertEquals(null, 
              SB_Ot_MultiObjectConfig.getSObjectType('SmartViscaf__NameCard__c'));
    }
  }
  
  @isTest
  static void test_SB_Ot_MultiObjectConfig() {
    // カスタム設定をデフォルトで初期化
    OrgTreeConfig__c config = new OrgTreeConfig__c(); 
    insert config;
    SB_Ot_MultiObjectConfig mulConfig = SB_Ot_MultiObjectConfig.getInstance();
    if (Schema.getGlobalDescribe().containsKey('SmartViscaf__NameCard__c')) {
      // SmartViscaあり
      SObjectType svOType = Schema.getGlobalDescribe().get('SmartViscaf__NameCard__c');
      // mulConfig.init('Account, Contact, Lead, SmartViscaf__NameCard__c',
      //       'Title, Phone, MobilePhone, Contact.EMail; Lead.Email; SmartViscaf__NameCard__c.SmartViscaf__email__c, SmartViscaf__NameCard__c, OwnerId, sobject');
      System.assertEquals(7, mulConfig.otype2Fields.get(Account.sObjectType).size());
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(0));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Account.sObjectType).get(1));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(2));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(3));
      System.assertEquals(7, mulConfig.otype2Fields.get(Contact.sObjectType).size());
      System.assertEquals('title', mulConfig.otype2Fields.get(Contact.sObjectType).get(0));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Contact.sObjectType).get(1));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Contact.sObjectType).get(2));
      System.assertEquals('email', mulConfig.otype2Fields.get(Contact.sObjectType).get(3));
      System.assertEquals(7, mulConfig.otype2Fields.get(Lead.sObjectType).size());
      System.assertEquals('title', mulConfig.otype2Fields.get(Lead.sObjectType).get(0));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Lead.sObjectType).get(1));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Lead.sObjectType).get(2));
      System.assertEquals('email', mulConfig.otype2Fields.get(Lead.sObjectType).get(3));
      System.assertEquals(7, mulConfig.otype2Fields.get(svOType).size());
      System.assertEquals('smartviscaf__title_name__c', mulConfig.otype2Fields.get(svOType).get(0));
      System.assertEquals('smartviscaf__tel1__c', mulConfig.otype2Fields.get(svOType).get(1));
      System.assertEquals('smartviscaf__mobile__c', mulConfig.otype2Fields.get(svOType).get(2));
      System.assertEquals('smartviscaf__email__c', mulConfig.otype2Fields.get(svOType).get(3));

      // System.assertEquals(6, mulConfig.gridColumns.size());
    }
    else {
      // SmartViscaなし
      // mulConfig.init('Account, Contact, Lead',
      //       'Title, Phone, MobilePhone, Contact.EMail; Lead.Email, OwnerId');
      System.assertEquals(6, mulConfig.otype2Fields.get(Account.sObjectType).size());
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(0));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Account.sObjectType).get(1));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(2));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(3));
      System.assertEquals(6, mulConfig.otype2Fields.get(Contact.sObjectType).size());
      System.assertEquals('title', mulConfig.otype2Fields.get(Contact.sObjectType).get(0));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Contact.sObjectType).get(1));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Contact.sObjectType).get(2));
      System.assertEquals('email', mulConfig.otype2Fields.get(Contact.sObjectType).get(3));
      System.assertEquals(6, mulConfig.otype2Fields.get(Lead.sObjectType).size());
      System.assertEquals('title', mulConfig.otype2Fields.get(Lead.sObjectType).get(0));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Lead.sObjectType).get(1));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Lead.sObjectType).get(2));
      System.assertEquals('email', mulConfig.otype2Fields.get(Lead.sObjectType).get(3));
      
      // System.assertEquals(5, mulConfig.gridColumns.size());
    }
  }

  @isTest
  static void test_SB_Ot_MultiObjectConfig_with_param() {
    // カスタム設定を初期化 
    // 複数オブジェクト関連、デフォルトから変更
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.MultiObject__c = 'Account, Contact, Lead, SmartViscaf__NameCard__c';
    config.MultiObjectTreeGridColumns1__c = 'Department, Title, Phone, MobilePhone, Email, Contact.EMail; Lead.Email; SmartViscaf__NameCard__c.SmartViscaf__email__c';
    config.MultiObjectTreeGridColumns2__c = ', SmartViscaf__NameCard__c, OwnerId, sobject';
    insert config;
    SB_Ot_MultiObjectConfig mulConfig = SB_Ot_MultiObjectConfig.getInstance();
    // SB_Ot_MultiObjectConfig mulConfig = SB_Ot_MultiObjectConfig.getInstance(
    //     'Account, Contact, Lead, SmartViscaf__NameCard__c',
    //     'Department, Title, Phone, MobilePhone, Email, Contact.EMail; Lead.Email; SmartViscaf__NameCard__c.SmartViscaf__email__c, SmartViscaf__NameCard__c, OwnerId');
    if (Schema.getGlobalDescribe().containsKey('SmartViscaf__NameCard__c')) {
      // SmartViscaあり
      SObjectType svOType = Schema.getGlobalDescribe().get('SmartViscaf__NameCard__c');
      System.assertEquals(9, mulConfig.otype2Fields.get(Account.sObjectType).size());
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(0));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(1));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Account.sObjectType).get(2));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(3));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(4));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(5));
      System.assertEquals(9, mulConfig.otype2Fields.get(Contact.sObjectType).size());
      System.assertEquals('department', mulConfig.otype2Fields.get(Contact.sObjectType).get(0));
      System.assertEquals('title', mulConfig.otype2Fields.get(Contact.sObjectType).get(1));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Contact.sObjectType).get(2));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Contact.sObjectType).get(3));
      System.assertEquals('email', mulConfig.otype2Fields.get(Contact.sObjectType).get(4));
      System.assertEquals('email', mulConfig.otype2Fields.get(Contact.sObjectType).get(5));
      System.assertEquals(9, mulConfig.otype2Fields.get(Lead.sObjectType).size());
      System.assertEquals(null, mulConfig.otype2Fields.get(Lead.sObjectType).get(0));
      System.assertEquals('title', mulConfig.otype2Fields.get(Lead.sObjectType).get(1));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Lead.sObjectType).get(2));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Lead.sObjectType).get(3));
      System.assertEquals('email', mulConfig.otype2Fields.get(Lead.sObjectType).get(4));
      System.assertEquals('email', mulConfig.otype2Fields.get(Lead.sObjectType).get(5));
      System.assertEquals(9, mulConfig.otype2Fields.get(svOType).size());
      System.assertEquals('smartviscaf__division__c', mulConfig.otype2Fields.get(svOType).get(0));
      System.assertEquals('smartviscaf__title_name__c', mulConfig.otype2Fields.get(svOType).get(1));
      System.assertEquals('smartviscaf__tel1__c', mulConfig.otype2Fields.get(svOType).get(2));
      System.assertEquals('smartviscaf__mobile__c', mulConfig.otype2Fields.get(svOType).get(3));
      System.assertEquals('smartviscaf__email__c', mulConfig.otype2Fields.get(svOType).get(4));
      System.assertEquals('smartviscaf__email__c', mulConfig.otype2Fields.get(svOType).get(5));

      // System.assertEquals(8, mulConfig.gridColumns.size());
    }
    else {
      // SmartViscaなし
      System.assertEquals(8, mulConfig.otype2Fields.get(Account.sObjectType).size());
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(0));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(1));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(2));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(3));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(4));
      System.assertEquals(null, mulConfig.otype2Fields.get(Account.sObjectType).get(5));
      System.assertEquals(8, mulConfig.otype2Fields.get(Contact.sObjectType).size());
      System.assertEquals('department', mulConfig.otype2Fields.get(Contact.sObjectType).get(0));
      System.assertEquals('title', mulConfig.otype2Fields.get(Contact.sObjectType).get(1));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Contact.sObjectType).get(2));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Contact.sObjectType).get(3));
      System.assertEquals('email', mulConfig.otype2Fields.get(Contact.sObjectType).get(4));
      System.assertEquals('email', mulConfig.otype2Fields.get(Contact.sObjectType).get(5));
      System.assertEquals(8, mulConfig.otype2Fields.get(Lead.sObjectType).size());
      System.assertEquals(null, mulConfig.otype2Fields.get(Lead.sObjectType).get(0));
      System.assertEquals('title', mulConfig.otype2Fields.get(Lead.sObjectType).get(1));
      System.assertEquals('phone', mulConfig.otype2Fields.get(Lead.sObjectType).get(2));
      System.assertEquals('mobilephone', mulConfig.otype2Fields.get(Lead.sObjectType).get(3));
      System.assertEquals('email', mulConfig.otype2Fields.get(Lead.sObjectType).get(4));
      System.assertEquals('email', mulConfig.otype2Fields.get(Lead.sObjectType).get(5));

      // System.assertEquals(7, mulConfig.gridColumns.size());
    }
  }

}