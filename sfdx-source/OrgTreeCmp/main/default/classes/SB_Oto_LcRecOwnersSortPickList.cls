/**
 *  SB_Oto_LcRecOwnersSortPickList
 *    「同じ名刺を持つユーザ」LWCの並び変え項目の選択肢
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.11.xx
 *
 **/
public class SB_Oto_LcRecOwnersSortPickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    Map<String, Schema.SObjectField> uFields = User.getSObjectType().getDescribe().fields.getMap();
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(uFields.get('Name').getDescribe().getLabel(), 'name');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    Map<String, Schema.SObjectField> uFields = User.getSObjectType().getDescribe().fields.getMap();
    result.addRow(new VisualEditor.DataRow(uFields.get('Name').getDescribe().getLabel(), 'name'));
    result.addRow(new VisualEditor.DataRow(uFields.get('Department').getDescribe().getLabel(), 'department'));
    result.addRow(new VisualEditor.DataRow(uFields.get('LastModifiedDate').getDescribe().getLabel(), 'lastDate'));
    result.addRow(new VisualEditor.DataRow(System.Label.SB_Ot_OwnerRecordCount, 'count'));
    return result;
  }
}