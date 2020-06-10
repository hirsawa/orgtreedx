public with sharing class SB_Otp_PersonRecord {
  private static String urlFormat {
    get {
      if (urlFormat == null) {
        if (UserInfo.getUiThemeDisplayed().startsWithIgnoreCase('Theme4')) {
          urlFormat = '/one/one.app#/sObject/{0}/view';
        }
        else {
          urlFormat = '/{0}';
        }
      }
      return urlFormat;
    }
    private set;
  }


  @AuraEnabled public Id id { get; protected set; }
  @AuraEnabled public Map<String, Object> values { get; protected set; }

  public SB_Otp_PersonRecord(SObject rec) {
    this.id = rec.Id;

  }

}