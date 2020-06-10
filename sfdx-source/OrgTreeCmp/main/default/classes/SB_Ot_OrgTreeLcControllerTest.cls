/**
 * SB_Ot_OrgTreeLcControllerTest
 *    SB_Ot_OrgTreeLcController のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx 初版
 *
 **/
@isTest
private class SB_Ot_OrgTreeLcControllerTest
{
 @TestSetup
 static void setupDB() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();
 }


  @isTest
  static void test_StandardController() {
    List<Account> acnts =[SELECT Id, Name FROM Account];
    ApexPages.StandardController sc = new ApexPages.StandardController(acnts[0]);
    SB_Ot_OrgTreeLcController ctrl = new SB_Ot_OrgTreeLcController(sc);
    System.assert(ctrl.getRecordNameAndId().startsWith(acnts[0].Name));
  }
  // エラー
  @isTest
  static void test_createOrgTree_Exception() {
    List<Account> acnts =[SELECT Id, Name FROM Account];
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = acnts[0].Id;       // 対象のレコードID がないので例外
    req.idField = 'site';       //参照するオブジェクト(項目)
    req.displayFormat = 'grid'; // 表示形式
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
    req.accountAssociation = true; // 親・子の取引先を階層に含める
    req.accountGridFields = null;// 取引先 グリッドに表示する項目
    req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法
    String reqJson = JSON.serialize(req);
    SB_Ot_OrgTreeLcController.CreateOrgTreeResponse response = SB_Ot_OrgTreeLcController.createOrgTree(reqJson);
    System.assert(!response.success);
    System.assert(String.isNotBlank(response.error));
  }



  // createOrgTree のテスト Accountで Tree
  @isTest
  static void test_createOrgTree_Account_Tree() {
    List<Account> acnts =[SELECT Id, Name FROM Account];
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = acnts[0].Id;       // 対象のレコードID
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
    req.accountAssociation = true; // 親・子の取引先を階層に含める
    req.accountGridFields = null;// 取引先 グリッドに表示する項目
    req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法
    String reqJson = JSON.serialize(req);
    SB_Ot_OrgTreeLcController.CreateOrgTreeResponse response = SB_Ot_OrgTreeLcController.createOrgTree(reqJson);
    System.assert(response.items.size() > 0);
  }

  // createOrgTree のテスト Accountで Grid
  @isTest
  static void test_createOrgTree_Account_Grid() {
    List<Account> acnts =[SELECT Id, Name FROM Account];
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = acnts[0].Id;       // 対象のレコードID
    req.idField = 'id';       //参照するオブジェクト(項目)
    req.displayFormat = 'grid'; // 表示形式
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
    req.accountAssociation = true; // 親・子の取引先を階層に含める
    req.accountGridFields = null;// 取引先 グリッドに表示する項目
    req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法
    String reqJson = JSON.serialize(req);
    SB_Ot_OrgTreeLcController.CreateOrgTreeResponse response = SB_Ot_OrgTreeLcController.createOrgTree(reqJson);
    System.assert(response.items.size() > 0);
    System.assert(response.treeGridColumns != null);
    System.assert(response.branchIds.size() > 0);
  }


 // createOrgTree のテスト Accountで Grid
  @isTest
  static void test_createOrgTree_Account_OnCustomConfig() {
    // カスタム設定を変更
    SB_Ot_Global.otConfig.PrioritizeCustomSetting__c = true;
    SB_Ot_Global.otConfig.AccountAssociation__c = true; // 取引先 親・子の取引先を階層に含める#

    List<Account> acnts =[SELECT Id, Name FROM Account WHERE ParentId = null];  // 親取引先ではない
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = acnts[0].Id;       // 対象のレコードID
    req.idField = 'id';       //参照するオブジェクト(項目)
    req.displayFormat = 'grid'; // 表示形式
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
    String reqJson = JSON.serialize(req);
    SB_Ot_OrgTreeLcController.CreateOrgTreeResponse response = SB_Ot_OrgTreeLcController.createOrgTree(reqJson);
    System.assert(response.items.size() > 0);
    System.assert(response.items[0].name ==  acnts[0].Id); // Treeなので、name に ID。ルートの取引先のではない
    System.assert(response.treeGridColumns != null);
    System.assert(response.branchIds.size() > 0);
  }

  // createOrgTree のテスト multiObject 有効 で  Account で Lead を表示
  @isTest
  static void test_createOrgTree_ReferenceIdField_Contact_Account() {
    List<Contact> conts = [SELECT Id, Name, AccountId, Account.Name FROM Contact WHERE AccountId !=null];

    System.Test.startTest();
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = conts[0].Id;       // 対象のレコードID
    req.idField = 'AccountId';       // ID項目
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
    req.accountAssociation = true; // 親・子の取引先を階層に含める
    req.accountGridFields = null;// 取引先 グリッドに表示する項目
    req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法
    // 複数オブジェクト 有効
    // req.multiObjectActive = true;  // 複数のオブジェクトによる構成
    // req.requestObject = 'account'; //  表示したいオブジェクト
    String reqJson = JSON.serialize(req);
    SB_Ot_OrgTreeLcController.CreateOrgTreeResponse response = SB_Ot_OrgTreeLcController.createOrgTree(reqJson);
    System.assert(response.items.size() > 0);
    // System.assertEquals(true, response.multiObjectActive);
    System.assertEquals('account', response.sourceObject);
    // System.assert(response.relateObjects.size() > 0);
    System.assert(response.items[0].label.contains(conts[0].Account.Name));
    System.Test.stopTest();
  }

  // createOrgTree のテスト Accountで Tree
  @isTest
  static void test_createOrgTree_User_Tree() {
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = null;       // 対象のレコードID
    req.idField = 'user';       //参照するオブジェクト(項目)
    req.displayFormat = 'tree'; // 表示形式
    req.dateRange = 0; // 対象レコードの期日の範囲 n年前から
    req.otherCondition = 'active'; // 対象レコードの条件
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
    // // 取引先 特有の設定項目
    // req.accountAssociation = true; // 親・子の取引先を階層に含める
    // req.accountGridFields = null;// 取引先 グリッドに表示する項目
    // req.accountDeptUsage = 'Label'; // 取引先 部署項目の使用方法
    String reqJson = JSON.serialize(req);
    SB_Ot_OrgTreeLcController.CreateOrgTreeResponse response = SB_Ot_OrgTreeLcController.createOrgTree(reqJson);
    System.assert(response.items.size() > 0);
    System.assertEquals('user', response.sourceObject);
     System.assert(response.items[0].label.contains(UserInfo.getOrganizationName()));
  }

}