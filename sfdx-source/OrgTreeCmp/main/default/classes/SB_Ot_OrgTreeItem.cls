/**
 *
 *  SB_Ot_OrgTreeItem
 *    クライアントにわたす 階層ノードs のクラス
 *
 * Copyright (C) 2019 SunBridge Inc. All Rights Reserved.
 *
 *  @author sawano
 *  @Version 1.1      2019.05.xx 複雑になってきたので、SB_Ot_OrgTreeFactory から分離
 *  @Version 1.2      2020.03.xx makeValuesのリファクタリング
 *
 */
public with sharing class SB_Ot_OrgTreeItem {

  private static SB_Ot_OrgTreeConfig treeConfig {
    get {
      if (treeConfig==null) {
        treeConfig = SB_Ot_OrgTreeConfig.getInstance();
      }
      return treeConfig;
    }
    private set;
  }

  private static Integer counter = 0;      // ブランチ ノードにIDを割り振るので、そのためのカウント

  //  名刺の最新へリンクしてるか調べる
  private static Boolean isReferenceToLasteNameCard(SObject obj) {
    Boolean saishin = (Boolean)obj.get('SmartViscaf__Saishin__c');
    Object latest = obj.get('SmartViscaf__Parent__c');
    return latest == null || saishin != false;
  }



  /**
    +
    ノード Node 部署
    リーフ Lead 人
  **/
  public abstract class Item implements Comparable {
    // public SObject obj { get; protected set; }
    @AuraEnabled public String name  { get; private set; }   // 用途が微妙に違うので派生クラスでセットします。Tree : 追加で渡せる情報 TreeGrid: ノードの識別子
    @AuraEnabled public String label { get; protected set; }
    @AuraEnabled public String org { get; protected set; }
    @AuraEnabled public String dept { get; protected set; }
    @AuraEnabled public String title { get; protected set; }
    @AuraEnabled public Integer titleOrder { get; private set; } // 役職の順位
    @AuraEnabled public String email { get; protected set; }
    @AuraEnabled public String pid { get; protected set; }  // 個人の識別子
    @AuraEnabled public List<Item> items { get; private set; } //配下のノード・リーフ   treeGrid の場合 js で _children に移す

    @AuraEnabled public Boolean selected { get; private set; }  //
    @AuraEnabled public Boolean mine { get; private set; }  //
    private Map<String, Item> branchs;  // 部門名 - 部門ノード
    private Map<String, Item> leafs;    // 終端ノード識別子（メアドとか Symbol）- 終端ノード
    private Integer type; // 0:人 1: 部署 2:(子)会社      ソートの際、まずこの順で並べる

    public void setLabel(String label) {
      this.label = label;
    }

    // 部署ノード
    public Item(String label) {
      // this.obj = null;
      this.selected = false;
      this.mine = false;
      this.label = label;
      this.items = new List<Item>();
      this.branchs = new Map<String, Item>();
      this.leafs = new Map<String, Item>();
      this.type = 2;  // 部署
    }
    // 末端 ノード
    public Item(SObject obj) {
      // this.obj = obj;
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(obj.getSObjectType());
      this.selected = false;
      if (obj.getSObjectType() != User.getSObjectType()) {
        this.mine = (Id)obj.get('OwnerId') == UserInfo.getUserId();
      }
      else {
        // 組織名  Userでブランチに組織名を出す用
        this.org = sobjConfig.isRootLabelUserOrg() ? (String)obj.get(sobjConfig.orgField) : '';
      }
      // ラベル
      this.label = sobjConfig.makeLabel(obj);
      // 役職
      if (String.isNotBlank(sobjConfig.titleField)) {
        this.title = (String)obj.get(sobjConfig.titleField);
      }
      this.titleOrder = SB_Ot_TitleOrderMaker.getTitleOrder(this.title);
      // 所属
      if (String.isNotBlank(sobjConfig.deptField)) {
        this.dept = (String)obj.get(sobjConfig.deptField);
        if (this.dept == null) {
          this.dept = '';
        }
        if (String.isNotBlank(this.dept) && String.isNotBlank(this.title) && sobjConfig.deptFieldWithTitle) {
          // 部署項目には役職が含まれる だったら (名刺 で 所属役職項目 とか）役職を削除
          if (sobjConfig.deptFieldMultiple) {
            // 部署項目は複数行型だったら、役職のある行全体を削除
            this.dept = removeTextLine(this.dept, this.title);
          }
          else {
            this.dept = this.dept.replace(this.title, '');
          }
          System.debug(LoggingLevel.INFO, 'this.dept: ' + this.dept);
        }
      }
      // メアド
      if (String.isNotBlank(sobjConfig.emailField)) {
        this.email = (String)obj.get(sobjConfig.emailField);
      }
      // 個人の識別子 pid
      if (String.isNotBlank(this.email)) {
        this.pid = this.email;
      }
      else {
        this.pid = (String)obj.get('Name');
      }
      this.type = 0;  // 人
    }
    // アカウント
    public Item(Account acnt) {
      // this.obj = acnt;
      this.selected = false;
      this.mine = acnt.OwnerId == UserInfo.getUserId();
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.sObjectType);
      // ラベル
      this.label = sobjConfig.makeLabel(acnt);
      this.items = new List<Item>();
      this.branchs = new Map<String, Item>();
      this.leafs = new Map<String, Item>();
      this.type = 3;  // 2:(子)会社
    }
    // 選択されたレコード
    public void setSelected() {
      setSelected(true);
    }
    private void setSelected(Boolean b) {
      this.selected = b;
      // Treeのときは ラベルに印を付ける
      if (this.selected && (this instanceOf TreeItem) && treeConfig.selectedMark) {
        this.label = String.format('{0} {1}', new String[] { this.label, System.Label.SB_Ot_TreeSelectedRecordMark });
      }
    }
    @TestVisible
    // 複数行のテキストから 特定の文字を含む行を削除する。
    private String removeTextLine(String multi, String text) {
      String[] ss = multi.split('\n');
      if (ss.size() > 1) {
        for (Integer n=0; n< ss.size(); n++) {
          if (ss[n].containsIgnoreCase(text)) {
            ss.remove(n);
          }
        }
        return String.join(ss, '\n');
      }
      else if (!ss.isEmpty()){
        return ss[0].replace(text, '');
      }
      return null;
    }

    public void addItem(List<String> branchs, Item item) {
      System.assert(this.items != null);
      if (branchs !=null && !branchs.isEmpty()) {
        // 配下の部署を見つける or 作る
        Item branch;
        String branchName = branchs[0].replaceAll('[\\s　]', '');   // 部署名 空白抜きで比較する 全角も
        if(!this.branchs.containsKey(branchName)) {
          // 部署が新規
          branch = createBranch(branchs[0]);    // ラベルは 空白つけて 作る 先がち
          this.items.add(branch);
          this.branchs.put(branchName, branch);
        }
        else {
          // 追加済み 部署
          branch = this.branchs.get(branchName);
        }
        // 部署配下に追加
        List<String> subbranchs = branchs.clone();
        subbranchs.remove(0);
        branch.addItem(subbranchs, item);
      }
      else {
        // 末端 ノード
        // if ((SB_Ot_GLobal.otConfig.SamePersonUsage__c == SB_Ot_GLobal.SAME_PERSON_OFF ||
        //     SB_Ot_GLobal.otConfig.SamePersonUsage__c == SB_Ot_GLobal.SAME_PERSON_NEST) &&
        //   this.leafs.containsKey(item.pid) ) {
        //   // 同じ人は 表示しない か 入れ子表示 で、同じ人 がすでにいたとき。
        //   if (SB_Ot_GLobal.otConfig.SamePersonUsage__c == SB_Ot_GLobal.SAME_PERSON_NEST) {
        //     // 入れ子にする。
        //     Item samePerson = this.leafs.get(item.pid);
        //     if (samePerson.items == null) {
        //       // 入れ子にするときにはじめて items を作る。そうしないと treegrid で からでも > が出てしまう。
        //       samePerson.items = new List<Item>();
        //     }
        //     samePerson.items.add(item); // 入れ子にする
        //   }
        // }
        // else {
          // 同じ人はフラットに表示(0 か 1,2以外) か 同じ人 いない
          this.items.add(item);
        //   this.leafs.put(item.pid, item);
        // }
      }
    }

    protected abstract Item createBranch(String label);
    protected abstract Item createBranch(Account acnt);

    // 部署Itemを追加
    public Item addBranch(Item branch) {
      this.items.add(branch);      // 子ノードをリストに追加
      this.branchs.put(branch.label, branch);
      return branch;
    }

    public void finalize() {
      if (this.items != null && !this.items.isEmpty()) {
        this.items.sort();
        for (Item i : this.items) {
          i.finalize();
        }
      }
    }

    // ソートする
    public Integer compareTo(Object compareTo) {
      if (this.type != ((Item)compareTo).type) {
        // 0:人 1: 部署 2:(子)会社      ソートの際、まずこの順で並べる
        return this.type > ((Item)compareTo).type ? 1 : -1;
      }
      else {
        if (this.titleOrder == null && ((Item)compareTo).titleOrder == null) {
          // 部署をソート
          return this.label.compareTo(((Item)compareTo).label);
        }
        //　部署配下では部署より人を先にする
        else if (this.titleOrder == null && ((Item)compareTo).titleOrder != null) {
          return 1;
        }
        else if (this.titleOrder != null && ((Item)compareTo).titleOrder == null) {
          return -1;
        }
        // 役職の順位でソート
        else if (this.titleOrder == null || this.titleOrder < ((Item)compareTo).titleOrder) {
          return -1;
        }
        else if (this.titleOrder == ((Item)compareTo).titleOrder) {
          // 役職順位が同じ
          if (this.title == ((Item)compareTo).title) {
            // 同じ役職名
            return this.label.compareTo(((Item)compareTo).label);
          }
          else {
            // 役職名でソート
            return this.title.compareTo(((Item)compareTo).title);
          }
        }
      }
      return 1;
    }

    protected abstract void printExtension();
    public void print() {
      printExtension();
      if (items == null || items.isEmpty()) {
        return;
      }
      for(Item i : items) {
        i.print();
      }
    }

  } // public abstract class Item implements Comparable


  // ツリーのノード・リーフ 人
  public class TreeItem extends Item {
    @AuraEnabled public Boolean expanded { get; private set; } // Specifies whether a branch is expanded. An expanded branch displays its nested items visually. The default is false.
    @AuraEnabled public Boolean disabled { get; private set; } // Specifies whether a branch is disabled. A disabled branch can't be expanded. The default is false.
    @AuraEnabled public String metatext { get; private set; } // Text to provide users with supplemental information and aid with identification or disambiguation.
    @AuraEnabled public String href { get; private set; } // The URL for the link.
    public TreeItem(String label) {
      super(label);
      this.expanded = true;
      this.disabled = false;
      this.metatext = null;
      this.name = 'NR' + String.valueOf(counter); // レコードではない。
      this.href = '#';
      counter++;
    }
    public TreeItem(SObject obj) {
      super(obj);
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(obj.getSObjectType());
      this.name = obj.Id;
      this.expanded = true;
      this.disabled = false;
      if (treeConfig.yourRecordMark && obj.getSObjectType() != User.getSObjectType() && (Id)obj.get('OwnerId') == UserInfo.getUserId()) {
        this.label = String.format('{0} {1}', new String[] { this.label, System.Label.SB_Ot_TreeYourRecordMark });
      }
      this.href = String.format(System.Label.SB_Ot_RecordDetailUrlFormat, new String[] { obj.Id });// onClick で処理するから使え荒れないけど、個人要素の識別用に一応
    }
    public TreeItem(Account acnt) {
      super(acnt);
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(Account.sObjectType);
      this.name = acnt.Id;
      this.expanded = true;
      this.disabled = false;
      this.href = '#';  // onClick で処理する。
    }
    protected override Item createBranch(String label) {
      return new TreeItem(label);
    }
    protected override Item createBranch(Account acnt) {
      return new TreeItem(acnt);
    }

    protected override void printExtension() {
      if (this.name != null) {
        System.debug(LoggingLevel.INFO, this.label + ' name: ' + this.name);
      }
      else {
        System.debug(LoggingLevel.INFO, this.label);
      }
    }

  }

  // ツリーグリッドのノード・リーフ
  public class GridItem extends Item {
    @AuraEnabled public String linkTo { get; private set;} // リンク先 リンクなくても キー が必要
    @AuraEnabled public Map<String, Object> values;

    public GridItem(String label) {
      super(label);
      this.linkTo = '#';
      this.name = 'NR' + String.valueOf(counter); // レコードではない。
      counter++;
    }

    public GridItem(SObject obj) {
      super(obj);
      this.linkTo = String.format(System.Label.SB_Ot_RecordDetailUrlFormat, new String[] { obj.Id });
      this.name = obj.Id;
      makeValues(obj);
    }

    public GridItem(Account acnt) {
      super(acnt);
      this.linkTo = String.format(System.Label.SB_Ot_RecordDetailUrlFormat, new String[] { acnt.Id });
      this.name = acnt.Id;
      makeValues(acnt);
    }

    protected override Item createBranch(String label) {
      return new GridItem(label);
    }
    protected override Item createBranch(Account acnt) {
      return new GridItem(acnt);
    }

    // Gridのとき、レコードのごとの各カラムに応じて表示するデータを作る
    private void makeValues(SObject obj) {
      this.values = new Map<String, Object>();
      SB_Ot_SObjectConfig sobjConfig = SB_Ot_SObjectConfig.getSObjectConfig(obj.getSObjectType());
      // 値のあるものから作ってく
      Map<String, Object> f2Val = obj.getPopulatedFieldsAsMap();
      for (String f : f2Val.keySet()) {
        SB_Ot_LcTreeGridDataCreator.DataCreator dcreator;
        if (sobjConfig.dataCreators.containsKey(f.toLowerCase())) {
          dcreator = sobjConfig.dataCreators.get(f.toLowerCase());
        }
        else if (f==SB_Ot_ContactRoleFormatter.getContactRoleField()) {
          dcreator = sobjConfig.dataCreators.get('contactrole');
        }
        if (dcreator == null) {
          continue;
        }
        this.values.putAll(dcreator.create(obj));
      }
      // 設定の項目ごとに作ってく
      // for (Integer n=0; n<sobjConfig.gridFields.size(); n++) {
      //   String f = sobjConfig.gridFields.get(n);
      //   if (!sobjConfig.dataCreators.containsKey(f)) {
      //     continue;
      //   }
      //   if (obj.get(f) == null) {
      //     continue;
      //   }
      //   SB_Ot_LcTreeGridDataCreator.DataCreator dcreator = sobjConfig.dataCreators.get(f);
      //   this.values.putAll(dcreator.create(obj));
      // }
    }

    protected override void printExtension() {
      if (this.values!=null) {
        System.debug(LoggingLevel.INFO, this.label + ' values: ' + this.values);
        for (String key : this.values.keySet()) {
          System.debug(LoggingLevel.INFO, key + ': ' + this.values.get(key));
        }
      }
      else {
        System.debug(LoggingLevel.INFO, this.label);
      }
    }

  }// public class GridItem extends Item

  // ルートと レコードに対応するノードを作る クラス用の インターフェイス
  public interface ItemBuilder {
    Item createRootItem(String label); // ルートノードを作る レコードのないノード
    Item createItem(SObject obj);  // 末端ノードを作る
    Item createItem(Account acnt); // アカウントのノードを作る
  }

  // Tree のルートと レコードに対応するノードを作る クラス
  public class TreeItemBuilder implements ItemBuilder {
    // ルートノードを作る レコードのないノード作る
    public Item createRootItem(String label) {
      return new TreeItem(label);
    }    // オブジェクトの ノードを作る
    public Item createItem(SObject obj) {
      return new TreeItem(obj);
    }
    public Item createItem(Account acnt) { // アカウントのノードを作る
      return new TreeItem(acnt);
    }
  }

  // TreeGrid のルートと レコードに対応するノードを作る クラス
  public class GridItemBuilder implements ItemBuilder {
    // ルートノードを作る レコードのないノード作る
    public Item createRootItem(String label) {
      return new GridItem(label);
    }    // オブジェクトの ノードを作る
    public Item createItem(SObject obj) {
      return new GridItem(obj);
    }
    public Item createItem(Account acnt) { // アカウントのノードを作る
      return new GridItem(acnt);
    }
  }


}