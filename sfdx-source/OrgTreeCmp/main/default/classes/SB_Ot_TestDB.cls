/**
 *
 * SB_Ot_TestDB
 *
 * テストクラス用のデータを作る基底クラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.03.xx
 **/
public virtual class SB_Ot_TestDB {

  public static final Integer CNT_USER = 10;
  public List<User> listUser = new List<User>();

  // テストユーザ追加
  public virtual void createUsers() {
    Profile profStd = [SELECT Id FROM profile WHERE Name='Standard User' OR Name='標準ユーザ' LIMIT 1];
    for (Integer n=1; n<=CNT_USER; n++) {
      String email = 'test'+ n.format().leftPad(3, '0') +'@testorg.com';
      String dept = 'test'+ n.format().leftPad(3, '0') +'部';
      listUser.add(new User(
              Alias = 'test'+ n.format()
              , Email= email
              , EmailEncodingKey='UTF-8'
              , FirstName = n.format() +'号'
              , LastName = 'テスト'
              , Title = dept + '部長'
              , CompanyName = '株式会社サンブリッジ'
              , Department = dept
              , LanguageLocaleKey='ja'
              , LocaleSidKey ='ja_JP'
              , ProfileId = profStd.Id
              , TimeZoneSidKey='Asia/Tokyo'
              , Country='日本'
              , State='東京都'
              , City='渋谷区'
              , Street='恵比寿南1丁目'
              , PostalCode='115-0023'
              , Phone='03-5488-6004'
              , Fax='03-5488-6010'
              , EmployeeNumber= String.valueOf(n)
              , Username = email));
    }
    insert listUser;
  }

  protected virtual List<Lead> createLeads() {
    List<Lead> result = new List<Lead>();
    result.add(new Lead(Company='渋谷株式会社', FirstName='太郎', LastName='恵比寿', Title='部長', Email='user01@shibuya.com'));
    result.add(new Lead(Company='渋谷株式会社', FirstName='次郎', LastName='恵比寿', Title='課長', Email='user02@shibuya.com'));
    result.add(new Lead(Company='渋谷株式会社', FirstName='三郎', LastName='恵比寿', Title='', Email='user03@shibuya.com'));
    result.add(new Lead(Company='目黒商事株式会社', FirstName='太郎', LastName='不動前', Title='部長', Email='user01@meguro.co.jp'));
    result.add(new Lead(Company='目黒商事株式会社', FirstName='次郎', LastName='不動前', Title='課長', Email='user02@meguro.co.jp'));
    result.add(new Lead(Company='目黒商事株式会社', FirstName='三郎', LastName='不動前', Title='', Email='user03@meguro.co.jp'));
    insert result;
    return result;
  }

  protected virtual List<Account> createChildAccount(List<Account> parents) {
    List<Account> result = new List<Account>();
    for (Account parent : parents) {
      result.add(new Account(Name=parent.Name+'子会社01', ParentId=parent.Id));
      result.add(new Account(Name=parent.Name+'子会社02', ParentId=parent.Id));
    }
    insert result;
    return result;
  }

  protected virtual List<Contact> createContacts(List<Account> acnts) {
    List<Contact> result = new List<Contact>();
    for (Account acnt : acnts) {
      result.add(new Contact(LastName=acnt.Name+'社員01', FirstName='太郎', Department='開発部 開発課', Title='課長', Email='taro@' + acnt.Id + '.com', AccountId=acnt.Id));
      result.add(new Contact(LastName=acnt.Name+'社員02', FirstName='次郎', Department='営業部 営業課', Title='課長', Email='jiro@' + acnt.Id + '.com', AccountId=acnt.Id));
    }
    insert result;
    return result;
  }

  protected virtual void createCustomConfig() {
    // カスタム設定を初期化
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.PrioritizeCustomSetting__c = true;  // カスタム設定を優先する
    config.AccountAssociation__c = true;      // 取引先 親・子の取引先を階層に含める#
    config.ContactTreeGridColumns__c = 'Title, Phone, MobilePhone, EMail, MailingAddress, OwnerId';
    config.LeadTreeGridColumns__c = 'Title, Phone, MobilePhone, Email';
    config.AccountOtherCondition__c = 0;
    config.ContactOtherCondition__c = 0;
    config.LeadOtherCondition__c = 0;
    config.NameCardOtherCondition__c = 0;
    config.UserOtherCondition__c = 0;
    insert config;
  }

  protected virtual void createAccountContactRole() {
    List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact];
    List<Schema.PicklistEntry> acrpls = AccountContactRole.Role.getDescribe().getPicklistValues();
    List<AccountContactRole> aRoles = new List<AccountContactRole>();
    for (Contact c :conts) {
      if (c.AccountId != null) {
        aRoles.add(new AccountContactRole(AccountId=c.AccountId, ContactId=c.Id, Role=acrpls.get(0).getValue(), IsPrimary=true));
      }
    }
    insert aRoles;
  }


  public virtual void initialize() {
    // ユーザを作る
    createUsers();
    User u = [SELECT Id, Name FROM User LIMIT 1];
    System.runAs(u) {
      // リードを作る
      createLeads();
      List<Account> acnts = new List<Account>();
      List<Contact> conts;
      // ルートのアカウントを作る。
      acnts.add(new Account(Name='株式会社親商事'));  // 1
      insert acnts;
      // ルートアカウント所属のコンタクトを作る
      conts = createContacts(acnts);      // 2
      // 第2階層のアカウントを作る
      acnts = createChildAccount(acnts);      // 1+2
      // 第2階層のアカウント所属のコンタクトを作る
      conts = createContacts(acnts);      // 2+4
      // 第3階層のアカウントを作る
      acnts = createChildAccount(acnts);      // 3+4
      // 第3階層のアカウント所属のコンタクトを作る
      conts = createContacts(acnts);      // 6+8
      // 取引先責任者の役割を作る
      createAccountContactRole();
    }
    // カスタム設定を作る
    createCustomConfig();
  }


}