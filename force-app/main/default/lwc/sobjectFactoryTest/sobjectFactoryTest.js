import { LightningElement, api, track, wire } from 'lwc';
import generateMethodToFactorySobject from '@salesforce/apex/SobjectFactoryTest.generateMethodToFactorySobject';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SobjectFactoryTest extends LightningElement {
    @track recordId;
    @track factoryMethod = undefined;
    @track loading = undefined;

    currentPageReference = null; 
    urlStateParameters = null;

    connectedCallback() {
        
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.attributes.recordId || null;
            this.factoryMethod = '';
        }
    }

    handleClick(event) {
        this.requestApex(this.recordId);
    }

    async requestApex(sObjectId) {
        this.loading = true;

        await generateMethodToFactorySobject({recordId: sObjectId})
        .then(result => {
            this.factoryMethod = result;
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!', 
                variant: 'success', 
                mode: 'pester', 
                message: 'Method generated with success!'
            }));
        })
        .catch(error => {
            this.factoryMethod = '';
            this.recordId = '';

            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!', 
                variant: 'error', 
                mode: 'sticky', 
                message: `Something went wrong ::: ${error.body.message}`
            }));
        });

        this.loading = false;
    }
}