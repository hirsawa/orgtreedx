/**
 *
 *  SB_Ot_LcTreeGridDataCreator
 *    グリッドのときのデータを作るクラス
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.2    2020.04.xx  初版
 */
public with sharing class SB_Oto_DataFormatter {

  public class RecordField {
    private String label { get; private set; }
    @AuraEnabled public Object value { get; private set; }
    @AuraEnabled public boolean email { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    @AuraEnabled public boolean phone { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    @AuraEnabled public boolean url { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    @AuraEnabled public boolean other { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
    public RecordField(String label, Object value) {
      this.label = label.toLowerCase();
      this.value = value;
      this.other = true;
    }

    public void setType(Schema.DisplayType dt) {
      this.other = false;
      switch on dt {
        when EMail {
          this.email = true;
        }
        when Phone {
          this.phone = true;
        }
        when URL {
          this.url = true;
        }
        when else {
          this.other = true;
        }
      }
    }

  }

  public virtual class DataFormatter {
    public Schema.DescribeFieldResult dfr { get; protected set; }
    public DataFormatter(Schema.DescribeFieldResult dfr) {
      this.dfr = dfr;
    }
    public virtual String format(Object val) {
      return (String)val;
    }
    public virtual RecordField build(Object val) {
      RecordField result = new RecordField(this.dfr.getName(), (String)val);
      result.setType(this.dfr.getType());
      return result;
    }
  }

  @TestVisible
  private with sharing class NumberFormatter extends DataFormatter {
    public NumberFormatter(Schema.DescribeFieldResult dfr) {
      super(dfr);
    }

    public override String format(Object val) {
      String result;
      if (val instanceOf Decimal) {
        result = ((Decimal)val).format();
      }
      else {
        result = String.valueOf(val);
      }
      return result;
    }

    public override RecordField build(Object val) {
      return new RecordField(this.dfr.getName(), String.format(Label.SB_Oto_DigestFormat, new String[] { this.dfr.getLabel(), format(val) }));
    }
  }

  @TestVisible
  private with sharing class DateFormatter extends DataFormatter {
    public DateFormatter(Schema.DescribeFieldResult dfr) {
      super(dfr);
    }
    public override String format(Object val) {
      System.assert(val != null);
      System.assert(val instanceOf Date);
      return ((Date)val).format();
    }
    public override RecordField build(Object val) {
      System.assert(val != null);
      System.assert(val instanceOf Date);
      String d = String.format(Label.SB_Oto_DigestFormat, new String[] { this.dfr.getLabel(), ((Date)val).format() });
      return new RecordField(this.dfr.getName(), d);
    }

  }

  @TestVisible
  private with sharing class DateTimeFormatter extends DataFormatter {
    public DateTimeFormatter(Schema.DescribeFieldResult dfr) {
      super(dfr);
    }
    public override String format(Object val) {
      System.assert(val != null);
      System.assert(val instanceOf DateTime);
      return ((DateTime)val).format();
    }
    public override RecordField build(Object val) {
      System.assert(val != null);
      System.assert(val instanceOf DateTime);
      String d = String.format(Label.SB_Oto_DigestFormat, new String[] { this.dfr.getLabel(), ((DateTime)val).format() });
      return new RecordField(this.dfr.getName(), d);
    }
  }

  @TestVisible
  private with sharing class AddressFormatter extends DataFormatter {
    public AddressFormatter(Schema.DescribeFieldResult dfr) {
      super(dfr);
    }
    public override String format(Object val) {
      System.assert(val != null);
      System.assert(val instanceOf Address);
      Address a = (Address)val;
      return String.format(System.Label.SB_Ot_AddressFormat,
        new String[] { String.isNotBlank(a.getCountry())? a.getCountry() : '',
                        String.isNotBlank(a.getCountryCode())? a.getCountryCode() : '',
                        String.isNotBlank(a.getPostalCode())? a.getPostalCode() : '',
                        String.isNotBlank(a.getState())? a.getState() : '',
                        String.isNotBlank(a.getStateCode())? a.getStateCode() : '',
                        String.isNotBlank(a.getCity())? a.getCity() : '',
                        String.isNotBlank(a.getStreet())? a.getStreet() : '' });
    }
    public override RecordField build(Object val) {
      return new RecordField(this.dfr.getName(), format(val));
    }
  }

  @TestVisible
  private static Map<String, String> getPickListEntry(Schema.DescribeFieldResult dfr) {
    System.assertEquals(Schema.DisplayType.Picklist, dfr.getType());
    Map<String, String> result = new Map<String, String>();
    try {
      List<Schema.PicklistEntry> entries = dfr.getPicklistValues();
      for (Schema.PicklistEntry ent : entries) {
        if (ent.isActive()) {
          result.put(ent.getValue(), ent.getLabel());
        }
        if (ent.isDefaultValue()) {
          System.debug('Default : ' + ent.getLabel());
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
    return result;
  }

  @TestVisible
  private with sharing class PicklistFormatter extends DataFormatter {
    private Map<String, String> pickListValues;
    public PicklistFormatter(Schema.DescribeFieldResult dfr) {
      super(dfr);
      this.pickListValues = getPickListEntry(dfr);
    }
    public override String format(Object val) {
      System.assert(val != null);
      System.assert(val instanceOf String);
      return this.pickListValues.get((String)val);
    }
    public override RecordField build(Object val) {
      return new RecordField(this.dfr.getName(), format(val));
    }
  }

  @TestVisible
  private static Map<String, DataFormatter> formatters;

  public static DataFormatter getDataFormatter(String f) {
    System.assert(formatters != null);
    return formatters.get(f);
  }

  @TestVisible
  private static final Set<Schema.DisplayType> ENABLE_DISPLAY_TYPE = new Set<Schema.DisplayType> {
    Schema.DisplayType.address,
    Schema.DisplayType.Date,
    Schema.DisplayType.DateTime,
    Schema.DisplayType.Double,
    Schema.DisplayType.Email,
    Schema.DisplayType.Integer,
    Schema.DisplayType.Long,
    Schema.DisplayType.Phone,
    Schema.DisplayType.Picklist,
    Schema.DisplayType.String,
    Schema.DisplayType.URL
  };

  public static Boolean isEnableDisplayType(Schema.DisplayType dt) {
    return SB_Oto_DataFormatter.ENABLE_DISPLAY_TYPE.contains(dt);
  }

  public static void createFormatters(List<Schema.DescribeFieldResult> dfrs) {
    if (formatters == null) {
      formatters = new Map<String, DataFormatter>();
    }
    for (Schema.DescribeFieldResult dfr : dfrs) {
      switch on dfr.getType() {
        when Date {
          formatters.put(dfr.getName(), new DateFormatter(dfr));
        }
        when DateTime {
          formatters.put(dfr.getName(), new DateTimeFormatter(dfr));
        }
        when address {
          formatters.put(dfr.getName(), new AddressFormatter(dfr));
        }
        when Picklist {
          formatters.put(dfr.getName(), new PicklistFormatter(dfr));
        }
        when Double, Integer, Long {
          formatters.put(dfr.getName(), new NumberFormatter(dfr));
        }
        when else {
          formatters.put(dfr.getName(), new DataFormatter(dfr));
        }
      }
    }
  }

}