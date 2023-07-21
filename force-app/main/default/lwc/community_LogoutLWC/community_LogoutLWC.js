import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Community_LogoutLWC extends NavigationMixin(LightningElement){

    //@api pageTpe;
    //@api dynamicUrl;

    connectedCallback() {
        //var baseUrl = document.location.origin;
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
        }
        });
    }

}