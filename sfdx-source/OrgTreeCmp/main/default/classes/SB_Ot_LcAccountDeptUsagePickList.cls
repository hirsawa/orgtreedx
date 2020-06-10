/**
 *
 *  SB_Ot_LcAccountDeptUsagePickList
 *    アカウント 部門 の利用方法 の動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx
 *
 **/
public class SB_Ot_LcAccountDeptUsagePickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('名称に追加する', 'Label');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    // result.addRow(new VisualEditor.DataRow('階層に展開する', 'Hierarchy'));　　ToDo?
    // result.addRow(new VisualEditor.DataRow('分割して階層に展開する', 'ParseHierarchy'));
    result.addRow(new VisualEditor.DataRow('名称に追加する', 'Label'));
    result.addRow(new VisualEditor.DataRow('使用しない', 'None'));
    return result;
  }
}