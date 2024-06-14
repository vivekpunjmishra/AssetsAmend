public with sharing class AssetsAmend {
    @AuraEnabled(Cacheable = true)
    public static list<Asset> getAssets(string accId) {
        list<Asset> assLst = 
        [SELECT  Id, Name From Asset where AccountId =: accId And (UsageEndDate = Null or UsageEndDate > Today) 
        And (Product2ID != null And SBQQ__RequiredByAsset__c = Null And SBQQ__RequiredBySubscription__c = Null And SBQQ__VirtualAsset__c = Null )];
        if(assLst.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return assLst; 
    }

    @AuraEnabled
    public static string getSelectedAssets(string accId, List<string> assetIds) {
        system.debug('Vivek '+assetIds+' - '+accId);
        string quoteId;
        if(accId != null && !assetIds.isEmpty()){
            quoteId = generateAmendments(accId,assetIds);
        }
        return quoteId; 
    }

    @AuraEnabled(Cacheable = true)
    public static list<Asset> getFilterAssets(string accId, string name, string num, string SKU, String ticket ) {
        system.debug('accId '+accId);
        system.debug('name '+name);
        system.debug('num '+num);
        system.debug('SKU '+SKU);
        system.debug('ticket '+ticket);
        list<Asset> assLst = 
        [SELECT  Id, Name From Asset where AccountId =: accId AND SerialNumber =:num And Name=:name And StockKeepingUnit=: SKU And Ticket__c=: ticket And (UsageEndDate = Null or UsageEndDate > Today) 
        And (Product2ID != null And SBQQ__RequiredByAsset__c = Null And SBQQ__RequiredBySubscription__c = Null And SBQQ__VirtualAsset__c = Null )];
        if(assLst.isEmpty()) {
            throw new AuraHandledException('No Record Found..');
        }
        return assLst; 
    }
    public static string generateAmendments(string accId, List<string> assetIds){
        Account acc = [SELECT Id, Name FROM Account WHERE Id = : accId LIMIT 1];
        List<Asset> assetList = [SELECT Id,Name, Quantity, AccountId,Account.Name,Product2Id, 
        SBQQ__QuoteLine__r.SBQQ__Quote__c,SBQQ__Bundle__c, SBQQ__RequiredByAsset__c, 
        SBQQ__RequiredByAsset__r.Name, SBQQ__QuoteLine__c, SBQQ__LatestQuoteLine__c,
        SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,  SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__PriceBook__c , SBQQ__QuoteLine__r.SBQQ__NetPrice__c
        FROM Asset WHERE Id IN : assetIds OR SBQQ__RequiredByAsset__c IN :assetIds];
        Opportunity amendOpp = new Opportunity( Name = 'Amendment Opportunity - '+acc.Name+' - '+Date.Today(),
                                                AccountId = acc.Id,
                                                StageName = 'Prospecting',
                                                CloseDate = Date.Today().addMonths(12),
                                                Pricebook2Id = '01sbm0000029MRZAA2',
                                                SBQQ__Renewal__c = false);
        // try{
            Database.insert(amendOpp);
        // }
        // catch(DmlException e){
        //     System.debug('Error in inserting Amendment Opportunity-->'+e.getMessage());
        // }
        SBQQ__Quote__c amendQuote = new SBQQ__Quote__c( SBQQ__Account__c = acc.Id,
                                                        SBQQ__Opportunity2__c = amendOpp.Id,
                                                        SBQQ__PriceBook__c = '01sbm0000029MRZAA2',  //Needs logic to be defined for setting PriceBookId on new Amendment Quote. Hardcoding standard price book id for now
                                                        SBQQ__Type__c = 'Amendment',
                                                        SBQQ__StartDate__c = Date.Today());
        // try{
            Database.insert(amendQuote);
        // }
        // catch(DmlException e){
        //     System.debug('Error in inserting Amendment Quote-->'+e.getMessage());
        // }
        List<SBQQ__QuoteLine__c> amendQuoteLinesList = new List<SBQQ__QuoteLine__c>();
        for(Asset a : assetList ){
            SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c( SBQQ__Quote__c = amendQuote.Id,
                                                                             SBQQ__Product__c = a.Product2Id,
                                                                             SBQQ__PricebookEntryId__c = a.SBQQ__QuoteLine__r.SBQQ__PricebookEntryId__c,
                                                                             SBQQ__Quantity__c = a.Quantity,
                                                                             SBQQ__PriorQuantity__c = a.Quantity,
                                                                             SBQQ__Existing__c = true,
                                                                             SBQQ__Renewal__c = true,
                                                                             SBQQ__UpgradedAsset__c = a.Id
                                                                             );
            amendQuoteLinesList.add(ql);
        }
        // try{
            Database.insert(amendQuoteLinesList);
        // }
        // catch(DmlException e){
        //     System.debug('Error in inserting Amendment Quote Lines-->'+e.getMessage());
        // }
        amendQuote.SBQQ__Primary__c = true;
        // try{
            Database.update(amendQuote);
            //redirecte after this line ------------------>
        // }
        // catch(DmlException e){
        //     System.debug('Error in updating Amendment Quote to Primary-->'+e.getMessage());
        // }
        calculateQuote(amendQuote.Id);
        return amendQuote.Id;
    }
    @future
    public static void calculateQuote(String amendQuoteId){
        SBQQ__Quote__c amendQuote = [SELECT Id,Calculate_Quote__c FROM SBQQ__Quote__c WHERE id = :amendQuoteId LIMIT 1 ];
        amendQuote.Calculate_Quote__c = true;
        try{
            Database.update(amendQuote);
            //redirecte after this line ------------------>
        }
        catch(DmlException e){
            System.debug('Error in calculating Amendment Quote-->'+e.getMessage());
        }
    }

}