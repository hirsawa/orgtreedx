public with sharing class SB_Otp_PersonConfig {

  public class CollateFields {
    private Schema.SObjectType otype;
    public String name { get; private set; }
    public String email { get; private set; }
    public String title { get; private set; }
    public String comapny { get; private set; }
    public String department { get; private set; }
    public CollateFields(Schema.SObjectType otype, String name, String email, String title, String comapny, String department) {
      this.otype = otype;
      this.name = name;
      this.email = email;
      this.title = title;
      this.comapny = comapny;
      this.department = department;
    }
    public Set<String> getFields() {
      return new Set<String> { this.name, this.email, this.title, this.comapny, this.department };
    }

  }

  public Map<SObjectType, CollateFields> otype2CollateFields;

  private SB_Otp_PersonConfig() {
    this.otype2CollateFields = new Map<SObjectType, CollateFields>();
    this.otype2CollateFields.put(Lead.getSObjectType(), new CollateFields(Lead.getSObjectType(), 'Name', 'EMail', 'Title', 'Company', null));
    this.otype2CollateFields.put(Contact.getSObjectType(), new CollateFields(Contact.getSObjectType(), 'Name', 'EMail', 'Title', 'Account.Name', 'Department'));
    if (SB_Ot_Global.isEnableLeadExtension()) {
      this.otype2CollateFields.put(SB_Ot_Global.getNameCardSObjectType(),
            new CollateFields(SB_Ot_Global.getNameCardSObjectType(), 'Name', 'SmartViscaf__email__c', 'Title', 'SmartViscaf__company_name__c', 'SmartViscaf__division__c'));
    }
  }

  public CollateFields getCollateFields(Schema.SObjectType otype) {
    System.assert(this.otype2CollateFields.containsKey(otype));
    return this.otype2CollateFields.get(otype);
  }

  private static SB_Otp_PersonConfig instance;

  public static SB_Otp_PersonConfig getInstance() {
    if (instance==null) {
      instance = new SB_Otp_PersonConfig();
    }
    return instance;
  }

}