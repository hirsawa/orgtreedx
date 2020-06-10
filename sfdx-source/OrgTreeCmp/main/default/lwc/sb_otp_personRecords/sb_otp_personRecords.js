/**
 *  sb_otp_personRecords.js
 *      同じ人のレコード一覧
 *
 *  @author sawano
 *  @Version 1 2020.05.xx
 *
 */
import { LightningElement, api, wire, track } from 'lwc';
import getPersonRecords from '@salesforce/apex/SB_Otp_personRecordsLwcController.getPersonRecords';

export default class Sb_otp_personRecords extends LightningElement {
  @api recordId; //
  @api appTitle;  // タイトル
  @api otherObjects;  // 対象のオブジェクト
  @api collateFields;   // 照合する項目
  @api sortField;   // 並び替え項目
  @api sortOrder;   // 並び替え順
  @api tableFields;   // 表示項目
  @api pageSize;      // ページサイズ（未サポート）
  @track sortAsc;
  @track working=true;   // ローディング中
  @track error;
  @track message;


  constructor() {
    super();
    // this.appTitle = label_apptitle;
    this.sortField = "name";
    this.sortOrder = "asc";
    this.sortAsc = this.sortOrder !== "desc";  // 並べ替え順の初期値
    this.working = true;
  }

}