/**
 *  sb_oto_ownerListItem.js
 *
 *  @author sawano
 *  @Version 1 2019.11.xx v1.1
 *
 */
import { LightningElement, api } from 'lwc';
// import LANG from '@salesforce/i18n/lang';
// import lastModifiedDate from '@salesforce/schema/Contact.LastModifiedDate';
import lastModifiedDate from '@salesforce/label/c.SB_Ot_LastModifiedDate';

export default class sb_oto_ownerListItem extends LightningElement {
  @api user;
  @api showdate;
  // lang = LANG;
  label = {
    lastModifiedDate
  };

  handleClick(event) {
    // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
    event.preventDefault();
    // 2. Read about event best practices at http://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_best_practices
    const selectEvent = new CustomEvent('select', {
        detail: this.user.id
    });
    // 3. Fire the custom event
    this.dispatchEvent(selectEvent);
  }

  handleDateClick(event) {
    // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
    event.preventDefault();
    // 2. Read about event best practices at http://developer.salesforce.com/docs/component-library/documentation/lwc/lwc.events_best_practices
    const selectEvent = new CustomEvent('select', {
        detail: this.user.lastId
    });
    // 3. Fire the custom event
    this.dispatchEvent(selectEvent);
  }

  get enableImg() {
    return this.user.photoUrl && this.user.photoUrl !== null;
  }

}