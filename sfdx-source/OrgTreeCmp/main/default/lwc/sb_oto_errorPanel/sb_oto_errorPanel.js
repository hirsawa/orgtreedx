/**
 *  sb_oto_errorPanel.js
 *
 *  @author sawano
 *  @Version 1 2019.11.xx v1.1
 *
 */
// LWC Smaples lwc-recipes
// https://github.com/trailheadapps/lwc-recipes
import { LightningElement, api, track } from 'lwc';
import { reduceErrors } from 'c/sb_oto_ldsUtils';

export default class Sb_nc_errorPanel extends LightningElement {
    /** Generic / user-friendly message */
    @api friendlyMessage = 'Error retrieving data';

    @track viewDetails = false;

    /** Single or array of LDS errors */
    @api errors;

    get errorMessages() {
        return reduceErrors(this.errors);
    }

    handleCheckboxChange(event) {
        this.viewDetails = event.target.checked;
    }
}