/*******************************************************
2014/11/01 WIT-335 Created by J. Hazebrouck
2015/02/04 WIT-2042 OLE. Fix localization logic and add multi-currency support
            -Replace hard coded literals by custom labels, sort out mess in existing labels where
             primary language was not always English
            -Convert opportunity amount and use converted amount for threshold comparison
This code is used to display the 'nivelette' visualforce page
Regarding the different values checked by the user, the oportunity will be updated with a new bid type
*******************************************************/
public without sharing class SMBW2_OPP_NivelBidType_VFC {

    private Id oppId;
    public Opportunity oppty{get;set;}          
    public decimal amount {get;set;}                //in Corp Currency
    public decimal amountNonConverted {get;set;}    //in Opportunity record currency before conversion
    public string corpCurrencyIsoCode {get;set;}
    public String ICValue = '';
    public String WinValue = '';
    public String RussiaValue = '';
    public String OfferValue = '';
    public String TCVValue = '';
    public String DomainValue = '';
    public String resultType{get;set;}
    public String resultDescription{get;set;}
    public Boolean boolResult{get;set;}
    public Set<String> regionalVals{get;set;} {regionalVals=new Set<String>();}
    
    public SMBW2_OPP_NivelBidType_VFC(ApexPages.StandardController controller){
    
        oppId = Apexpages.currentPage().getParameters().get('oppId');
        oppty = [SELECT Id, Name, RecordtypeId, RecordType.Name, StageName, Amount, currencyIsoCode,SMB_Opp_Must_Win__c,
        SMB_OPP_Must_Win_level__c, AccountId, Account.Sales_Region__c, Account.Sales_Cluster__c
        FROM Opportunity WHERE Id =: oppId LIMIT 1];
        
        //Convert currency 
        amountNonConverted = oppty.amount;
        CurrencyType oCurrType = [select conversionRate, isoCode
                         from CurrencyType
                         where isoCode = :oppty.CurrencyIsoCode
                         LIMIT 1]; //no error check, can't really be other than 1, can it?
        amount = amountNonConverted/oCurrType.conversionRate;
        oCurrType = [select conversionRate, isoCode
                         from CurrencyType
                         where isCorporate = true
                         LIMIT 1];
        corpCurrencyIsoCode = oCurrType.IsoCode; // to display on page
        
       list<SMB_OPP_MustWinVal_Regional__c> custom_set=SMB_OPP_MustWinVal_Regional__c.getall().values();
        Boolean isRegional = false;
       for(SMB_OPP_MustWinVal_Regional__c foropp:custom_set)
      {
           regionalVals.add(foropp.name);
           if((';'+oppty.SMB_OPP_Must_Win_level__c+';').contains((';'+foropp.name+';')))
           isRegional = true;
       }
        
        //As the fields 'Must Win' and 'Amount' are populated in the first visualforce page,
        //we apply those values to the field by default when the page is loaded
        if(oppty.SMB_Opp_Must_Win__c == 'Yes' && isRegional)
            WinValue = 'Win1';
        else WinValue = 'Win2';
        
        // OLE, not elegant, will have to be replaced by custom setting threshold at some point
        if(Amount < 10000000)
            TCVValue = 'TCV1';
        else if(Amount >= 10000000 && Amount < 18000000)
            TCVValue = 'TCV2';
        else if(Amount >= 18000000 && Amount < 50000000)
            TCVValue = 'TCV3';
        else if(Amount >= 50000000)
            TCVValue = 'TCV4';
        
        resultType = '';
        resultDescription = '';
        boolResult = false;
    }
    
    //Method to change the bid type regarding the different values chosen as described in the diagram
    public pageReference saveBidType(){
        List<RecordType> listOppType = [SELECT Id, Name, Description, DeveloperName FROM RecordType WHERE sObjectType ='Opportunity' AND isActive = true AND DeveloperName LIKE: 'SAMBA%' order by DeveloperName];
        try{
            if(resultType == System.Label.SMB_CL011_BidType_Regional_IC || resultType == System.Label.SMB_CL012_BidType_Regional)
                oppty.RecordTypeId = listOppType[0].Id;
            else if(resultType == System.Label.SMB_CL013_BidType_Local)
                oppty.RecordTypeId = listOppType[2].Id;
            else if(resultType == System.Label.SMB_CL014_BidType_Simple){
                oppty.RecordTypeId = listOppType[1].Id;
                if(oppty.StageName == '1 Pre-qualification') 
                    oppty.StageName = '2 Qualification';
            }
            else{
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.WARNING, system.label.NVLT_Warning_Need_A_Result));
                return null;
            }
            update oppty;
            
            PageReference pageRef = new PageReference('/' + oppty.Id + '?retURL=%2F' + oppty.Id);
            return pageRef;
        }
        catch(exception ex){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Exception Error: ' + ex));
            return null;
        }
    }
    
    //Method to go back to the record page without changing the bid type
    public pageReference cancel(){
        PageReference pageRef = new PageReference('/' + oppId + '?retURL=%2F' + oppId);
        return pageRef;
    }
    
    //Method used in the apex:actionfunction to dynamically display section and result
    public pageReference doNothingIC(){
        resultType = '';
        resultDescription = '';
        boolResult = false;
        
        if(ICValue == 'IC1'){
            boolResult = true;
            resultType = System.Label.SMB_CL011_BidType_Regional_IC;
        }
        else if(ICValue == 'IC2' && WinValue == 'Win1'){
            boolResult = true;
            resultType = System.Label.SMB_CL012_BidType_Regional;
        }
        else if(ICValue == 'IC2' && WinValue == 'Win2' && TCVValue == 'TCV4'){
            boolResult = true;
            resultType = System.Label.SMB_CL011_BidType_Regional_IC;
        }else if(ICValue == 'IC2' && WinValue == 'Win2' && TCVValue == 'TCV3'){
            boolResult = true;
            resultType = System.Label.SMB_CL012_BidType_Regional;
        }
        else if(ICValue == 'IC2' && WinValue == 'Win2' && (TCVValue == 'TCV1' || TCVValue == 'TCV2') && RussiaValue == 'Russia1'){
            boolResult = true;
            resultType = System.Label.SMB_CL012_BidType_Regional;
        }
        else if(ICValue == 'IC2' && WinValue == 'Win2' && TCVValue == 'TCV2'  && DomainValue == 'Domain1'){
            boolResult = true;
            resultType = System.Label.SMB_CL012_BidType_Regional;
        }
        else if(ICValue == 'IC2' && WinValue == 'Win2' && (DomainValue == 'Domain2' || (DomainValue == 'Domain1' && TCVValue == 'TCV1')) && (OfferValue == 'Offer1' || OfferValue == 'Offer2' || OfferValue == 'Offer3')){
            boolResult = true;
            resultType = System.Label.SMB_CL014_BidType_Simple;
        }
        else if(ICValue == 'IC2' && WinValue == 'Win2' &&  (DomainValue == 'Domain2' || (DomainValue == 'Domain1' && TCVValue == 'TCV1')) && OfferValue == 'Offer4'){
            boolResult = true;
            resultType = System.Label.SMB_CL013_BidType_Local;
        }
        
        // Pick result message to display to user
        if(resultType == System.Label.SMB_CL011_BidType_Regional_IC){
            //Role Reorg 2015. Code is heavy maintenance, see if can be improved in later version
            //if(oppty.Account.Sales_Cluster__c == 'DGC')
            // n.b.: DGC : French Large Accounts BU. Never know, might change acronym in future
            if(oppty.Account.Sales_Region__c == System.Label.NVLT_DGC_Current_Name)
                resultDescription = System.Label.SMB_CL015_DGC_Reg_IC;
            else resultDescription = System.Label.SMB_CL019_Inter_Reg_IC;
        }
        else if(resultType == System.Label.SMB_CL012_BidType_Regional){
            if(oppty.Account.Sales_Region__c == System.Label.NVLT_DGC_Current_Name) //Role Reorg 2015. region vs cluster
                resultDescription = System.Label.SMB_CL016_DGC_Reg;
            else resultDescription = System.Label.SMB_CL020_Inter_Reg;
        }
        else if(resultType == System.Label.SMB_CL013_BidType_Local){
            if(oppty.Account.Sales_Region__c == System.Label.NVLT_DGC_Current_Name) //Role Reorg 2015. region vs cluster
                resultDescription = System.Label.SMB_CL017_DGC_Local;
            else if(oppty.Account.Sales_Cluster__c == 'Russia')
                resultDescription = System.Label.SMB_CL022_Russia_Local;
            else resultDescription = System.Label.SMB_CL021_Inter_Local;
        }
        else if(resultType == System.Label.SMB_CL014_BidType_Simple){
            if(oppty.Account.Sales_Region__c == System.Label.NVLT_DGC_Current_Name) //Role Reorg 2015. region vs cluster
                resultDescription = System.Label.SMB_CL018_DGC_Simple;
            else resultDescription = '';
        }
        
        return null;
    }
    

    //Radio Buttons Values
    public List<SelectOption> getItemsICV() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('IC1', system.label.NVLT_YES));
        options.add(new SelectOption('IC2', system.label.NVLT_NO));
        return options;
    }
    
    public List<SelectOption> getItemsWinV() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Win1',system.label.NVLT_YES));
        options.add(new SelectOption('Win2',system.label.NVLT_NO));
        return options;
    }
    
    public List<SelectOption> getItemsTCVV() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('TCV1', system.label.NVLT_Less_Than_10M ));
        options.add(new SelectOption('TCV2', system.label.NVLT_10M_TO_18M ));
        options.add(new SelectOption('TCV3', system.label.NVLT_18M_TO_40M ));
        options.add(new SelectOption('TCV4', system.label.NVLT_Above_40M ));
        return options;
    }
    
    public List<SelectOption> getItemsRussiaV() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Russia1', system.label.NVLT_YES));
        options.add(new SelectOption('Russia2', system.label.NVLT_NO));
        return options;
    }
    
    public List<SelectOption> getItemsOfferV() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Offer1', system.label.NVLT_STD_OPTY)); //'Opportunity based on standard offers,  pricing, terms & conditions'));
        options.add(new SelectOption('Offer2', system.label.NVLT_PROPOSAL_WITHIN_EXISTING_DAC)); //'Proposal & contract made in line with a previous DAC mandate'));
        options.add(new SelectOption('Offer3', system.label.NVLT_CONTRACT_EXTENSION)); //'Contract extension without changes of initial contract scope and prices'));
        options.add(new SelectOption('Offer4', system.label.NVLT_Other)); //'None of the above'));
        return options;
    }
    
    public List<SelectOption> getItemsDomainV() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Domain1', system.label.NVLT_YES));
        options.add(new SelectOption('Domain2', system.label.NVLT_NO));
        return options;
    }
    
    //Radio Buttons Getter & Setter
    public String getICValue() {
        return ICValue;
    }
    
    public void setICValue(String ICV) {
        this.ICValue = ICV;
    }
    
    public String getWinValue() {
        return WinValue;
    }
    
    public void setWinValue(String WinV) {
        this.WinValue = WinV;
    }
    
    public String getRussiaValue() {
        return RussiaValue;
    }
    
    public void setRussiaValue(String RussiaV) {
        this.RussiaValue = RussiaV;
    }
    
    public String getOfferValue() {
        return OfferValue;
    }
    
    public void setOfferValue(String OfferV) {
        this.OfferValue = OfferV;
    }
    
    public String getTCVValue() {
        return TCVValue;
    }
    
    public void setTCVValue(String TCVV) {
        this.TCVValue = TCVV;
    }
    
    public String getDomainValue() {
        return DomainValue;
    }
    
    public void setDomainValue(String DomainV) {
        this.DomainValue = DomainV;
    }
    
}