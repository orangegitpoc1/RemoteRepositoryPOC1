/*******************************************************
Created by J. Hazebrouck
Associated Business Requirement: BR-45
Verify that there is no duplicate prospect or customer account on the system
using the RCE ID or OS KEY ID and recordtype as unique key
*******************************************************/
public without sharing class SMBW1_Account_TR003_IdentifyDuplic_TRG {

    public static void IdentifyDuplicateAcc(List<Account> listAcc){
        //Create a map of all customer and prospect accounts with RCE ID or OS KEY ID
        Map<String, Account> mapAcc = new Map<String, Account>();
        //OLM 15/04/29 workaround gov limit (add filter on RCE_ID__c and iSell__OSKeyID__c)
        list<string> listRCEId = new list<String>();
        list<string> listOSKeyId = new list<String>();
        for (Account oAccount : listAcc) 
        {
            if (oAccount.RCE_ID__c != null && oAccount.RCE_ID__c != '')
            listRCEId.add(oAccount.RCE_ID__c);
            if (oAccount.iSell__OSKeyID__c != null && oAccount.iSell__OSKeyID__c != '')
            listOSKeyId.add(oAccount.iSell__OSKeyID__c);
        }
        for(Account a : [SELECT Id, recordType.DeveloperName, RCE_ID__c, Name FROM Account WHERE RCE_ID__c in :listRCEId]){
            if(a.recordType.DeveloperName =='Prospect' || a.recordType.DeveloperName == 'Customer'){
                if(a.RCE_ID__c != null && a.RCE_ID__c != '')
                    mapAcc.put(a.RCE_ID__c, a);
            }
        }
        
        for(Account a : [SELECT Id, recordType.DeveloperName, iSell__OSKeyID__c, Name FROM Account WHERE iSell__OSKeyID__c in :listOSKeyId]){
            if(a.recordType.DeveloperName == 'Prospect' || a.recordType.DeveloperName == 'Customer'){
                if(a.iSell__OSKeyID__c != null && a.iSell__OSKeyID__c != '')
                    mapAcc.put(a.iSell__OSKeyID__c, a);
            }
        }
        
        //Look for duplicate accounts and display error if found
        for(Account a : listAcc){
            if(a.RCE_ID__c != null && a.RCE_ID__c != ''){
                if(mapAcc.containsKey(a.RCE_ID__c)){
                    a.addError(System.label.SMB_CL002_Error_Duplicate_Account + '<a style = "color:#c00" href=\'/'  + mapAcc.get(a.RCE_ID__c).id + '\'>' + mapAcc.get(a.RCE_ID__c).Name + '</a>', false);
               }
            }
            else if(a.iSell__OSKeyID__c != null && a.iSell__OSKeyID__c != ''){
                if(mapAcc.containsKey(a.iSell__OSKeyID__c)){
                    a.addError(System.Label.SMB_CL002_Error_Duplicate_Account + '<a style = "color:#c00" href=\'/'  + mapAcc.get(a.iSell__OSKeyID__c).id + '\'>' + mapAcc.get(a.iSell__OSKeyID__c).Name + '</a>', false);
                }
            }
        }
        
    }
}

/*public without sharing class SMBW1_Account_TR003_IdentifyDuplic_TRG {

    public static void IdentifyDuplicateAcc(List<Account> listAcc){
        //Create a map of all customer and prospect accounts with RCE ID or OS KEY ID
        Map<String, Account> mapAcc = new Map<String, Account>();
        //OLM 15/04/29 workaround gov limit (add filter on RCE_ID__c and iSell__OSKeyID__c)
        list<string> listRCEId = new list<String>();
        list<string> listOSKeyId = new list<String>();
        for (Account oAccount : listAcc) 
        {
            if (oAccount.RCE_ID__c != null)
            listRCEId.add(oAccount.RCE_ID__c);
            if (oAccount.iSell__OSKeyID__c != null)
            listOSKeyId.add(oAccount.iSell__OSKeyID__c);
        }
        for(Account a : [SELECT Id, Name, RecordTypeId, recordType.DeveloperName, RCE_ID__c,
        iSell__OSKeyID__c FROM Account WHERE (recordType.DeveloperName ='Prospect' OR
        recordType.DeveloperName = 'Customer')
        and ((RCE_ID__c in :listRCEId)or (iSell__OSKeyID__c in :listOSKeyId)) //OLM 15/04/29
        ]){
            if(a.RCE_ID__c != null && a.RCE_ID__c != '')
                mapAcc.put(a.RCE_ID__c, a);
            else if(a.iSell__OSKeyID__c != null && a.iSell__OSKeyID__c != '')
                mapAcc.put(a.iSell__OSKeyID__c, a);
        }
        //Look for duplicate accounts and display error if found
        for(Account a : listAcc){
            if(a.RCE_ID__c != null && a.RCE_ID__c != ''){
                if(mapAcc.containsKey(a.RCE_ID__c)){
                    a.addError(System.label.SMB_CL002_Error_Duplicate_Account + '<a style = "color:#c00" href=\'/'  + mapAcc.get(a.RCE_ID__c).id + '\'>' + mapAcc.get(a.RCE_ID__c).Name + '</a>', false);
                }
            }
            else if(a.iSell__OSKeyID__c != null && a.iSell__OSKeyID__c != ''){
                if(mapAcc.containsKey(a.iSell__OSKeyID__c)){
                    a.addError(System.Label.SMB_CL002_Error_Duplicate_Account + '<a style = "color:#c00" href=\'/'  + mapAcc.get(a.iSell__OSKeyID__c).id + '\'>' + mapAcc.get(a.iSell__OSKeyID__c).Name + '</a>', false);
                }
            }
        }
    }
}*/