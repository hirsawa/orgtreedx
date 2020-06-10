/**
 *  SB_Ot_CmpLauncherControllerTest
 *
 *  SB_Ot_CmpLauncherController のテストクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.03.xx
 *
 **/
@isTest
private class SB_Ot_CmpLauncherControllerTest {

  @TestSetup
  static void setupDB() {
    SB_Ot_TestDB db = new SB_Ot_TestDB();
    db.initialize();
  }

  @isTest
  static void test_SB_Ot_CmpLauncherController_SB_Ot_OrgTree_Lead() {
    List<Lead> leads = [SELECT Id, Name FROM Lead];

    PageReference pageRef = Page.SB_Ot_CmpLauncher;
    System.Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', leads[0].Id);
    ApexPages.currentPage().getParameters().put('retUrl', '/lightning/page/home');
    ApexPages.currentPage().getParameters().put('app', 'ot');
    SB_Ot_CmpLauncherController ctrl = new SB_Ot_CmpLauncherController();
    String lccmp = SB_Ot_CmpLauncherController.APPCD_COMPONENT.get('ot');
    System.assertEquals(lccmp, ctrl.component);
  }

  @isTest
  static void test_SB_Ot_CmpLauncherController_InvalidApp() {
    List<Lead> leads = [SELECT Id, Name FROM Lead];

    PageReference pageRef = Page.SB_Ot_CmpLauncher;
    System.Test.setCurrentPage(pageRef);
    ApexPages.currentPage().getParameters().put('id', leads[0].Id);
    ApexPages.currentPage().getParameters().put('retUrl', '/lightning/page/home');
    ApexPages.currentPage().getParameters().put('app', 'XXXX');
    SB_Ot_CmpLauncherController ctrl = new SB_Ot_CmpLauncherController();
    System.assertEquals(null, ctrl.component);
  }

}