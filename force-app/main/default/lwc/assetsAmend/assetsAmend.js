import { LightningElement, wire,api } from 'lwc';
import getAssets from '@salesforce/apex/AssetsAmend.getAssets';
import getSelectedAssets from '@salesforce/apex/AssetsAmend.getSelectedAssets';
import getFilterAssets from '@salesforce/apex/AssetsAmend.getFilterAssets';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from "lightning/navigation";
export default class AssetsAmend extends NavigationMixin(LightningElement) {
@api Assets;
@api recordId
assetRecs
isTrue = false
num
name
SKU
ticket
connectedCallback() {
    this.columns = [
        {label:'Name', fieldName:'Name'},
    ];
}
@wire(getAssets, {accId:'$recordId'})
WiredAss({error,data}){
    if(data){
        this.Assets = data
        console.log(this.Assets)
    }
    if(error){
        console.error(error)
    }
}

getSelectedName(event){

    //this.assetRecs = event.detail.selectedRows;
    const recs  = event.detail.selectedRows;
    const assetIds = recs.map(rec => rec.Id);
    console.log(recs)
    this.assetRecs = assetIds;
 
    

    console.log(' vivek '+JSON.stringify(event.detail.selectedRows));
}

saveHandler(){
    
    getSelectedAssets({accId:this.recordId, assetIds :this.assetRecs})
  .then((result) => {
    // console.log('result '+Promise.resolve(result.json()));
    this.dispatchEvent(new CloseActionScreenEvent());
    console.log('Ashish '+result)
    // const baseUrl = 'https://gyansys35-dev-ed.develop.lightning.force.com/one/one.app#eyJjb21wb25lbnREZWYiOiJvbmU6YWxvaGFQYWdlIiwiYXR0cmlidXRlcyI6eyJhZGRyZXNzIjoiaHR0cHM6Ly9neWFuc3lzMzUtZGV2LWVkLS1zYnFxLmRldmVsb3AudmYuZm9yY2UuY29tL2FwZXgvc2I%2FaWQ9YTBxYm0wMDAwMDA0RG1mQUFFIn0sInN0YXRlIjp7fX0%3D';
    // const dynamicUrl = `${baseUrl}&Product=${this.assetRecs}`;
    
    let link = '/apex/sbqq__sb?scontrolCaching=1&id=' + result 
                       + '#quote/le?qId=' + result;
    this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
            // apiName: "customTabName",
            // url: 'https://gyansys35-dev-ed.develop.lightning.force.com/one/one.app#eyJjb21wb25lbnREZWYiOiJvbmU6YWxvaGFQYWdlIiwiYXR0cmlidXRlcyI6eyJhZGRyZXNzIjoiaHR0cHM6Ly9neWFuc3lzMzUtZGV2LWVkLS1zYnFxLmRldmVsb3AudmYuZm9yY2UuY29tL2FwZXgvc2I%2FaWQ9YTBxYm0wMDAwMDA0RG1mQUFFIn0sInN0YXRlIjp7fX0%3D'
            // url: `https://gyansys35-dev-ed.develop.lightning.force.com/one/one.app#eyJjb21wb25lbnREZWYiOiJvbmU6YWxvaGFQYWdlIiwiYXR0cmlidXRlcyI6eyJhZGRyZXNzIjoiaHR0cHM6Ly9neWFuc3lzMzUtZGV2LWVkLmRldmVsb3AubGlnaHRuaW5nLmZvcmNlLmNvbS9hcGV4L3NicXFfX3NiP2lkPTEyMzQ1JlByb2R1Y3Q9${this.assetRecs}`  
            // Customize the URL with your parameters
            url: link



        },
        // query string parameters
        state: {
            c__showPanel: 'true' // Value must be a string
        }
    }).then(url => {
        window.open(url)
    });

  })
  .catch((error) => {
    console.log('error '+error)
  });



}
cancelHandler(){
    this.dispatchEvent(new CloseActionScreenEvent());
    console.log('Ashish')
}

filterHandler(){
    this.isTrue = true
}
nameHandler(event){
   this.name = event.target.value
}
numHandler(event){
    this.num = event.target.value
}
SKUHandler(event){
    this.SKU = event.target.value
}
ticketHandler(event){
    this.ticket = event.target.value
}
saveFilterHandler(){

    getFilterAssets({accId:this.recordId, name :this.name, num:this.num, SKU:this.SKU, ticket:this.ticket})
  .then((result) => {
    console.log('result '+result);
    this.Assets = result
    console.log('Ashish')
  })
  .catch((error) => {
    console.log('error '+error)
  });}

}