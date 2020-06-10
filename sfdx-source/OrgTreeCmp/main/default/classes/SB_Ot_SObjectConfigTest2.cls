/**
 *
 *  SB_Ot_OrgTreeConfigTest2
 *    SB_Ot_OrgTreeConfig のテストクラス  基本的なことのテスト カバレッジを稼ぐためにメソッドを個別にテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.12.xx
 *
 */
@isTest
private class SB_Ot_SObjectConfigTest2
{

  // @TestSetup
  // static void setupAccounts() {
  //   List<Account> acnts = new List<Account>();
  //   acnts.add(new Account(Name='株式会社テスト', Site='営業部'));
  //   acnts.add(new Account(Name='株式会社テスト', Site='開発部'));
  //   acnts.add(new Account(Name='株式会社サンプル'));
  //   insert acnts;
  // }

  // private static void updateAccountsWithNameCard() {
  //   List<SObject> cards = new List<SObject>();
  //   SObject saishin = SB_Ot_Global.getNameCardSObjectType().newSObject();
  //   saishin.put('Name', '最新 太郎');
  //   saishin.put('SmartViscaf__company_name__c', '株式会社テスト');
  //   saishin.put('SmartViscaf__person_name_first__c', '最新');
  //   saishin.put('SmartViscaf__person_name_last__c', '太郎');
  //   saishin.put('SmartViscaf__division__c', '営業部');
  //   saishin.put('SmartViscaf__title_name__c', '部長');
  //   saishin.put('SmartViscaf__email__c', 'taro@test.com');
  //   saishin.put('SmartViscaf__delivery_type__c', '2');
  //   saishin.put('SmartViscaf__Parent__c', null);
  //   saishin.put('SmartViscaf__tenshokugonomeishi__c', null);
  //   cards.add(saishin);

  //   SObject tenshoku = SB_Ot_Global.getNameCardSObjectType().newSObject();
  //   tenshoku.put('Name', '転職 次郎');
  //   tenshoku.put('SmartViscaf__company_name__c', '株式会社テスト');
  //   tenshoku.put('SmartViscaf__person_name_first__c', '転職');
  //   tenshoku.put('SmartViscaf__person_name_last__c', '次郎');
  //   tenshoku.put('SmartViscaf__division__c', '営業部');
  //   tenshoku.put('SmartViscaf__title_name__c', '課長');
  //   tenshoku.put('SmartViscaf__email__c', 'jiro@sample.com');
  //   tenshoku.put('SmartViscaf__delivery_type__c', '2');
  //   tenshoku.put('SmartViscaf__Parent__c', null);
  //   tenshoku.put('SmartViscaf__tenshokugonomeishi__c', null);
  //   cards.add(tenshoku);
  //   insert cards;
  //   Id tenshokugoId = cards[0].Id;

  //   cards.clear();
  //   // 最新ではない
  //   SObject saishin_0 = SB_Ot_Global.getNameCardSObjectType().newSObject();
  //   saishin_0.put('Name', '最新 太郎');
  //   saishin_0.put('SmartViscaf__company_name__c', '株式会社テスト');
  //   saishin_0.put('SmartViscaf__person_name_first__c', '最新');
  //   saishin_0.put('SmartViscaf__person_name_last__c', '太郎');
  //   saishin_0.put('SmartViscaf__division__c', '開発部');
  //   saishin_0.put('SmartViscaf__title_name__c', '課長');
  //   saishin_0.put('SmartViscaf__email__c', 'taro@test.com');
  //   saishin_0.put('SmartViscaf__delivery_type__c', '2');
  //   saishin_0.put('SmartViscaf__Parent__c', saishin.Id);
  //   saishin_0.put('SmartViscaf__tenshokugonomeishi__c', null);
  //   cards.add(saishin_0);
  //   // 転職済み 株式会社サンプル から 株式会社テスト
  //   SObject tenshoku_0 = SB_Ot_Global.getNameCardSObjectType().newSObject();
  //   tenshoku_0.put('Name', '転職 次郎');
  //   tenshoku_0.put('SmartViscaf__company_name__c', '株式会社サンプル');
  //   tenshoku_0.put('SmartViscaf__person_name_first__c', '転職');
  //   tenshoku_0.put('SmartViscaf__person_name_last__c', '次郎');
  //   tenshoku_0.put('SmartViscaf__title_name__c', '部長');
  //   tenshoku_0.put('SmartViscaf__email__c', 'jiro@sample.com');
  //   tenshoku_0.put('SmartViscaf__delivery_type__c', '2');
  //   tenshoku_0.put('SmartViscaf__Parent__c', null);
  //   tenshoku_0.put('SmartViscaf__tenshokugonomeishi__c', tenshokugoId);
  //   cards.add(tenshoku_0);
  //   insert cards;

  //   List<Account> acnts = [SELECT Id, Name, Site FROM Account];
  //   for (Account a : acnts) {
  //     if (a.Name=='株式会社テスト' && a.Site=='営業部') {
  //       // 最新の名刺に紐付いてる
  //       a.put('SmartViscaf__NameCard__c', saishin.Id);
  //     }
  //     else if (a.Name=='株式会社テスト' && a.Site=='開発部') {
  //       // 最新の名刺でない に紐付いてる
  //       a.put('SmartViscaf__NameCard__c', saishin_0.Id);
  //     }
  //     else if (a.Name=='株式会社サンプル') {
  //       // 転職済に 紐付いてる
  //       a.put('SmartViscaf__NameCard__c', tenshoku_0.Id);
  //     }
  //   }
  //   update acnts;
  // }

