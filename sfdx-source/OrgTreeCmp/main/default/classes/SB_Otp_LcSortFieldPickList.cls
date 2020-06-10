/**
 *  SB_Otp_LcSortFieldPickList
 *    「同じ名刺を持つユーザ」LWCの並び変え項目の選択肢
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1    2019.11.xx
 *
 **/
public class SB_Otp_LcSortFieldPickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('オブジェクト', 'object');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    result.addRow(new VisualEditor.DataRow('オブジェクト', 'object'));
    result.addRow(new VisualEditor.DataRow('所有者', 'owner'));
    result.addRow(new VisualEditor.DataRow('作成日', 'createDate'));
    result.addRow(new VisualEditor.DataRow('最終更新日', 'lastDate'));
    return result;
  }
}