/**
 *  sb_oto_recordOwners.js
 *      名刺レコード詳細画面で 同じ人の名刺を持つユーザ をリストする LWC
 *
 *  @author sawano
 *  @Version1 2019.06.xx v2.4 SV_DEV-1593 LEX画面の名刺詳細から「同じ名刺を持つユーザ」を確認できるようにしてほしい
 *
 */
import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
// @salesforce Modules https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.reference_salesforce_modules
import getUsersHavingContacts from '@salesforce/apex/SB_Oto_RecordOwnersLwcController.getUsersHavingContacts';
// import { refreshApex } from '@salesforce/apex';
// Access Internalization Properties https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_i18n
// import LANG from '@salesforce/i18n/lang';
// Access Labels https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.create_labels
import label_apptitle from '@salesforce/label/c.SB_Ot_OwnersAppTitle';
import label_menu_order from '@salesforce/label/c.SB_Ot_MENU_ORDER';
// Use the Wire Service to Get Data https://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.data_wire_service_about
// import user_name from '@salesforce/schema/User.Name';
// import user_department from '@salesforce/schema/User.Department';
// import lastModifiedDate from '@salesforce/schema/Contact.LastModifiedDate';
import label_name from '@salesforce/label/c.SB_Ot_USER_NAME';
import label_dept from '@salesforce/label/c.SB_Ot_USER_DEPARTMENT';
import label_lastmodifieddate from '@salesforce/label/c.SB_Ot_LastModifiedDate';
import label_recordCount from '@salesforce/label/c.SB_Ot_OwnerRecordCount'

export default class sb_oto_contactsOwners extends NavigationMixin(LightningElement) {
  @api recordId; //
  @api appTitle; //
  @api titleFields // 所属役職等の表示項目
  @api fields; // 表示するカラム
  @api includeInactiveUser;  // 無効なユーザも含める
  @api includeAccountOwner;  // 取引先の所有者を含む
  @api accountAssociation; // 親取引先の所有者を含める
  @api showLastModifiedDate; // 最終更新日を表示する
  @api sortField; // label="並び順(初期値)" type="String" datasource="apex://SB_NC_CardOwnersSortPickList"
  @api sortOrder; // 設定の初期値を保持し続けるlabel="並び順(初期値)" type="String" datasource="apex://SB_NC_CardOwnersSortOrderPickList"
  @track sortAsc;
  @track working=true;   // ローディング中
  @track owners;
  @track selectedOwner;
  @track error;
  @track message;
  @track showMenu;
  // lang = LANG;
  label = {
    // label_apptitle,
    label_menu_order,
    label_name,
    label_dept,
    label_lastmodifieddate,
    label_recordCount
  };

  // The constructor() method is invoked when a component instance is created.
  constructor() {
    super();
    // this.appTitle = label_apptitle;
    this.fields = "EMail, Phone" ;
    this.titleFields = "CompanyName, Department, Title";
    this.sortField = "name";
    this.sortOrder = "asc";
    this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    this.working = true;
  }

  // The connectedCallback() lifecycle hook is invoked when a component is inserted into the DOM.
  connectedCallback() {
    if (!this.appTitle) {
      this.appTitle = label_apptitle;
    }
    this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    this.working = true;
  }
  // サーバからデータ取得
  // Call Apex Methods https://developer.salesforce.com/docs/component-library/documentation/lwc/apex
  // Wire an Apex Method to a Function
  @wire(getUsersHavingContacts, { targetId: '$recordId',
                                // excludeMe: false,
                                // includeCurrentOwner: '$includeCurrentOwner',
                                includeInactiveUser: '$includeInactiveUser',    //
                                includeAccountOwner: '$includeAccountOwner',  // 取引先の所有者を含む
                                accountAssociation: '$accountAssociation', // 親取引先の所有者を含める
                                showLastModifiedDate: '$showLastModifiedDate', // 最終更新日を表示する
                                sortField: '$sortField',
                                sortAsc: '$sortAsc' ,
                                titleFields: '$titleFields',
                                fields: '$fields'})
                                wiredOwners({ error, data }) {
                                  if (data) {
                                    this.error = undefined;
                                    this.message = data.message;
                                    if (data.success) {
                                      // this.message = data.message;
                                      this.owners = data.owners;
                                      this.showMenu = this.owners.length > 1;
                                    }
                                    else {
                                      // SV_DEV-2560 [組織情報DX]取引先責任者の所有者 で 内部エラーをメッセージ表示可能にする。
                                      this.owners = undefined;
                                      this.showMenu = false;
                                    }
                                    // refreshApex(this.owners);
                                  }
                                  else if (error) {
                                    // プラットフォームでのエラー
                                    this.message = undefined;
                                    this.error = error;
                                    this.owners = undefined;
                                    this.showMenu = false;
                                  }
                                  this.working = false;
                              }

  // ユーザを選択したとき
  handleSelect(event) {
    const userId = event.detail;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
          recordId: userId,
          // objectApiName: "User",
          actionName: "view"
      }
    });
  }

  // ソートキーを選択したとき
  handleSortKeySelect(event) {
    const selKey = event.detail.value;
    if (this.sortField === selKey) {
      this.sortAsc = !this.sortAsc;
    }
    else {
      this.sortField = selKey;
      this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    }
    this.working = true;  // ローディング中に
  }

  // 氏名でソート
  get sortName() {
    return this.sortField === "name";
  }
  // 部署でソート
  get sortDept() {
    return this.sortField === "department";
  }
  // 最終更新日でソート
  get sortLastDate() {
    return this.sortField === "lastDate";
  }

  // レコード所有数でそ～sと
  get sortRecordCount() {
    return this.sortField === "count";
  }

}