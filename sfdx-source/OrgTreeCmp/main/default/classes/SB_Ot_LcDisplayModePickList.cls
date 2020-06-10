/**
 *
 *  SB_Ot_LcDisplayModePickList
 *    表示形式の動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx
 *  @Version 1.1    2019.11.xx    Grifがデフォルト
 *
 **/
public class SB_Ot_LcDisplayModePickList extends VisualEditor.DynamicPickList {

  public override VisualEditor.DataRow getDefaultValue(){
    VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(Label.SB_Ot_Tree, 'grid');
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    result.addRow(new VisualEditor.DataRow(Label.SB_Ot_Tree, 'tree'));
    result.addRow(new VisualEditor.DataRow(Label.SB_Ot_Grid, 'grid'));
    //result.addRow(new VisualEditor.DataRow('ツリーで切り替え可能', 'TreeChangable'));
    //result.addRow(new VisualEditor.DataRow('グリッドで切り替え可能', 'GridChangable'));
    return result;
  }
}