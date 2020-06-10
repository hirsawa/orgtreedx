/**
 *
 *  SB_Ot_LcRequestObjectPickList
 *    対象のオブジェクト の動的選択リスト
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1      2019.05.xx
 *
 **/
public class SB_Ot_LcRequestObjectPickList extends VisualEditor.DynamicPickList {
  private VisualEditor.DesignTimePageContext context;
  private SB_Ot_MultiObjectConfig multiConfig;

  public SB_Ot_LcRequestObjectPickList(VisualEditor.DesignTimePageContext context) {
    this.context = context;
    this.multiConfig = SB_Ot_MultiObjectConfig.getInstance();
  }

  public override VisualEditor.DataRow getDefaultValue() {
    VisualEditor.DataRow defaultValue;
    for (SB_Ot_MultiObjectConfig.ObjectLabelName o : this.multiConfig.objects) {
      if (this.context.entityName == o.name || (this.context.entityName=='contact' && o.name == 'account')) {
        defaultValue  = new VisualEditor.DataRow(o.label, o.name);
        break;
      }
    }
    return defaultValue;
  }

  public override VisualEditor.DynamicPickListRows getValues() {
    VisualEditor.DynamicPickListRows  result = new VisualEditor.DynamicPickListRows();
    for (SB_Ot_MultiObjectConfig.ObjectLabelName o : this.multiConfig.objects ) {
      result.addRow(new VisualEditor.DataRow(o.label, o.name));
    }
    return result;
  }
}