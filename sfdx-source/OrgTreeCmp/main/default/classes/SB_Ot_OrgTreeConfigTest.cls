/**
 *
 *  SB_Ot_OrgTreeConfigTest
 *    SB_Ot_OrgTreeConfig のテストクラス  基本的なことのテスト カバレッジを稼ぐためにメソッドを個別にテスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.12.xx
 *
 */
@isTest
private class SB_Ot_OrgTreeConfigTest {

  @isTest
  static void test_getInstance() {
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = null;       // 対象のレコードID がないので例外
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

    SB_Ot_OrgTreeConfig config = SB_Ot_OrgTreeConfig.getInstance(req);
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Separator, config.deptParser);
    config.setDeptParser(3);
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Regex, config.deptParser);
  }

  @isTest
  static void test_getEnumFromString() {
    System.assertEquals(SB_Ot_OrgTreeConfig.ItemDisplayMode.Tree, SB_Ot_OrgTreeConfig.getDisplayMode('tree'));
    System.assertEquals(SB_Ot_OrgTreeConfig.ItemDisplayMode.Grid, SB_Ot_OrgTreeConfig.getDisplayMode('grid'));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentUsage.Hierarchy, SB_Ot_OrgTreeConfig.getDepartmentUsage('hierarchy'));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Separator, SB_Ot_OrgTreeConfig.getDepartmentParser('separator'));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Line, SB_Ot_OrgTreeConfig.getDepartmentParser('line'));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Comparision, SB_Ot_OrgTreeConfig.getDepartmentParser('comparision'));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Regex, SB_Ot_OrgTreeConfig.getDepartmentParser('regex'));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Noop, SB_Ot_OrgTreeConfig.getDepartmentParser('noop'));
  }

  @isTest
  static void test_getDepartmentParserEnumFromNum() {
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Separator, SB_Ot_OrgTreeConfig.getDepartmentParser(0));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Line, SB_Ot_OrgTreeConfig.getDepartmentParser(1));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Comparision, SB_Ot_OrgTreeConfig.getDepartmentParser(2));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Regex, SB_Ot_OrgTreeConfig.getDepartmentParser(3));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Noop, SB_Ot_OrgTreeConfig.getDepartmentParser(4));
    System.assertEquals(SB_Ot_OrgTreeConfig.DepartmentParser.Separator, SB_Ot_OrgTreeConfig.getDepartmentParser(5));
  }



}