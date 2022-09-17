import { LightningElement, api, track, wire } from 'lwc';
import generateMethodToFactorySobject from '@salesforce/apex/SobjectFactoryTest.generateMethodToFactorySobject';

export default class SobjectFactoryTest extends LightningElement {
    @api recordId;
    @track factoryMethod = '';
    @track sobjectId = '';

    connectedCallback() {
        
    }

    handleChange(event) {
        this.sobjectId = event.target.value;
        
        generateMethodToFactorySobject({recordId: event.target.value})
            .then(result => {
                this.factoryMethod = result;
            })
            .catch(error => {
                this.factoryMethod = JSON.stringify(error);
            });
    }
}