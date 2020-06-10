/**
 *  SB_Ot_LabelFormatterTest
 *
 *  SB_Ot_LabelFormatter のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1    2019.05.xx
 *
 **/
@isTest
private class SB_Ot_LabelFormatterTest {

  @TestSetup
  static void setupDB() {
    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='恵比寿株式会社', Site='本社'));
    insert acnts;

    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='テスト', FirstName='太郎', Email='taro@test.com', Title='課長', Department='営業部', AccountId=acnts[0].Id));
    insert conts;
  }

  // Account 用フォーマッターで
  @isTest
  static void test_AccountLabelFormatter_Account() {
    Account acnt = [SELECT Id, Name, Site, Owner.Name FROM Account WHERE Site !=null LIMIT 1];
    SB_Ot_OrgTreeConfig treeConfig = SB_Ot_OrgTreeConfig.getInstance();
    treeConfig.displayFormat = SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree;
    treeConfig.showSObject = true;
    treeConfig.showOwner = true;
    SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSObjectType());
    SB_Ot_LabelFormatter.ExtraLabelFormatter formatter = new SB_Ot_LabelFormatter.ExtraLabelFormatter(sobjConfig);
    String label = formatter.make(acnt);
    System.assert(label.containsIgnoreCase(acnt.Name));
  }

  // Account 用でない フォーマッターで
  @isTest
  static void test_ExtraLabelFormatter_Contact() {
    Contact cont = [SELECT Id, Name, Department, Title, Email, Owner.Name FROM Contact WHERE EMail != null And Title != null LIMIT 1];
    SB_Ot_OrgTreeConfig treeConfig = SB_Ot_OrgTreeConfig.getInstance();
    treeConfig.displayFormat = SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree;
    treeConfig.showSObject = true;
    treeConfig.showOwner = true;
    treeConfig.showTitle = true;
    treeConfig.showEmail = true;
    SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Contact.getSObjectType());
    SB_Ot_LabelFormatter.ExtraLabelFormatter formatter = new SB_Ot_LabelFormatter.ExtraLabelFormatter(sobjConfig);
    String label = formatter.make(cont);
    System.assert(label.containsIgnoreCase(cont.Name));
  }

  // フォーマッター生成のテスト
  @isTest
  static void test_createLabelFormatter() {
    SB_Ot_OrgTreeConfig treeConfig = SB_Ot_OrgTreeConfig.getInstance();
    treeConfig.displayFormat = SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree;
    treeConfig.showSObject = true;
    treeConfig.showOwner = true;
    treeConfig.showTitle = true;
    treeConfig.showEmail = true;
    treeConfig.gridLabelNoExtra = true;

    SB_Ot_LabelFormatter.LabelFormatter formatter;

    formatter = SB_Ot_LabelFormatter.createLabelFormatter(SB_Ot_SObjectConfig.getSObjectConfig(Account.getSObjectType()));
    System.assert(formatter instanceOf SB_Ot_LabelFormatter.AccountLabelFormatter);

    formatter = SB_Ot_LabelFormatter.createLabelFormatter(SB_Ot_SObjectConfig.getSObjectConfig(Contact.getSObjectType()));
    System.assert(formatter instanceOf SB_Ot_LabelFormatter.ExtraLabelFormatter);

    treeConfig.displayFormat = SB_Ot_OrgTreeConfig.ItemDisplayMode.Grid;
    formatter = SB_Ot_LabelFormatter.createLabelFormatter(SB_Ot_SObjectConfig.getSObjectConfig(Contact.getSObjectType()));
    System.assert(formatter instanceOf SB_Ot_LabelFormatter.SimpleLabelFormatter);
  }


}