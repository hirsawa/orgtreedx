/**
 *  SB_Ot_RecordsHolderTest
 *
 *  選択されたレコードから、同じ組織のレコードを収集保持するクラス SB_Ot_RecordsHolder のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx
 *
 **/
@isTest
private class SB_Ot_RecordsHolderTest {

 @TestSetup
 static void setupDB() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();
 }

  // SingleObjectRecordsHolder のテスト Leadで レコードID で収集
  @isTest
  static void test_SingleObjectRecordsHolderFromId() {
    // カスタム設定を変更
    SB_Ot_Global.otConfig.LeadWhere__c = 'Website=null';  // 検索条件を追加

    List<AggregateResult> ars = [SELECT Count(Id) cnt, Company FROM Lead GROUP BY Company];
    for (AggregateResult ar : ars) {
      String company = (String)ar.get('Company');
      Integer cnt = (Integer)ar.get('cnt');
      List<Lead> leads = [SELECT Id, Name, Company FROM Lead WHERE Company = :company];
      SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder = new SB_Ot_RecordsHolder.SingleObjectRecordsHolder();
      holder.create(leads[0].Id);  // レコードIDから
      System.assertEquals(company, holder.name);
      System.assertEquals(cnt, holder.members.size());
      System.assert(holder.label.contains(company));
      System.assert(holder.label.contains(Lead.getSObjectType().getDescribe().getLabel()));
    }
  }

  // SingleObjectRecordsHolder のテスト Leadで レコードID で収集だけど、組織名項目がNULL で　例外
  @isTest
  static void test_SingleObjectRecordsHolderFromId_NoOrgName() {
    // カスタム設定を変更
    SB_Ot_Global.otConfig.LeadOrgField__c = 'Website';  // 組織名項目を変える。

    List<AggregateResult> ars = [SELECT Count(Id) cnt, Company FROM Lead GROUP BY Company];
    for (AggregateResult ar : ars) {
      Boolean fault = false;
      String company = (String)ar.get('Company');
      Integer cnt = (Integer)ar.get('cnt');
      List<Lead> leads = [SELECT Id, Name, Company FROM Lead WHERE Company = :company];
      SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder = new SB_Ot_RecordsHolder.SingleObjectRecordsHolder();
      try {
        holder.create(leads[0].Id);
      }
      catch(Exception e) {
        fault = true;
      }
      System.assertEquals(true, fault);
    }
  }

  // SingleObjectRecordsHolder のテスト Leadで レコードID で収集
  @isTest
  static void test_SingleObjectRecordsHolderFromOrgName() {
    List<AggregateResult> ars = [SELECT Count(Id) cnt, Company FROM Lead GROUP BY Company];
    for (AggregateResult ar : ars) {
      String company = (String)ar.get('Company');
      Integer cnt = (Integer)ar.get('cnt');
      List<Lead> leads = [SELECT Id, Name, Company FROM Lead WHERE Company = :company];
      SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder = new SB_Ot_RecordsHolder.SingleObjectRecordsHolder(Lead.getSObjectType());
      holder.create(leads[0].Company);  // 組織名から
      System.assertEquals(company, holder.name);
      System.assertEquals(cnt, holder.members.size());
      System.assert(holder.label.contains(company));
      System.assert(holder.label.contains(Lead.getSObjectType().getDescribe().getLabel()));
    }
  }

  // SingleObjectRecordsHolder のテスト Leadで レコードID で収集
  @isTest
  static void test_SingleObjectRecordsHolderFromOrgName_None() {
    // List<AggregateResult> ars = [SELECT Count(Id) cnt, Company FROM Lead GROUP BY Company];
    // for (AggregateResult ar : ars) {
      Boolean fault = false;
    //   String company = (String)ar.get('Company');
    //   Integer cnt = (Integer)ar.get('cnt');
    //   List<Lead> leads = [SELECT Id, Name, Company FROM Lead WHERE Company = :company];
      SB_Ot_RecordsHolder.SingleObjectRecordsHolder holder = new SB_Ot_RecordsHolder.SingleObjectRecordsHolder(Lead.getSObjectType());
      try {
        holder.create('Invalid Inc.');// ない組織名から
      }
      catch(Exception e) {
        fault = true;
      }
      System.assertEquals(false, fault);
      System.assertEquals(true, holder.members.isEmpty());
    // }
  }


  // AccountsRecordsHolder のテスト レコードID で収集 一緒にやると TooManySOQLになるのでわける
  @isTest
  static void test_AccountsRecordsHolderFromId_Accout() {
    List<Account> acnts  = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name FROM Contact];

    // アカウントIDから
    for (Integer n=0; n<acnts.size(); n++) {
      SB_Ot_RecordsHolder.AccountsRecordsHolder enterprise = new SB_Ot_RecordsHolder.AccountsRecordsHolder();
      enterprise.create(acnts[n].Id);   // レコードID で収集
      System.assertEquals(acnts.size(), enterprise.acnts.size());
      System.assertEquals(conts.size(), enterprise.conts.size());
    }
    // // コンタクトIDから
    // for (Integer n=0; n<conts.size(); n++) {
    //   SB_Ot_RecordsHolder.AccountsRecordsHolder enterprise = new SB_Ot_RecordsHolder.AccountsRecordsHolder();
    //   enterprise.create(conts[n].Id);   // レコードID で収集
    //   System.assertEquals(acnts.size(), enterprise.acnts.size());
    //   System.assertEquals(conts.size(), enterprise.conts.size());
    // }
  }


  // AccountsRecordsHolder のテスト レコードID で収集 一緒にやると TooManySOQLになるのでわける
  @isTest
  static void test_AccountsRecordsHolderFromId_Contact() {
    List<Account> acnts  = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name FROM Contact];

    // // アカウントIDから
    // for (Integer n=0; n<acnts.size(); n++) {
    //   SB_Ot_RecordsHolder.AccountsRecordsHolder enterprise = new SB_Ot_RecordsHolder.AccountsRecordsHolder();
    //   enterprise.create(acnts[n].Id);   // レコードID で収集
    //   System.assertEquals(acnts.size(), enterprise.acnts.size());
    //   System.assertEquals(conts.size(), enterprise.conts.size());
    // }
    // コンタクトIDから
    for (Integer n=0; n<conts.size(); n++) {
      SB_Ot_RecordsHolder.AccountsRecordsHolder enterprise = new SB_Ot_RecordsHolder.AccountsRecordsHolder();
      enterprise.create(conts[n].Id);   // レコードID で収集
      System.assertEquals(acnts.size(), enterprise.acnts.size());
      System.assertEquals(conts.size(), enterprise.conts.size());
    }
  }

  // AccountsRecordsHolder のテスト 組織名 で収集
  @isTest
  static void test_AccountsRecordsHolderFromOrgName() {
    List<Account> acnts  = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name FROM Contact];

    // アカウントIDから
    for (Integer n=0; n<acnts.size(); n++) {
      SB_Ot_RecordsHolder.AccountsRecordsHolder enterprise = new SB_Ot_RecordsHolder.AccountsRecordsHolder();
      enterprise.create(acnts[n].Name); // 組織名 で収集
      System.assertEquals(acnts.size(), enterprise.acnts.size());
      System.assertEquals(conts.size(), enterprise.conts.size());
    }
  }

  // SingleAccountRecordsHolder のテスト
  @isTest
  static void test_SingleAccountRecordsHolderFromId_Account() {
    List<Account> acnts  = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact];

    // アカウントIDから
    for (Integer n=0; n<acnts.size(); n++) {
      Id acntId = acnts[n].Id;
      SB_Ot_RecordsHolder.SingleAccountRecordsHolder company = new SB_Ot_RecordsHolder.SingleAccountRecordsHolder();
      company.create(acntId);
      System.assertEquals(1, company.acnts.size());
      System.assertEquals([SELECT Id FROM Contact WHERE AccountId = :acntId].size(), company.conts.size());
    }
    // // コンタクトIDから
    // for (Integer n=0; n<conts.size(); n++) {
    //   Id acntId = conts[n].AccountId;
    //   Id contId = conts[n].Id;
    //   SB_Ot_RecordsHolder.SingleAccountRecordsHolder company = new SB_Ot_RecordsHolder.SingleAccountRecordsHolder();
    //   company.create(contId);
    //   System.assertEquals(1, company.acnts.size());
    //   System.assertEquals([SELECT Id FROM Contact WHERE AccountId = :acntId].size(), company.conts.size());
    // }
  }

  // SingleAccountRecordsHolder のテスト
  @isTest
  static void test_SingleAccountRecordsHolderFromId_Contact() {
    List<Account> acnts  = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact];

    // // アカウントIDから
    // for (Integer n=0; n<acnts.size(); n++) {
    //   Id acntId = acnts[n].Id;
    //   SB_Ot_RecordsHolder.SingleAccountRecordsHolder company = new SB_Ot_RecordsHolder.SingleAccountRecordsHolder();
    //   company.create(acntId);
    //   System.assertEquals(1, company.acnts.size());
    //   System.assertEquals([SELECT Id FROM Contact WHERE AccountId = :acntId].size(), company.conts.size());
    // }
    // コンタクトIDから
    for (Integer n=0; n<conts.size(); n++) {
      Id acntId = conts[n].AccountId;
      Id contId = conts[n].Id;
      SB_Ot_RecordsHolder.SingleAccountRecordsHolder company = new SB_Ot_RecordsHolder.SingleAccountRecordsHolder();
      company.create(contId);
      System.assertEquals(1, company.acnts.size());
      System.assertEquals([SELECT Id FROM Contact WHERE AccountId = :acntId].size(), company.conts.size());
    }
  }

  // SingleAccountRecordsHolder のテスト
  @isTest
  static void test_SingleAccountRecordsHolderFromOrgName() {
    List<Account> acnts  = [SELECT Id, Name FROM Account];
    List<Contact> conts = [SELECT Id, Name, AccountId FROM Contact];

    // 組織名から
    for (Integer n=0; n<acnts.size(); n++) {
      Id acntId = acnts[n].Id;
      SB_Ot_RecordsHolder.SingleAccountRecordsHolder company = new SB_Ot_RecordsHolder.SingleAccountRecordsHolder();
      company.create(acnts[n].Name); // 組織名 で収集
      System.assertEquals(1, company.acnts.size());
      System.assertEquals([SELECT Id FROM Contact WHERE AccountId = :acntId].size(), company.conts.size());
    }
  }

  @isTest
  static void test_SoloContactHolder() {
    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='取引先なし', FirstName='太郎', EMail='taro@nashi.com', AccountId=null));
    conts.add(new Contact(LastName='取引先なし', FirstName='次郎', EMail='jiro@nashi.com',AccountId=null));
    insert conts;

    Contact cont = [SELECT Id, Name, LastName, FirstName, EMail FROM Contact WHERE Id = :conts[0].Id LIMIT 1];
    //
    SB_Ot_RecordsHolder.RecordsHolder holder = SB_Ot_RecordsHolder.createHolder(null, cont.Id);
    // SB_Ot_RecordsHolder.SoloContactHolder holder = new SB_Ot_RecordsHolder.SoloContactHolder();
    // holder.create(cont.Id); // 組織名 で収集
    System.assert(holder instanceOf SB_Ot_RecordsHolder.SoloContactHolder);
    System.assertEquals(0, ((SB_Ot_RecordsHolder.SoloContactHolder)holder).acnts.size());
    System.assertEquals(1, ((SB_Ot_RecordsHolder.SoloContactHolder)holder).conts.size());
  }


}