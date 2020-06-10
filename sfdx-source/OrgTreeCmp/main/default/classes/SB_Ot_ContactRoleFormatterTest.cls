/**
 *  SB_Ot_ContactRoleFormatterTest
 *
 *  SB_Ot_ContactRoleFormatter のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1    2019.12.xx
 *
 **/
@isTest
private class SB_Ot_ContactRoleFormatterTest {

  @TestSetup
  static void setupDB() {
    List<Account> acnts = new List<Account>();
    acnts.add(new Account(Name='恵比寿株式会社', Site='本社'));
    insert acnts;
    List<Contact> conts = new List<Contact>();
    conts.add(new Contact(LastName='社員01', FirstName='太郎', Department='開発部 開発課', Title='課長', Email='taro@ebisu.com', AccountId=acnts[0].Id));
    insert conts;
    List<Schema.PicklistEntry> acrpls = AccountContactRole.Role.getDescribe().getPicklistValues();
    List<AccountContactRole> aRoles = new List<AccountContactRole>();
    aRoles.add(new AccountContactRole(AccountId=acnts[0].Id, ContactId=conts[0].Id, Role=acrpls.get(0).getValue(), IsPrimary=true));
    insert aRoles;
    List<Case> cases = new List<Case>();
    cases.add(new Case(Subject='何かケース', AccountId=acnts[0].Id, ContactId=conts[0].Id, Status='New'));
    insert cases;
    List<Schema.PicklistEntry> ccrpls = CaseContactRole.Role.getDescribe().getPicklistValues();
    List<CaseContactRole> cRoles = new List<CaseContactRole>();
    cRoles.add(new CaseContactRole(CasesId=cases[0].Id, ContactId=conts[0].Id, Role=ccrpls.get(0).getValue()));
    insert cRoles;
  }

  // Account 用でない フォーマッターで
  @isTest
  static void test_SB_Ot_ContactRoleFormatter_AccountRole() {
    Contact cont = [SELECT Id, Name, (SELECT Id, Role, IsPrimary FROM AccountContactRoles), (SELECT Id, Role FROM CaseContactRoles) FROM Contact LIMIT 1];
    SB_Ot_ContactRoleFormatter.createFormatter(Contact.getSObjectType());
    System.assert(SB_Ot_ContactRoleFormatter.instance instanceOf SB_Ot_ContactRoleFormatter.WithPrimaryContactRoleFormatter);
    String label = SB_Ot_ContactRoleFormatter.makeContactRole(cont);
    List<Schema.PicklistEntry> acrpls = AccountContactRole.Role.getDescribe().getPicklistValues();
    System.assertEquals(SB_Ot_ContactRoleFormatter.primary + acrpls.get(0).getLabel(), label);
  }

  @isTest
  static void test_SB_Ot_ContactRoleFormatter_CaseRole() {
    Contact cont = [SELECT Id, Name, (SELECT Id, Role, IsPrimary FROM AccountContactRoles), (SELECT Id, Role FROM CaseContactRoles) FROM Contact LIMIT 1];
    SB_Ot_ContactRoleFormatter.createFormatter(Case.getSObjectType());
    System.assert(!(SB_Ot_ContactRoleFormatter.instance instanceOf SB_Ot_ContactRoleFormatter.WithPrimaryContactRoleFormatter));
    String label = SB_Ot_ContactRoleFormatter.makeContactRole(cont);
    List<Schema.PicklistEntry> ccrpls = CaseContactRole.Role.getDescribe().getPicklistValues();
    System.assertEquals(ccrpls.get(0).getLabel(), label);
  }


}