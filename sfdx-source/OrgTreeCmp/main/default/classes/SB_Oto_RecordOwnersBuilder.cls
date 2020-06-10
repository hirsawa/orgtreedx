/**
 *  SB_Oto_RecordOwnersBuilder
 *  同じアカウント配下のコンタクトを持つユーザ Lightning Web Component の処理の実態
 *
 *  @author sawano
 *  @Version1 v1.1 2019.11.xx
 *
 **/
public with sharing class SB_Oto_RecordOwnersBuilder {
  private Id targetId; // 対象のアカウント or コンタクト のレコードID
  // private Boolean includeCurrentOwner;  // このレコード所有者を含める
  private Boolean includeInactiveUser;  // 無効なユーザも含める
  private Boolean includeAccountOwner; // 取引先の所有者を含む
  private Boolean accountAssociation; // 親取引先配下のアカウント配下のコンタクトの所有者全て
  private Boolean showLastModifiedDate; // 最終更新日を表示する
  private String titleFields;  // 所属役所の表示項目
  private String fields;        // ユーザの表示項目
  private String sortField;   // 並び順に使う項目(初期値)
  private Boolean sortAsc;   // 昇順
  //
  private static TitileFormatter titleFormatter;
  @TestVisible private static void createTitileFormatter(String titleFields) {
    titleFormatter = new JoinSpaceTitleFormatter(User.sObjectType, titleFields);
  }
  //
  private static ItemListCreater itemListCreater;
  @TestVisible private static void createItemListCreator(String fields) {
    itemListCreater = new ItemListCreater(fields);
  }

  @TestVisible
  private with sharing class RecordLabelFormatter {
    private TitileFormatter accountLabelFormatter;
    private TitileFormatter contactLabelFormatter;
    public RecordLabelFormatter() {
      accountLabelFormatter = new JoinSpaceTitleFormatter(Account.sObjectType, 'Name, Site');
      contactLabelFormatter = new JoinSpaceTitleFormatter(Contact.sObjectType, 'Name, Departmnet, Title');
    }
    public String format(SObject obj) {
      if (obj.getSObjectType() == Contact.getSObjectType()) {
        return contactLabelFormatter.format(obj);
      }
      else if (obj.getSObjectType() == Account.getSObjectType()) {
        return accountLabelFormatter.format(obj);
      }
      return null;
    }
  }
  private static RecordLabelFormatter recordLabelFormatter {
    get {
      if (recordLabelFormatter == null) {
        recordLabelFormatter = new RecordLabelFormatter();
      }
      return recordLabelFormatter;
    }
    private set;
  }
  // // クエリするユーザの項目
  // private static final Set<String> USER_FIELDS = new Set<String> {
  //   'id',
  //   'name',
  //   'companyname',
  //   'country',
  //   'department',
  //   'title',
  //   'email',
  //   'phone',
  //   'fax',
  //   'mobilephone',
  //   'employeenumber'};

  private static final String NAMECARD_QUERY = 'SELECT Id, Name, OwnerId, Parent__c, tenshokugonomeishi__c, card_exchange_date__c, company_name__c, division__c, title_name__c FROM NameCard__c WHERE {0} ORDER BY OwnerId, card_exchange_date__c {1} NULLS FIRST';
  private static final String USER_QUERY = 'SELECT {0} FROM User WHERE Id in :ownerIds {1} {2}';

  private static final String ORDER_DEPT = 'ORDER BY CompanyName {0} NULLS LAST, Department {0} NULLS LAST';
  private static final String ORDER_NAME = 'ORDER BY Name {0}';

  // Chatterが有効？ プロファイル画像がある
  private static Boolean enableFeedItem {
    get {
      if (enableFeedItem == null) {
        if (System.Test.isRunningTest() == false) {
          enableFeedItem = ConnectApi.Organization.getSettings().features.chatter;
        }
        else {
          enableFeedItem = false;
        }
      }
      return enableFeedItem;
    }
    private set;
  }

  public SB_Oto_RecordOwnersBuilder(
        Id targetId,
        // Boolean includeCurrentOwner,  // このレコード所有者を含める
        Boolean includeInactiveUser,  // 無効なユーザも含める
        Boolean includeAccountOwner,  // 取引先の所有者を含む
        // Boolean onlyLastestContacts, // 最新の（同じメアドで最終更新日の最新の）コンタクトにしぼる
        Boolean accountAssociation, // 親・子取引先の所有者を含める
        Boolean showLastModifiedDate, // 最終更新日を表示する
        String sortField, // 並び順(初期値)
        Boolean sortAsc,   // 昇順
        String titleFields,  // 所属役所の表示項目
        String fields) {       // ユーザの表示項目 ToDo
    this.targetId = targetId;
    // this.includeCurrentOwner = includeCurrentOwner;  // このレコード所有者を含める
    this.includeInactiveUser = includeInactiveUser;  // 無効なユーザも含める
    this.includeAccountOwner = includeAccountOwner;  // 取引先の所有者を含む
    this.accountAssociation = accountAssociation; // 親取引先配下のアカウント配下のコンタクトの所有者全て
    this.showLastModifiedDate = showLastModifiedDate;
    this.sortField = String.isNotBlank(sortField) ? sortField : 'name'; // 並び順(初期値)
    this.sortAsc = sortAsc;   // 昇順
    this.titleFields = String.isNotBlank(titleFields) ? titleFields : 'CompanyName, Department, Title';// 所属役所の表示項目
    // this.titleFormatter = new JoinSpaceTitleFormatter(titleFields);
    SB_Oto_RecordOwnersBuilder.createTitileFormatter(this.titleFields);
    this.fields = String.isNotBlank(fields) ? fields : 'EMail, Phone';        // ユーザの表示項目
    SB_Oto_RecordOwnersBuilder.createItemListCreator(this.fields);
  }

  public enum SortKey { NAME, DEPT, LASTDATE, COUNT }

  private static Map<String, SortKey> SORT_KEY_MAP = new Map<String, SortKey> {
    'name' => SortKey.NAME,
    'department' => SortKey.DEPT,
    'lastDate' => SortKey.LASTDATE,
    'count' => SortKey.COUNT
  };

  @TestVisible private static SortKey ownerSortKey = SortKey.Name;
  @TestVisible private static Boolean ownerSortAsc = true;

  private static final Set<String> PHONE_FIELDS = new Set<String> {
    'phone', 'mobilephone'
  };

  // public class SB_Oto_DataFormatter.RecordField {
  //   private String label { get; private set; }
  //   @AuraEnabled public Object value { get; private set; }
  //   @AuraEnabled public boolean email { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
  //   @AuraEnabled public boolean phone { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
  //   @AuraEnabled public boolean url { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
  //   @AuraEnabled public boolean other { get; private set; }     // 項目の型 0: その他 1: 電話(Fax除く) 2:EMail
  //   public SB_Oto_DataFormatter.RecordField(String label, Object value) {
  //     this.label = label.toLowerCase();
  //     this.value = value;
  //     this.phone = PHONE_FIELDS.contains(this.label);
  //     this.email = this.label == 'email';
  //     this.other = !this.phone && !this.email;
  //   }
  // }

  public with sharing class RecordOwner implements Comparable {
    @AuraEnabled public Id id { get; private set; }
    @AuraEnabled public String photoUrl { get; private set; }
    @AuraEnabled public String deptTitle { get; private set; }

    @AuraEnabled public String name { get; private set; }
    @AuraEnabled public String alias { get; private set; }
    // @AuraEnabled public String email { get; private set; }
    // @AuraEnabled public String phone { get; private set; }
    // @AuraEnabled public String mobilePhone { get; private set; }
    private Datetime lastDate;
    @AuraEnabled public Id lastId { get; private set; }  // 最終更新日の最新のレコードのID
    @AuraEnabled public String lastModifiedDate { get; private set; }
    @AuraEnabled public String department { get; private set; }
    // @AuraEnabled public Map<String, Object> values { get; private set; }
    @AuraEnabled public List<SB_Oto_DataFormatter.RecordField> items { get; private set; }
    @AuraEnabled public String recordLabel { get; private set; }
    @AuraEnabled public Integer recordCount { get; private set; } // レコード所有数
    private List<SObject> recs;  // このユーザが所有者である Account　または Contact

    public RecordOwner(User u, List<SObject> recs) {
      Map<String, Object> values = new Map<String, Object>();
      values.putAll(u.getPopulatedFieldsAsMap());
      this.id = (Id)values.get('Id');
      // if (enableFeedItem) {
      //   // this.photoUrl = (String)values.get('FullPhotoUrl');
      //   this.photoUrl = (String)values.get('SmallPhotoUrl');
      // }
      if (!System.Test.isRunningTest()) {
        // ConnectApi はテストでは 例外発生する。SeeAllDataにすると別の問題あるし
        ConnectApi.Photo photo = ConnectApi.UserProfiles.getPhoto(null, this.id);
        this.photoUrl = photo.smallPhotoUrl;
      }
      this.name = (String)values.get('Name');
      this.alias = (String)values.get('Alias');
      // this.email = (String)values.remove('Email');
      // this.phone = (String)values.remove('Phone');
      // this.mobilePhone = (String)values.remove('MobilePhone');
      this.department = (String)values.get('Department');
      this.deptTitle = SB_Oto_RecordOwnersBuilder.titleFormatter.format(u);
      this.items = SB_Oto_RecordOwnersBuilder.itemListCreater.create(u);
      this.recordCount = 0;
      this.recs = new List<SObject>();
      addRecords(recs);
    }

    private void addRecords(List<SObject> recs) {
      this.recs.addAll(recs);
      for (SObject rec : recs) {
        Datetime newDate = (Datetime)rec.get('LastModifiedDate');
        if (this.lastDate == null || lastDate < newDate) {
          this.lastId = rec.Id;
          this.lastDate = newDate;
          this.lastModifiedDate = String.valueOf(newDate); // 指定した date を表す string を、標準の「yyyy-MM-dd」形式で返します。
          this.recordLabel = SB_Oto_RecordOwnersBuilder.recordLabelFormatter.format(rec);
        }
      }
      this.recordCount = this.recs.size();
    }

    public Integer compareTo(Object compareTo) {
      RecordOwner other = (RecordOwner)compareTo;
      Object thisKey;
      Object otherKey;
      switch on ownerSortKey {
        when DEPT {
          thisKey = this.department;
          otherKey = other.department;
        }
        when LASTDATE {
          thisKey = this.lastDate;
          otherKey = other.lastDate;
        }
        when COUNT {
          thisKey = this.recordCount;
          otherKey = other.recordCount;
        }
        when else {
          thisKey = this.name;
          otherKey = other.name;
        }
      }
      if (thisKey == otherKey) {
        return 0;
      }
      else if (otherKey!= null && (thisKey == null ||
                                    (thisKey instanceOf String && (String)thisKey > (String)otherKey) ||
                                    (thisKey instanceOf Integer && (Integer)thisKey > (Integer)otherKey) ||
                                    (thisKey instanceOf Datetime && (Datetime)thisKey > (Datetime)otherKey))) {
        return ownerSortAsc ? 1 : -1;
      }
      else {
        return ownerSortAsc ? -1: 1;
      }
    }
  }

  public abstract class LwcResponse {
    @AuraEnabled public Boolean success { get; private set; }
    @AuraEnabled public String message { get; private set; }

    public LwcResponse() {
      this.success = true;
    }
    public void setException(Exception e) {
      this.message = e.getMessage();
      this.success = false;
    }
  }

  public with sharing class GetRecordOwnersResponse extends LwcResponse {
    @AuraEnabled public String sortField { get; private set; }
    @AuraEnabled public Boolean sortAsc { get; private set; }
    @AuraEnabled public Id targetId { get; private set; }
    @AuraEnabled public List<RecordOwner> owners { get; private set; }
    // @AuraEnabled public List<NameCard__c> cards { get; private set; }
    @AuraEnabled public Integer count { get; private set; }
    // @AuraEnabled public Integer getCardCount() { return this.cards.size(); }

    public GetRecordOwnersResponse() {
      this.owners = new List<RecordOwner>();
    }
    public void init(ID targetId, String sortField, Boolean sortAsc) {
      this.targetId = targetId;
      this.sortField = sortField;
      this.sortAsc = sortAsc;
    }

    public void addOwner(User u, List<SObject> recs) {
      try {
        this.owners.add(new RecordOwner(u, recs));
      }
      catch(Exception e) {
        this.message = e.getMessage();
        this.success = false;
      }
    }

    // public void addCards(List<NameCard__c> cards) {
    //   this.cards = new List<NameCard__c>(cards);
    // }

    public void finalize() {
      ownerSortKey = SORT_KEY_MAP.get(this.sortField);
      ownerSortAsc = this.sortAsc;
      this.owners.sort();   // ソートが必要なのは 名刺交換日のときだけだけど
      this.count = this.owners.size();
    }

  }

  // 所属、役職等の表示クラス の基底
  @TestVisible
  private abstract class TitileFormatter {
    @TestVisible protected List<String> titleFields;
    public List<String> getTitleFields() { return titleFields; }
    private List<Schema.DescribeFieldResult> dfrs = new List<Schema.DescribeFieldResult>();

    public TitileFormatter(SObjectType otype, String sourceText) {
      // this.titleFormat = sourceText;
      this.titleFields = new List<String>();
      this.dfrs = new List<Schema.DescribeFieldResult>();
      List<String> fields = parseTitleFields(sourceText.toLowerCase());
      Map<String, Schema.SObjectField > fMap = otype.getDescribe().fields.getMap();
      for(String f : fields) {
        if (fMap.containsKey(f) && SB_Oto_DataFormatter.isEnableDisplayType(fMap.get(f).getDescribe().getType())) {
          // 有効なAPI名 で、所定のDisplayTypeののみ
          this.titleFields.add(f);
          this.dfrs.add(fMap.get(f).getDescribe());
        }
      }
      SB_Oto_DataFormatter.createFormatters(this.dfrs);
    }
    private abstract List<String> parseTitleFields(String text);
    public abstract String format(SObject o);
  }

  // 所属、役職等の表示クラス 1
  // 不完全、こもじにしちゃってるのと、無効な項目APIを残すので
  @TestVisible
  private with sharing class ReplaceTitileFormatter extends TitileFormatter {
    @TestVisible private String titleFormat;   // String text = '{CompanyName}{Department} {Title} {XXXX__c}';

    public ReplaceTitileFormatter(SObjectType otype, String sourceText) {
      super(otype, sourceText);
      this.titleFormat = sourceText.toLowerCase();      // ToDo
      for (Integer n = 0; n < this.titleFields.size(); n++) {
        String f = this.titleFields.get(n);
        this.titleFormat = this.titleFormat.replaceAll(f, String.valueOf(n)); // 同じのは前の数字を使う。後のは、なくなってるけど、このステップは通す
      }
    }

    private override List<String> parseTitleFields(String text) {
      List<String> result = new List<String>();
      if (String.isBlank(text)) {
        return result;
      }
      Pattern ptn = Pattern.compile('\\{([a-zA-Z0-9_]+?)\\}');
      Matcher matcher = ptn.matcher(text);
      while (matcher.find()) {
        if (matcher.groupCount() == 1) {
          // マッピングに追加
          result.add(matcher.group(1));
        }
      }
      return result;
    }

    public override String format(SObject obj) {
      List<String> values = new List<String>();
      // Map<String, Object> f2v = obj.getPopulatedFieldsAsMap();
      for (Schema.DescribeFieldResult dfr : this.dfrs) {
        Object val = obj.get(dfr.getName());
        if (val != null) {
          String d = SB_Oto_DataFormatter.getDataFormatter(dfr.getName()).format(val);
          values.add(d);
        }
        else {
          values.add(''); // NULLの項目も必要
        }
      }
      return String.format(this.titleFormat, values);
    }

  } // private with sharing class ReplaceTitileFormatter extends TitileFormatter {

  // 所属、役職等の表示クラス 2
  @TestVisible
  private with sharing class JoinSpaceTitleFormatter extends TitileFormatter {
    public JoinSpaceTitleFormatter(SObjectType otype, String sourceText) {
      super(otype, sourceText);
    }

    private override List<String> parseTitleFields(String text) {
      List<String> result = new List<String>();
      if (String.isNotBlank(text)) {
        result.addAll(text.split(',\\s*'));
      }
      return result;
    }

    public override String format(SObject obj) {
      List<String> values = new List<String>();
      for (Schema.DescribeFieldResult dfr : this.dfrs) {
        Object val = obj.get(dfr.getName());
        if (val != null) {
          String d = SB_Oto_DataFormatter.getDataFormatter(dfr.getName()).format(val);
          values.add(d);
        }
      }
      return String.join(values, ' ');
    }

  } //private with sharing class JoinSpaceTitleFormatter extends TitileFormatter {


  private static final Set<Schema.DisplayType> enableDisplayTypes = new Set<Schema.DisplayType> {
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

  private class ItemListCreater {
    private List<String> fields;    // 全部小文字のAPI名
    public List<String> getFields() { return fields; }
    // private List<String> camelFields;    // API名
    private List<Schema.DescribeFieldResult> dfrs;

    public ItemListCreater(String source) {
      this.fields = new List<String>();
      // this.camelFields = new List<String>();
      this.dfrs = new List<Schema.DescribeFieldResult>();
      Map<String, Schema.SObjectField > fMap = User.sObjectType.getDescribe().fields.getMap();
      for(String f : source.toLowerCase().split(',\\s*')) {
        if (fMap.containsKey(f) && SB_Oto_DataFormatter.isEnableDisplayType(fMap.get(f).getDescribe().getType())) {
          // 有効なAPI名 で 文字列型のみ
          this.fields.add(f);
          // this.camelFields.add(fMap.get(f).getDescribe().getName());
          dfrs.add(fMap.get(f).getDescribe());
        }
      }
      // フォーマッタを追加
      SB_Oto_DataFormatter.createFormatters(this.dfrs);
    }

    public List<Object> create(Map<String, Object> f2v) {
      List<Object> result = new List<Object>();
      // // Map<String, Object> f2v = rec.getPopulatedFieldsAsMap();
      // for (String f : f2v.keySet()) {
      //   if (this.fields.contains(f.toLowerCase())) {
      //     result.add(f2v.get(f));
      //   }
      // }
      for (Schema.DescribeFieldResult dfr : this.dfrs) {
        if (f2v.containsKey(dfr.getName())) {
          result.add(f2v.get(dfr.getName()));
        }
      }
      return result;
    }
    public List<SB_Oto_DataFormatter.RecordField> create(User u) {
      List<SB_Oto_DataFormatter.RecordField> result = new List<SB_Oto_DataFormatter.RecordField>();
      for (Schema.DescribeFieldResult dfr : this.dfrs) {
        Object val = u.get(dfr.getName());
        if (val != null) {
          result.add(SB_Oto_DataFormatter.getDataFormatter(dfr.getName()).build(val));
        }
      }
      return result;
    }

  }

  private Map<Id, List<SObject>> makeOwnerId2Records(Map<Id, List<SObject>> user2recs, List<SObject> recs) {
    for (SObject rec : recs) {
      Id ownerId = (Id)rec.get('OwnerId');
      List<SObject> ownRecs;
      if (user2recs.containsKey(ownerId)) {
        ownRecs = user2recs.get(ownerId);
      }
      else {
        ownRecs = new List<SObject>();
        user2recs.put(ownerId, ownRecs);
      }
      ownRecs.add(rec);
    }
    return user2recs;
  }

  public GetRecordOwnersResponse create() {
    GetRecordOwnersResponse result = new GetRecordOwnersResponse();
    try {
      SB_Ot_OrgTreeConfig config = SB_Ot_OrgTreeConfig.getInstance();
      config.setAccountAssociation(this.accountAssociation);
      SB_Ot_SObjectConfig.makeOwnerListSObjectConfig();     // 所有者リスト用のアカウント、コンタクト、ユーザの設定を作る
      result.init(this.targetId, this.sortField, this.sortAsc);
      SB_Ot_RecordsHolder.AccountsRecordsHolder holder = (SB_Ot_RecordsHolder.AccountsRecordsHolder)SB_Ot_RecordsHolder.createHolder(this.targetId.getSobjectType(), this.targetId);
      // result.addCards(cards);
      Set<Id> ownerIds = new Set<Id>();
      Map<Id, List<SObject>> user2recs = new Map<Id, List<SObject>>();
      if (this.includeAccountOwner) {
        List<Account> acnts = new List<Account> (); // 追加の条件に一致したものに絞ったアカウント
        for(Account a : holder.acnts) {
          if (holder.matchedAcntIds.contains(a.Id)) {
            acnts.add(a);
          }
        }
        if (!acnts.isEmpty()) {
          makeOwnerId2Records(user2recs, acnts);
        }
      }
      makeOwnerId2Records(user2recs, holder.conts);
      ownerIds.addAll(user2recs.keySet());

      // Set<String> cols = new Set<String>(USER_FIELDS);
      Set<String> cols = new Set<String> {'id', 'name', 'alias', 'department'}; //　必須
      // cols.addAll(this.fields.toLowerCase().split(',\\s*')); // 無効な項目もクエリするエラーにする。
      // cols.addAll(this.titleFields.toLowerCase().split(',\\s*')); // 無効な項目もクエリするエラーにする。
      cols.addAll(SB_Oto_RecordOwnersBuilder.titleFormatter.getTitleFields()); //
      cols.addAll(SB_Oto_RecordOwnersBuilder.itemListCreater.getFields()); //

      // if (enableFeedItem) {
      //   cols.add('fullphotourl');
      //   cols.add('smallphotourl');
      // }
      String orderby = '';
      if (sortField == 'name') {
        orderby = String.format(ORDER_NAME, new String[] { this.sortAsc ? 'ASC' : 'DESC'});
      }
      else if (sortField == 'department') {
        orderby = String.format(ORDER_DEPT, new String[] { this.sortAsc ? 'ASC' : 'DESC'});
      }
      String query = String.format(USER_QUERY,
        new String[]{ String.join(new List<String>(cols), ', '), (this.includeInactiveUser ? '' : 'and IsActive=true'), orderby });
      System.debug(query);
      List<User> users = Database.query(query);
      for (User u : users){
        // 結果に所有者s を追加
        result.addOwner(u, user2recs.get(u.Id));
      }
      // 結果の並べ替えとか
      result.finalize();
    }
    catch(Exception e) {
      result.setException(e);
    }
    return result;
  }

}