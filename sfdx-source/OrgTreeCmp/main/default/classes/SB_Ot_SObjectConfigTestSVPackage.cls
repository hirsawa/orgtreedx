/**
 *
 *  SB_Ot_SObjectConfigTestSVPackage
 *    SB_Ot_SObjectConfig のテストクラス  PackageにSmartViscaが必須にするよう
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2020.01.xx
 *
 */
@isTest
private class SB_Ot_SObjectConfigTestSVPackage
{

  @isTest
  static void test_makeConditions_SmartVisca() {
    SB_Ot_SObjectConfig config = SB_Ot_SObjectConfig.getSObjectConfig(SmartViscaf__NameCard__c.getSObjectType());
    List<String> conditions;
    conditions = config.makeConditions(1, 'latest');
    System.assertEquals(1+1+1, conditions.size());
    conditions = config.makeConditions(1, 'noChangeLatest');
    System.assertEquals(1+3+1, conditions.size());
  }

}