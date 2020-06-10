/**
 *
 *  SB_Ot_SObjectConfigTest
 *    SB_Ot_SObjectConfig のテストクラス  基本的なことのテスト カバレッジを稼ぐためにメソッドを個別にテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.12.xx
 *
 */
@isTest
private class SB_Ot_SObjectConfigTest
{

  @isTest
  static void test_makeConditions_Account() {
    // テストで、名刺オブジェクトがあることにしておきます。
    SB_Ot_Global.nameCardSObjectType = UserRole.getSObjectType();

    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSObjectType());
    List<String> conditions;
    conditions = config.makeConditions(1, 'haveNC');
    System.assertEquals(1+1, conditions.size());
    conditions = config.makeConditions(1, 'haveLatestNC');
    System.assertEquals(1+2, conditions.size());
    conditions = config.makeConditions(1, 'haveNoChangeLatestNC');
    System.assertEquals(1+4, conditions.size());
  }

  @isTest
  static void test_makeConditions_Lead() {
    // テストで、名刺オブジェクトがあることにしておきます。
    SB_Ot_Global.nameCardSObjectType = UserRole.getSObjectType();

    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(Lead.getSObjectType());
    List<String> conditions;
    conditions = config.makeConditions(1, 'haveNC');
    System.assertEquals(1+1+1, conditions.size());
    conditions = config.makeConditions(1, 'haveLatestNC');
    System.assertEquals(1+2+1, conditions.size());
    conditions = config.makeConditions(1, 'haveNoChangeLatestNC');
    System.assertEquals(1+4+1, conditions.size());
  }

  @isTest
  static void test_makeConditions_NameCard() {
    if (!SB_Ot_Global.isEnableSmartVisca()) {
      return;
    }
    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(SB_Ot_Global.getNameCardSObjectType());
    List<String> conditions;
    conditions = config.makeConditions(1, 'latest');
    System.assertEquals(1+1+1, conditions.size());
    conditions = config.makeConditions(1, 'noChangeLatest');
    System.assertEquals(1+3+1, conditions.size());
  }

  @isTest
  static void test_makeConditions_User() {
    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(User.getSObjectType());
    List<String> conditions;
    conditions = config.makeConditions(1, 'active');
    System.assertEquals(1+2, conditions.size());
    conditions = config.makeConditions(1, 'sameOrg');
    System.assertEquals(1+2, conditions.size());
    conditions = config.makeConditions(1, 'sameOrgActive');
    System.assertEquals(1+3, conditions.size());
  }

  @isTest
  static void test_getQueryFields_Contact() {
    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(Contact.getSObjectType());

    Set<String> fields = config.getQueryFields();
    System.assert(fields.contains('name'));
    System.assert(fields.contains('title'));
  }

  @isTest
  static void test_getOrderByFields_Contact() {
    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(Contact.getSObjectType());

    List<String> fields = config.getOrderByFields();
    System.assert(fields.contains('department'));
    System.assert(fields.contains('title'));
  }

  @isTest
  static void test_getOrderByFields_Lead() {
    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(Lead.getSObjectType());

    List<String> fields = config.getOrderByFields();
    System.assert(fields.contains('company'));
    System.assert(fields.contains('title'));
  }

  @isTest
  static void test_makeSObjectConfig_Contact() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();

    List<Contact> conts =[SELECT Id, Name FROM Contact];
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = conts[0].Id;       // 対象のレコードID
    req.idField = 'id';       //参照するオブジェクト(項目)
    req.displayFormat = 'tree'; // 表示形式
    req.dateRange = 0; // 対象レコードの期日の範囲 n年前から
    req.otherCondition = 'none'; // 対象レコードの条件
    req.orgField = null;   // 組織名の項目
    req.deptField = 'Department';  // 部署名の項目
    req.titleField = 'Title';   // 役職名の項目
    req.gridFields = 'Title, Email, OwnerId';   // グリッドに表示する項目
    req.deptParser = 'Separator';  // 部門、部署の分割方法
    // req.showTitle = true;  // 役職を表示する
    // req.showOwner = true;   // 所有者を表示する
    // req.showEMail = true;   // メアドを表示する
    // req.gridLabelNoExtra = true;   // グリッドのラベルには 役職等を表示しない
    req.maxRecs = 1000; //  対象レコード数の制限
    // 取引先 特有の設定項目
    req.accountAssociation = false; // 親・子の取引先を階層に含める  カスタム設定と相違！！
    req.accountGridFields = null;// 取引先 グリッドに表示する項目
    req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法

    SB_Ot_SObjectConfig.makeSObjectConfig(Contact.getSObjectType(), req);
    System.assertEquals(0, SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Account.sObjectType).dateRange);
    System.assertEquals(0, SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Contact.sObjectType).dateRange);
  }

  @isTest
  static void test_makeSObjectConfig_Lead() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();

    List<Lead> leads =[SELECT Id, Name FROM Lead];
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = leads[0].Id;       // 対象のレコードID
    req.idField = 'id';       //参照するオブジェクト(項目)
    req.displayFormat = 'tree'; // 表示形式
    req.dateRange = 0; // 対象レコードの期日の範囲 n年前から
    req.otherCondition = 'none'; // 対象レコードの条件
    req.orgField = null;   // 組織名の項目
    req.deptField = null;  // 部署名の項目
    req.titleField = 'Title';   // 役職名の項目
    req.gridFields = 'Title, Email, OwnerId';   // グリッドに表示する項目
    req.deptParser = 'Separator';  // 部門、部署の分割方法
    // req.showTitle = true;  // 役職を表示する
    // req.showOwner = true;   // 所有者を表示する
    // req.showEMail = true;   // メアドを表示する
    // req.gridLabelNoExtra = true;   // グリッドのラベルには 役職等を表示しない
    req.maxRecs = 1000; //  対象レコード数の制限
    // 取引先 特有の設定項目
    req.accountAssociation = false; // 親・子の取引先を階層に含める  カスタム設定と相違！！
    req.accountGridFields = null;// 取引先 グリッドに表示する項目
    req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法

    SB_Ot_SObjectConfig.makeSObjectConfig(Lead.getSObjectType(), req);
    System.assertEquals(0, SB_Ot_SObjectConfig.sobj2SObjectConfig.get(Lead.sObjectType).dateRange);
  }


  @isTest
  static void test_makeDateRangeCondition_FY() {
    // カスタム設定のデフォルト値をクリア
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.DateRageUseFiscalYear__c = true;
    insert config;

    SB_Ot_SObjectConfig objConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSObjectType());
    System.assertEquals(System.Label.SB_Ot_DateRangeCondition_THISFY, objConfig.makeDateRangeCondition(0));
    System.assert(objConfig.makeDateRangeCondition(1).contains('LAST_N_FISCAL_YEARS:1'));
  }

  @isTest
  static void test_makeDateRangeCondition_CY() {
    // カスタム設定のデフォルト値をクリア
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.DateRageUseFiscalYear__c = false;
    insert config;

    SB_Ot_SObjectConfig objConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.getSObjectType());
    System.assertEquals(System.Label.SB_Ot_DateRangeCondition_THISCY, objConfig.makeDateRangeCondition(0));
    System.assert(objConfig.makeDateRangeCondition(1).contains('LAST_N_YEARS:1'));
  }

  @isTest
  static void test_makeDateRangeCondition_NC_FY() {

    if (!SB_Ot_Global.isEnableSmartVisca()) {
      return;
    }
    // カスタム設定のデフォルト値をクリア
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.DateRageUseFiscalYear__c = true;
    insert config;

    SB_Ot_SObjectConfig objConfig = SB_Ot_SObjectConfig.getSObjectConfig(SB_Ot_Global.getNameCardSObjectType());
    System.assertEquals(System.Label.SB_Ot_DateRangeCondition_NC_THISFY, objConfig.makeDateRangeCondition(0));
    System.assert(objConfig.makeDateRangeCondition(1).contains('LAST_N_FISCAL_YEARS:1'));
  }

  @isTest
  static void test_makeDateRangeCondition_NC_CY() {

    if (!SB_Ot_Global.isEnableSmartVisca()) {
      return;
    }
    // カスタム設定のデフォルト値をクリア
    OrgTreeConfig__c config = new OrgTreeConfig__c();
    config.DateRageUseFiscalYear__c = false;
    insert config;

    SB_Ot_SObjectConfig objConfig = SB_Ot_SObjectConfig.getSObjectConfig(SB_Ot_Global.getNameCardSObjectType());
    System.assertEquals(System.Label.SB_Ot_DateRangeCondition_NC_THISCY, objConfig.makeDateRangeCondition(0));
    System.assert(objConfig.makeDateRangeCondition(1).contains('LAST_N_YEARS:1'));
  }

}