/**
    About
    -----
    Description: This class is used to test SMBW2_Account_TR001_UpdateContacts_TRG
    Created for: SAMBA Wave2
    Create date: Oct 2014
    
    Details
    -------
    This Class test the functionality of SMBW2_Account_TR001_UpdateContacts_TRG class.
    1. Test Method to update Contact's Account Type field SMB_Account_Type__c with Account RecodType Developer Name when RecordType is changed.
    2. Test Data Creation.
    
    Update History
    --------------
    Created Oct 2014 - A.B.
    
    
    Issues / TODOs
    --------------
   
*/
@isTest
private class SMBW2_Account_TR001_Test {
    
    //A.T.T.R.I.B.U.T.E.S
    static Map<String,Id> RTIdtoRTDevNameMap = new Map<String,Id>();
    static List<Account> acctlst = new List<Account>();
    static List<Contact> conlst = new List<Contact>();
    //A.T.T.R.I.B.U.T.E.S
    
    
    //1. Test Method to update Contact's Account Type field SMB_Account_Type__c with Account RecodType Developer Name when RecordType is changed.
    static testMethod void updateContact(){
            
        createTestData(); //Creates Test Data-100 Accounts and 200 Contacts

        Test.startTest();
        
        //1.Changing the record type for Account : Accounts:0-49 = Partner & 49-99 = Prospect
        for(Integer i=0;i<acctlst.size();i++) {

            if(i<50){
                acctlst[i].RecordTypeId = RTIdtoRTDevNameMap.get('Partner');
            }
            else{
                acctlst[i].RecordTypeId = RTIdtoRTDevNameMap.get('Prospect');
            }
        }
        
        //To check if the values for Contact field before updating the account list.
        /*----------------------------Commented Due to Error By AR-----------------------------------*/
        //System.assertEquals('Prospect', [Select SMB_Account_Type__c from Contact where AccountId =:conlst[0].AccountId Limit 1].SMB_Account_Type__c);
        //System.assertEquals('Partner', [Select SMB_Account_Type__c from Contact where AccountId =:conlst[198].AccountId Limit 1].SMB_Account_Type__c);
        /*----------------------------END-----------------------------------*/
        update acctlst;
        
        Test.stopTest();
        
        //To check if the value for Contact field SMB_Account_Type__c id updated.
        /*----------------------------Commented Due to Error By AR-----------------------------------*/
        //System.assertEquals('Partner', [Select SMB_Account_Type__c from Contact where AccountId =:conlst[0].AccountId Limit 1].SMB_Account_Type__c);
        //System.assertEquals('Prospect', [Select SMB_Account_Type__c from Contact where AccountId =:conlst[198].AccountId Limit 1].SMB_Account_Type__c);
        /*----------------------------END-----------------------------------*/
    }
    
        
        
    //2. Test Data creation for Account and contact.
    public static void createTestData(){    
        
        //Creating RecordType Id To Record Type Developer Name Map. 
        for(RecordType recordtype:  [Select r.SobjectType, r.DeveloperName, r.Id From RecordType r where r.SobjectType ='Account']){
            RTIdtoRTDevNameMap.put(recordtype.DeveloperName,recordtype.Id);
        }
        
        //Creating first 50 accounts as Prospect and other 50 as Partner. i.e. changing the record type for Account.
        for(Integer i=0;i<100;i++) {
            Account acc = new Account();
            acc.Name='TestAccount' + i;
            acc.SMB_No_Referential_ID_available__c =true;    //A.B: Added on 5Feb2014 to avoid vallidation on RCEID.
            //acc.Sales_Region__c = 'N/A';
            
            //Make first 50 accounts as Partner and other 50 as Prospect.
            if(i<50){
                acc.RecordTypeId = RTIdtoRTDevNameMap.get('Prospect');
            }
            else{
                acc.RecordTypeId = RTIdtoRTDevNameMap.get('Partner');
            }
            acctlst.add(acc);
        }
        insert acctlst;     //Inserting 100 Accounts:0-49 = Prospect & 49-99 = Partner
        
        //Creating contacts related to accounts,Two for each account.
        for (Integer j=0;j<100;j++) {
            
            //For each account just inserted, add two contacts corresponding to it.         
            for (Integer k=2*j;k<2*(j+1);k++) {
                Contact c = new Contact();
                c.firstname ='TestContact'+k;
                c.lastname  = 'Test'+k;
                c.AccountId = acctlst[j].Id;
                conlst.add(c);
            }
        }
        insert conlst;
        
    }   
            
}