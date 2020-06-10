/**
 * SB_Ot_RecConnectionDetectorTest
 *    SB_Ot_RecConnectionDetector のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx 初版
 *
 **/
@isTest
private class SB_Ot_RecConnectionDetectorTest {

 @TestSetup
 static void setupDB() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();
    // Lead に Account, Contact に対応するのを作っておく
    List<Contact> conts = [SELECT Id, Name, FirstName, LastName, Email, Title, Department, Account.Name FROM Contact];
    List<Lead> leads = new List<Lead>();
    for (Contact c : conts) {
      leads.add(new Lead(Company=c.Account.Name, Title = c.Title, FirstName=c.FirstName, LastName=c.LastName, Email=c.Email));
    }
    insert leads;
 }

  // SB_Ot_RecConnectionDetector のテスト メールで紐付ける
  // 0: 会社名 (会社名が一致するレコードを探す）
  // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
  // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
  @isTest
  static void test_run_byEmail() {
    // カスタム設定を変更
    // 他オブジェクトを関連づけるときに用いる項目
    // 0: 会社名 (会社名が一致するレコードを探す）
    // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
    // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
    SB_Ot_Global.otConfig.MultiObjectConnectionField__c = 1;


    List<Contact> conts = [SELECT Id, Name, FirstName, LastName, Email, Title, Department, Account.Name FROM Contact];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, conts[0].Id);
    detector.run();
    System.assertEquals(conts[0].Account.Name, (String)detector.getConnectionValue(Account.getSObjectType()));
    System.assertEquals(conts[0].Account.Name, (String)detector.getConnectionValue(Lead.getSObjectType()));
  }

  // SB_Ot_RecConnectionDetector のテスト 会社名で紐付ける Contact から
  // 0: 会社名 (会社名が一致するレコードを探す）
  // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
  // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
  @isTest
  static void test_run_byOrgName_Contact() {
    // カスタム設定を変更
    // 他オブジェクトを関連づけるときに用いる項目
    // 0: 会社名 (会社名が一致するレコードを探す）
    // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
    // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
    SB_Ot_Global.otConfig.MultiObjectConnectionField__c = 0;


    List<Contact> conts = [SELECT Id, Name, FirstName, LastName, Email, Title, Department, Account.Name FROM Contact];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, conts[0].Id);
    detector.run();
    System.assertEquals(conts[0].Account.Name, (String)detector.getConnectionValue(Account.getSObjectType()));
    System.assertEquals(conts[0].Account.Name, (String)detector.getConnectionValue(Lead.getSObjectType()));
  }

  // SB_Ot_RecConnectionDetector のテスト 会社名で紐付ける Account から
  // 0: 会社名 (会社名が一致するレコードを探す）
  // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
  // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
  @isTest
  static void test_run_byOrgName_Account() {
    // カスタム設定を変更
    // 他オブジェクトを関連づけるときに用いる項目
    // 0: 会社名 (会社名が一致するレコードを探す）
    // 1: メールアドレス（メールアドレスが一致したレコードと同一の会社名のレコードを探す)
    // 2: 取引先参照項目(または、取引先責任者参照項目）、リード参照項目: 名刺レコード以外では、参照先の名刺レコードの参照項目を使う。参照がない場合は 0: 会社名と同じ処理
    SB_Ot_Global.otConfig.MultiObjectConnectionField__c = 0;

    List<Account> acnts = [SELECT Id, Name FROM Account];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, acnts[0].Id);
    detector.run();
    System.assertEquals(acnts[0].Name, (String)detector.getConnectionValue(Account.getSObjectType()));
    System.assertEquals(acnts[0].Name, (String)detector.getConnectionValue(Lead.getSObjectType()));
  }


  @isTest
  static void test_isValidReferenceId_Account() {
    List<Account> acnts = [SELECT Id, Name FROM Account];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, acnts[0].Id);

    System.assertEquals(true, detector.isValidReferenceId(acnts[0].Id));
  }

  @isTest
  static void test_isValidReferenceId_Contact() {
    List<Contact> conts = [SELECT Id, Name FROM Contact];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, conts[0].Id);

    System.assertEquals(true, detector.isValidReferenceId(conts[0].Id));
  }

  @isTest
  static void test_isValidReferenceId_Lead() {
    List<Lead> leads = [SELECT Id, Name FROM Lead];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, leads[0].Id);

    System.assertEquals(true, detector.isValidReferenceId(leads[0].Id));
  }

  // 紐づく名刺の中の 参照項目を得る
  // ないのでみんなNULL
  @isTest
  static void test_getReferenceId() {
    List<Lead> leads = [SELECT Id, Name FROM Lead];
    List<SObjectType> otypes = new List<SObjectType> { Account.getSObjectType(), Lead.getSObjectType() };
    SB_Ot_RecConnectionDetector detector = new SB_Ot_RecConnectionDetector(otypes, leads[0].Id);

    // ないのでみんなNULL
    System.assertEquals(null, detector.getReferenceId(Account.getSObjectType()));
    System.assertEquals(null, detector.getReferenceId(Contact.getSObjectType()));
    System.assertEquals(null, detector.getReferenceId(Lead.getSObjectType()));
  }


}