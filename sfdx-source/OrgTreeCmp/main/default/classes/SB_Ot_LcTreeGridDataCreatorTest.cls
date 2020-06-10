/**
 *
 *  SB_Ot_LcTreeGridDataCreatorTest
 *    SB_Ot_LcTreeGridDataCreator のテストクラス
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.2      2020.4.xx
 *
 */
@isTest
private class SB_Ot_LcTreeGridDataCreatorTest {

  @isTest
  static void test_DataCreator_Contact() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();

    Contact cont = [SELECT Id, Name FROM Contact LIMIT 1];
    cont = new Contact(Id= cont.Id);
    cont.Salutation = 'Mr.';
    cont.EmailBouncedDate = Datetime.now();
    cont.BirthDate = Date.today().addYears(-80);
    cont.MailingCity = '渋谷区';
    cont.MailingState = '東京都';
    cont.MailingCountry = '日本';
    cont.MailingPostalCode = '115-0023';
    // cont.MailingStateCode = '01';
    // cont.MailingCountryCode = 'JPN';
    cont.MailingStreet = '恵比寿南';
    update cont;
    // List<Contact> conts =[SELECT Id, Name FROM Contact];
    SB_Ot_OrgTreeLcController.CreateOrgTreeRequest req = new SB_Ot_OrgTreeLcController.CreateOrgTreeRequest();
    req.selectedId = cont.Id;       // 対象のレコードID
    req.idField = 'id';       //参照するオブジェクト(項目)
    req.displayFormat = 'grid'; // 表示形式
    req.dateRange = 0; // 対象レコードの期日の範囲 n年前から
    req.otherCondition = 'none'; // 対象レコードの条件
    req.orgField = null;   // 組織名の項目
    req.deptField = 'Department';  // 部署名の項目
    req.titleField = 'Title';   // 役職名の項目
    req.gridFields = 'Title, Email, OwnerId, ContactRole, MailingAddress, Salutation, EmailBouncedDate, BirthDate';   // グリッドに表示する項目
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
    Map<String, SB_Ot_LcTreeGridDataCreator.DataCreator> dataCreators = SB_Ot_LcTreeGridDataCreator.buildCreators(SB_Ot_SObjectConfig.getSObjectConfig(Contact.getSObjectType()));
    Contact record = [SELECT Id,Title, Email, OwnerId, Owner.Name, (SELECT Id, Role, IsPrimary, AccountId FROM AccountContactRoles), MailingAddress, Salutation, EmailBouncedDate, BirthDate FROM Contact WHERE Id = :cont.Id LIMIT 1];
    for (String f : dataCreators.keySet()) {
      SB_Ot_LcTreeGridDataCreator.DataCreator dc = dataCreators.get(f);
      Map<String, Object>  values = dc.create(record);
    }
    System.assertEquals(req.gridFields.split(',').size(), dataCreators.size());
  }
}