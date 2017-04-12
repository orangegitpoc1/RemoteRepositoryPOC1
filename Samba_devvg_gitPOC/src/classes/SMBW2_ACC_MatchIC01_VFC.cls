public without sharing class SMBW2_ACC_MatchIC01_VFC {

    private Id accId;
    public Integer allIC01s{get;set;}
    public Integer allSearchIC01s{get;set;}
    public Boolean bool = false;
    public List<ic01Wrapper> listIc01Wrapper{get;set;}
    public List<ic01Wrapper> listIc01SearchWrapper{get;set;}
    public String globalValue{get;set;}
    public Boolean boolSearch{get;set;}
        
    public class ic01Wrapper {
        public IC01__c ic01Record{get;set;}
        public Boolean bool{get;set;}
        
        public ic01Wrapper(IC01__c i, Boolean b){
            ic01Record = i;
            bool = b;
        }
    }
    
    public SMBW2_ACC_MatchIC01_VFC(ApexPages.StandardController controller){
        this.accId = controller.getRecord().Id;
        listIc01Wrapper = new List<ic01Wrapper>();
        listIc01SearchWrapper = new List<ic01Wrapper>();
        allIC01s = 0;
        allSearchIC01s =0;
        boolSearch = false;
        Account acc = [SELECT Id, Name FROM Account WHERE Id =: accId LIMIT 1];
        
        //SOSL Search
        String condSearch = acc.Name.replace(' ', ' OR ');
        List<List<IC01__c>> searchList = [FIND :condSearch IN ALL FIELDS RETURNING IC01__c (Id, Name,
        Account__c, CAC__c, CAC_Name__c, CORE_ID__c, Customer_Address_1__c, Customer_Address_2__c,
        Customer_Address_3__c, Customer_Address_City__c, Customer_Address_Country__c,
        Customer_Address_Postal_Code__c, Customer_Address_State__c, Customer_Name__c WHERE Account__c =: null limit 20)];
        for (integer i = 0; i < searchList[0].size(); i++){
            ic01Wrapper iw = new ic01Wrapper(searchList[0][i], false);
            listIc01Wrapper.add(iw);
        }
        allIC01s = listIc01Wrapper.size();
        
        //1st SOQL Request too restrictive
        /*String condition = '%' + acc.Name + '%';
        for(IC01__c i : [SELECT Id, Name, Account__c, CAC__c, CAC_Name__c, CORE_ID__c, Customer_Address_1__c,
        Customer_Address_2__c, Customer_Address_3__c, Customer_Address_City__c, Customer_Address_Country__c,
        Customer_Address_Postal_Code__c, Customer_Address_State__c, Customer_Name__c FROM IC01__c WHERE
        Customer_Name__c like: condition AND Account__c =: null]){
            ic01Wrapper iw = new ic01Wrapper(i, false);
            listIc01Wrapper.add(iw);
        }
        allIC01s = listIc01Wrapper.size();*/
    }
    
    public pageReference cancel(){
        PageReference pageRef = new PageReference('/' + accId + '?retURL=%2F' + accId);
        return pageRef;
    }
    
    public pageReference matchIC(){
        List<IC01__c> listICToUpdate = new List<IC01__c>();
        for(ic01Wrapper iw : listIc01Wrapper){
            if(iw.bool){
                iw.ic01Record.Account__c = accId;
                listICToUpdate.add(iw.ic01Record);
            }
        }
        for(ic01Wrapper iw : listIc01SearchWrapper){
            if(iw.bool){
                iw.ic01Record.Account__c = accId;
                listICToUpdate.add(iw.ic01Record);
            }
        }
        if(listICToUpdate.size() > 0){
            update listICToUpdate;
            PageReference pageRef = new PageReference('/' + accId + '?retURL=%2F' + accId);
            return pageRef;
        }
        else{
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Warning, 'No IC01s selected below. Please select at least one IC01 by checking the box.'));
            return null;
        }
    }
    
    public void globalSearch(){
        String s = globalValue.replace('*', '');
        if(s.length() < 2)
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.Warning, 'You must enter at least 2 characters to run the global search.'));
        else{
            boolSearch = true;
            allSearchIC01s = 0;
            listIc01SearchWrapper = new List<ic01Wrapper>();
            
            //SOSL Search
            String condSearch = globalValue.replace(' ', ' OR ');
            List<List<IC01__c>> searchList = [FIND :condSearch IN ALL FIELDS RETURNING IC01__c (Id, Name,
            Account__c, CAC__c, CAC_Name__c, CORE_ID__c, Customer_Address_1__c, Customer_Address_2__c,
            Customer_Address_3__c, Customer_Address_City__c, Customer_Address_Country__c,
            Customer_Address_Postal_Code__c, Customer_Address_State__c, Customer_Name__c WHERE Account__c =: null limit 20)];
            for (integer i = 0; i < searchList[0].size(); i++){
                ic01Wrapper iw = new ic01Wrapper(searchList[0][i], false);
                listIc01SearchWrapper.add(iw);
            }
            allSearchIC01s = listIc01SearchWrapper.size();
            
            //1st SOQL Request too restrictive
            /*String condSearch = '%' + globalValue + '%';
            for(IC01__c i : [SELECT Id, Name, Account__c, CAC__c, CAC_Name__c, CORE_ID__c, Customer_Address_1__c,
            Customer_Address_2__c, Customer_Address_3__c, Customer_Address_City__c, Customer_Address_Country__c,
            Customer_Address_Postal_Code__c, Customer_Address_State__c, Customer_Name__c FROM IC01__c WHERE
            Customer_Name__c like: condSearch AND Account__c =: null]){
                ic01Wrapper iw = new ic01Wrapper(i, false);
                listIc01SearchWrapper.add(iw);
            }
            allSearchIC01s = listIc01SearchWrapper.size();*/
        }
    }
}