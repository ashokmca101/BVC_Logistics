import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { exportToCsv } from 'c/csvUtility'; // Custom CSV utility, explained below
import getAccounts from '@salesforce/apex/AccountController.getAccounts';

export default class createACRReport extends LightningElement {
  accounts = [];
  isLibraryLoaded = false;

  @wire(getAccounts)
  wiredAccounts({ error, data }) {
    if (data) {
      console.log('you are in ACRREPORT+++++++');
      this.accounts = data;
    } else if (error) {
      console.log('you arent ACRREPORT+++++++');
      this.showErrorToast('Error', error.body.message);
    }
  }

  renderedCallback() {
    if (this.isLibraryLoaded) return;
    this.isLibraryLoaded = true;
    loadScript(this, '/loadResource.bvc2--bvcuat.sandbox.lightning.force.com/resource/csvLibrary') // Replace 'csvLibrary' with the actual resource URL for your CSV library
      .then(() => {
        console.log('CSV library loaded successfully');
      })
      .catch((error) => {
        console.error('Failed to load CSV library', error);
      });
  }

  handleExportClick() {
    console.log('handleExportClick+++++++');
    if (this.accounts.length > 0) {
      const csvData = this.accounts.map((account) => ({
        Id: account.Id,
        Name: account.Name
      }));

      exportToCsv(csvData, 'accountData.csv');
    } else {
      this.showErrorToast('No Accounts Found', 'There are no accounts to export.');
    }
  }

  showErrorToast(title, message) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: 'error'
    });
    this.dispatchEvent(toastEvent);
  }
}