/**
    About
    -----
    Description: This class updates the Contact Field SMB_Account_Type__c with the RecordType Developer name of related Account.
    Created for: SAMBA Wave2
    Create date: Oct 2014
    
    Details
    -------
    This class will be initiated once Account RecordType is changed via AccountAfterUpdate TRG.
     
    Update History
    --------------
    Created Oct 2014 - A.B.    
    Issues / TODOs
    --------------  
*/
public without sharing class SMBW2_Account_TR001_UpdateContacts_TRG {
    
    //Update Contact field SMB_Account_Type__c with Account RecodType Developer Name when related Account RecordType is changed.
    public static void UpdateContact( Map<Id, Account> AccIdToAccountMap){
        
            
        try{
            //A.T.T.R.I.B.U.T.E.S
            Map<Id, List<Contact>> AccIdToConListMap = new Map<Id, List<Contact>>();    //This Map holds Account Id's and List of Contacts by Fetchign values from AccIdToAccountMap
            List<Contact> ConListToUpdate = new  List<Contact>();                       //This holds updated contact list
            Map<Id,String> RTIdToRTDeveloperNameMap = new  Map<Id,String>();            //This hold Recordtype Id to RecordType DeveloperName Map
            //A.T.T.R.I.B.U.T.E.S
            
            //Creating RecordType Id To Record Type Developer Name Map. 
            for(RecordType rT:  [Select r.SobjectType, r.Id, r.DeveloperName From RecordType r where r.SobjectType ='Account']){
                RTIdToRTDeveloperNameMap.put(rT.Id,rT.DeveloperName);
            }
             
            //Creating AccountId To related contact list Map.
            for(Contact c : [Select c.SMB_Account_Type__c, c.AccountId From Contact c where c.AccountId in :AccIdToAccountMap.keySet()]){
                
                if(AccIdToAccountMap.containsKey(c.AccountId)){
                    c.SMB_Account_Type__c = RTIdToRTDeveloperNameMap.get(AccIdToAccountMap.get(c.AccountId).RecordTypeId);
                }
                ConListToUpdate.add(c);
            }
            
            //updating the contacts.
            if(!ConListToUpdate.isEmpty())
            update ConListToUpdate;
            
        }catch(Exception e){
            system.debug(Logginglevel.INFO,'++++++EXCEPTION+++++'+e);
        }
    }
    
 }