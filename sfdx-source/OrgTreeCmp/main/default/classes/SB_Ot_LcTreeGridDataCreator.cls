/**
 *
 *  SB_Ot_LcTreeGridDataCreator
 *    グリッドのときのデータを作るクラス
 *
 * Copyright (C) 2020 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.2    2020.04.xx  初版 2000レコード表示を目処のリファクタリング で 表示データの生成クラスを固定でインスタンス化してみる。
 *  @Version 1.5    2020.05.07 v1.5 SV_ORGTREE-22 サンブリッジ組織の取引先・取引先責任者のグリッド表示で NullPointerException になる取引先がある。 所有者の参照先でNameがないのがある！
 *
 */
public with sharing class SB_Ot_LcTreeGridDataCreator {

  public virtual class DataCreator {
    public String field { get; private set; }
    public String colId { get; private set; }
    DataCreator() {}
    public DataCreator(String f) {
      this.field = f;
      this.colId = f.removeStart('smartviscaf__').removeEnd('__c');//
    }
    public virtual Map<String, Object> create(SObject record) {
      return new Map<String, Object> { this.colId => record.get(this.field) };
    }
  }

  private with sharing class ContactRoleDataCreator extends DataCreator {
    public ContactRoleDataCreator(String f) {
      super(f);
    }
    public override Map<String, Object> create(SObject record) {
      return new Map<String, Object> { this.colId => SB_Ot_ContactRoleFormatter.makeContactRole((Contact)record) };
    }
  }

  private virtual with sharing class ReferenceDataCreator extends DataCreator {
    private String refField;
    public ReferenceDataCreator(String f) {
      super(f);
      this.refField = f.toLowerCase().removeEndIgnoreCase('id').replaceAll('__c$', '__r');
    }

    public virtual override Map<String, Object> create(SObject record) {
      Map<String, Object> result = new Map<String, Object>();
      // 2020.05.07 v1.5 SV_ORGTREE-22 サンブリッジ組織の取引先・取引先責任者のグリッド表示で NullPointerException になる取引先がある。 所有者の参照先でNameがないのがある！
      SObject ref_obj = record.getSObject(this.refField);
      if (ref_obj != null) {
        result.put(colId + 'Id', ref_obj.get('Id'));
        result.put(colId, ref_obj.get('Name'));
        result.put(colId + 'LinkTo', String.format(System.Label.SB_Ot_RecordDetailUrlFormat, new String[] { (String)ref_obj.get('Id') }));
        System.debug(result);
      }
      return result;
    }
  }

  private with sharing class NameCardReferenceDataCreator extends ReferenceDataCreator {
    public NameCardReferenceDataCreator(String f) {
      super(f);
    }
    //  名刺の最新へリンクしてるか調べる
    private Boolean isReferenceToLastNameCard(SObject obj) {
      Boolean saishin = (Boolean)obj.get('SmartViscaf__Saishin__c');
      Object latest = obj.get('SmartViscaf__Parent__c');
      return latest == null || saishin != false;
    }
    public override Map<String, Object> create(SObject record) {
      Map<String, Object> result = new Map<String, Object>();
      // 念の為こっちも。2020.05.07 v1.5 SV_ORGTREE-22 サンブリッジ組織の取引先・取引先責任者のグリッド表示で NullPointerException になる取引先がある。 所有者の参照先でNameがないのがある！
      SObject ref_obj = record.getSObject(this.refField);
      if (ref_obj != null) {
        result.put(colId + 'Id', ref_obj.get('Id'));
        result.put(colId + 'LinkTo', String.format(System.Label.SB_Ot_RecordDetailUrlFormat, new String[] { (String)ref_obj.get('Id') }));
        if (!isReferenceToLastNameCard(ref_obj)) { //  名刺の最新へリンクしてるか調べる
          // 最新じゃないとき
          String text = String.format(System.Label.SB_Ot_OldNameCardLinkFormat, new String[] { (String)ref_obj.get('Name') });
          result.put(colId, text);  //
        }
        else {
          result.put(colId, ref_obj.get('Name'));
        }
      }
      return result;
    }

  }

  private with sharing class DateDataCreator extends DataCreator {
    public DateDataCreator(String f) {
      super(f);
    }
    public override Map<String, Object> create(SObject record) {
      Object val = record.get(this.field);
      if (val != null) {
        return new Map<String, Object> { this.colId => ((Date)val).format() };
      }
      return new Map<String, Object> ();
    }
  }

  private with sharing class DateTimeDataCreator extends DataCreator {
    public DateTimeDataCreator(String f) {
      super(f);
    }
    public override Map<String, Object> create(SObject record) {
      Object val = record.get(this.field);
      if (val != null) {
        return new Map<String, Object> { this.colId => ((DateTime)val).format() };
      }
      return new Map<String, Object> ();
    }
  }

  private with sharing class LocationDataCreator extends DataCreator {
    private String apiName;
    public LocationDataCreator(String f, Schema.DescribeFieldResult dfr) {
      super(f);
      this.apiName = dfr.getName();
    }
    public override Map<String, Object> create(SObject record) {
      Object val = record.get(this.field);
      if (val != null) {
        Location l = (Location)val;
        return new Map<String, Object> {
          colId + 'Id' => this.apiName,
          colId => String.format(System.Label.SB_Ot_LocationFormat, new String[] { String.valueOf(l.getLatitude()), String.valueOf(l.getLongitude())}),
          colId + 'LinkTo' => String.format(System.Label.SB_Ot_MapUrlFormat, new String[] { String.valueOf(l.getLatitude()), String.valueOf(l.getLongitude())})
        };
      }
      return new Map<String, Object> ();
    }
  }

  private with sharing class AddressDataCreator extends DataCreator {
    public AddressDataCreator(String f) {
      super(f);
    }
    public override Map<String, Object> create(SObject record) {
      Object val = record.get(this.field);
      if (val != null) {
        // 0: Country, 1: CountryCode, 2: PostalCode, 3: State, 4: StateCode, 5: City, 6: Street
        // 0: 国 1: 国コード, 2: 郵便番号, 3: 都道府県, 4: 都道府県コード, 5: 市区郡, 6: 町名・番地
        Address a = (Address)val;
        return new Map<String, Object> { this.colId => String.format(System.Label.SB_Ot_AddressFormat,
            new String[] { String.isNotBlank(a.getCountry())? a.getCountry() : '',
                            String.isNotBlank(a.getCountryCode())? a.getCountryCode() : '',
                            String.isNotBlank(a.getPostalCode())? a.getPostalCode() : '',
                            String.isNotBlank(a.getState())? a.getState() : '',
                            String.isNotBlank(a.getStateCode())? a.getStateCode() : '',
                            String.isNotBlank(a.getCity())? a.getCity() : '',
                            String.isNotBlank(a.getStreet())? a.getStreet() : '' }) };
      }
      return new Map<String, Object> ();
    }
  }

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

  private with sharing class PickListDataCreator extends DataCreator {
    private Map<String, String> pickListValues;
    public PickListDataCreator(String f, Schema.DescribeFieldResult dfr) {
      super(f);
      this.pickListValues = getPickListEntry(dfr);
    }
    public override Map<String, Object> create(SObject record) {
      Object val = record.get(this.field);
      if (val != null) {
        return new Map<String, Object> { this.colId => this.pickListValues.get((String)val) };
      }
      return new Map<String, Object> ();
    }
  }

  // 指定されてる表示項目から、それに応じたデータを作るクラスsをインスタンス化して返す。
  public static Map<String, DataCreator> buildCreators(SB_Ot_SObjectConfig sobjConfig) {
    Map<String, DataCreator> result = new Map<String, DataCreator>();
    for (String f : sobjConfig.gridFields) {
      if (f == 'contactrole' && sobjConfig.otype == Contact.getSObjectType()) {
        result.put(f, new ContactRoleDataCreator(f));
      }
      else {
        Schema.DescribeFieldResult dfr = sobjConfig.fieldMap.get(f).getDescribe();
        switch on dfr.getType() {
          when Reference {
            if (f=='SmartViscaf__NameCard__c' && sobjConfig.showNameCardOld) { //  名刺の最新へリンクしてるか調べる
              result.put(f, new NameCardReferenceDataCreator(f));
            }
            else {
              result.put(f, new ReferenceDataCreator(f));
            }
          }
          when location {
            result.put(f, new LocationDataCreator(f, dfr));
          }
          when Date {
            result.put(f, new DateDataCreator(f));
          }
          when DateTime {
            result.put(f, new DateTimeDataCreator(f));
          }
          when address {
            result.put(f, new AddressDataCreator(f));
          }
          when Picklist {
            result.put(f, new PickListDataCreator(f, dfr));
          }
          when else {
            result.put(f, new DataCreator(f));
          }
        }
      }
    }
    return result;
  }

}