  // private static final List<String> accountFields = new List<String> {
  //   'Id', 'Name',
  //   'SmartViscaf__NameCard__c',
  //   'SmartViscaf__NameCard__r.SmartViscaf__Parent__c',
  //   'SmartViscaf__NameCard__r.SmartViscaf__Saishin__c',
  //   'SmartViscaf__NameCard__r.SmartViscaf__tenshokugonomeishi__c',
  //   'SmartViscaf__NameCard__r.SmartViscaf__tenshokuzumi__c'
  // };

  // private static void setupAccountSObjectConfig(String condiition) {
  //   List<Account> acnts = [SELECT Id, Name FROM Account];
  //   SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
  //   req.selectedId = acnts[0].Id;       // 対象のレコードID
  //   req.idField = 'id';       //参照するオブジェクト(項目)
  //   req.displayFormat = 'tree'; // 表示形式
  //   req.dateRange = 0; // 対象レコードの期日の範囲 n年前から
  //   req.otherCondition = condiition; // 対象レコードの条件
  //   req.orgField = null;   // 組織名の項目
  //   req.deptField = null;  // 部署名の項目
  //   req.titleField = 'Title';   // 役職名の項目
  //   req.gridFields = 'Title, Email, OwnerId';   // グリッドに表示する項目
  //   req.deptParser = 'Separator';  // 部門、部署の分割方法
  //   // req.showTitle = true;  // 役職を表示する
  //   // req.showOwner = true;   // 所有者を表示する
  //   // req.showEMail = true;   // メアドを表示する
  //   // req.gridLabelNoExtra = true;   // グリッドのラベルには 役職等を表示しない
  //   req.maxRecs = 1000; //  対象レコード数の制限
  //   // 取引先 特有の設定項目
  //   req.accountAssociation = false; // 親・子の取引先を階層に含める  カスタム設定と相違！！
  //   req.accountGridFields = null;// 取引先 グリッドに表示する項目
  //   req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法

  //   SB_Ot_SObjectConfig.makeSObjectConfig(Account.getSObjectType(), req);
  // }

  // @isTest
  // static void test_isMatchDateOtherCpnditions_none() {
  //   setupAccountSObjectConfig('none');
  //   SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Account.sObjectType);
  //   if (SB_Ot_Global.isEnableSmartVisca()) {
  //     // updateAccountsWithNameCard();
  //     String query = String.format('SELECT {0} FROM Account WHERE Name=\'\'株式会社テスト\'\' AND Site=\'\'営業部\'\'', new String[]{ String.join(accountFields, ', ')});
  //     System.debug(query);
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  //   else {
  //     String query = 'SELECT Id, Name FROM Account WHERE Name=\'株式会社テスト\' AND Site=\'営業部\'';
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  // }

  // @isTest
  // static void test_isMatchDateOtherCpnditions_haveNC() {
  //   setupAccountSObjectConfig('haveNC');
  //   SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Account.sObjectType);
  //   if (SB_Ot_Global.isEnableSmartVisca()) {
  //     updateAccountsWithNameCard();
  //     String query = String.format('SELECT {0} FROM Account WHERE Name=\'\'株式会社テスト\'\' AND Site=\'\'営業部\'\'', new String[]{ String.join(accountFields, ', ')});
  //     System.debug(query);
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  //   else {
  //     String query = 'SELECT Id, Name FROM Account WHERE Name=\'株式会社テスト\' AND Site=\'営業部\'';
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  // }

  // @isTest
  // static void test_isMatchDateOtherCpnditions_haveLatestNC() {
  //   setupAccountSObjectConfig('haveLatestNC');
  //   SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Account.sObjectType);
  //   if (SB_Ot_Global.isEnableSmartVisca()) {
  //     updateAccountsWithNameCard();
  //     String query = String.format('SELECT {0} FROM Account WHERE Name=\'\'株式会社テスト\'\' AND Site=\'\'営業部\'\'', new String[]{ String.join(accountFields, ', ')});
  //     System.debug(query);
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  //   else {
  //     String query = 'SELECT Id, Name FROM Account WHERE Name=\'株式会社テスト\' AND Site=\'営業部\'';
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  // }

  // @isTest
  // static void test_isMatchDateOtherCpnditions_haveNoChangeLatestNC() {
  //   setupAccountSObjectConfig('haveNoChangeLatestNC');
  //   SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Account.sObjectType);
  //   if (SB_Ot_Global.isEnableSmartVisca()) {
  //     updateAccountsWithNameCard();
  //     String query = String.format('SELECT {0} FROM Account WHERE Name=\'\'株式会社テスト\'\' AND Site=\'\'営業部\'\'', new String[]{ String.join(accountFields, ', ')});
  //     System.debug(query);
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  //   else {
  //     String query = 'SELECT Id, Name FROM Account WHERE Name=\'株式会社テスト\' AND Site=\'営業部\'';
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  // }

  // @isTest
  // static void test_isMatchDateOtherCpnditions_haveNoChangeLatestNC_false() {
  //   setupAccountSObjectConfig('haveNoChangeLatestNC');
  //   SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Account.sObjectType);
  //   if (SB_Ot_Global.isEnableSmartVisca()) {
  //     updateAccountsWithNameCard();
  //     String query = String.format('SELECT {0} FROM Account WHERE Name=\'\'株式会社サンプル\'\'', new String[]{ String.join(accountFields, ', ')});
  //     System.debug(query);
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(false, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  //   else {
  //     String query = 'SELECT Id, Name FROM Account WHERE Name=\'株式会社テスト\' AND Site=\'営業部\'';
  //     List<SObject> recs = Database.query(query);
  //     System.assertEquals(true, config.isMatchDateOtherCpnditions(recs[0]));
  //   }
  // }

}