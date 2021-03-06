/**
 *  SB_Ot_LcDeptFieldPickList
 *      部署名項目の選択肢
 *
 *  
 **/
public class SB_Ot_LcDeptFieldPickList extends SB_Ot_LcSObjectFieldPickList {
  public SB_Ot_LcDeptFieldPickList(VisualEditor.DesignTimePageContext context) {
    super(context);
    if (context.entityName == 'Account') {
      // Accountの部署とか、役職とかは選択しなくて、Contactの方
      this.otype = Contact.getSObjectType();
    }
    else {
      this.otype = Schema.getGlobalDescribe().get(context.entityName);
    }
    this.fieldMap = this.otype.getDescribe().fields.getMap();
    try {    
      this.objConfig = SB_Ot_SObjectConfig.getSObjectConfig(this.otype);
      // Schema.DescribeSObjectResult dsr = ;
    }
    catch(Exception e) {
      System.debug(LoggingLevel.INFO, e.getMessage());
    }
  }

  protected override String getDefaultField() {
    if (this.objConfig == null) {
      return null;
    }
    return this.objConfig.deptField;
  }
    
  protected override Set<Schema.DisplayType> getEnableDisplayTypes() {
    return new Set<Schema.DisplayType> { Schema.DisplayType.STRING, Schema.DisplayType.TEXTAREA };
  }

}